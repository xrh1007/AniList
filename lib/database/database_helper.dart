import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/work.dart';

class DatabaseHelper {
  static const _databaseName = 'anilist.db';
  static const _databaseVersion = 2;
  static const tableName = 'works';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        coverPath TEXT,
        platform TEXT,
        url TEXT,
        addDate TEXT NOT NULL,
        startDate TEXT,
        completionDate TEXT
      )
    ''');
  }

  /// v1 → v2：新增观看平台与网址两列（ALTER TABLE 不动既有数据，旧记录两列为空）
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN platform TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN url TEXT');
    }
  }

  // ==================== CRUD ====================

  /// 插入新作品，返回带 id 的 Work
  Future<Work> insertWork(Work work) async {
    final db = await database;
    final id = await db.insert(tableName, work.toMap());
    work.id = id;
    return work;
  }

  /// 更新作品，返回更新的行数
  Future<int> updateWork(Work work) async {
    final db = await database;
    return await db.update(
      tableName,
      work.toMap(),
      where: 'id = ?',
      whereArgs: [work.id],
    );
  }

  /// 删除作品
  Future<int> deleteWork(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有作品
  Future<List<Work>> getAllWorks() async {
    final db = await database;
    final maps = await db.query(tableName, orderBy: 'id DESC');
    return maps.map((m) => Work.fromMap(m)).toList();
  }

  /// 按分类获取作品
  Future<List<Work>> getWorksByType(String typeName) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [typeName],
      orderBy: 'id DESC',
    );
    return maps.map((m) => Work.fromMap(m)).toList();
  }

  /// 获取单个作品
  Future<Work?> getWorkById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Work.fromMap(maps.first);
  }

  /// 清空所有作品
  Future<int> clearAllWorks() async {
    final db = await database;
    return await db.delete(tableName);
  }

  // ==================== 导出导入 ====================

  /// 导出所有数据为 JSON 字符串
  Future<String> exportToJson() async {
    final works = await getAllWorks();
    final jsonList = works.map((w) => w.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// 导出 JSON 文件到应用文档目录，返回文件路径
  Future<String> exportToFile() async {
    final jsonStr = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'anilist_backup.json'));
    await file.writeAsString(jsonStr);
    return file.path;
  }

  /// 导出 JSON 字符串到用户指定路径（通过系统文件保存对话框获得）
  Future<void> exportToPath(String jsonStr, String savePath) async {
    final file = File(savePath);
    await file.writeAsString(jsonStr, flush: true);
  }

  /// 从 JSON 字符串导入数据
  /// [merge] 为 true 时合并导入（跳过已存在的同标题同类型记录），
  /// 为 false 时覆盖导入（先清空再导入）
  Future<int> importFromJson(String jsonStr, {bool merge = false}) async {
    final db = await database;
    if (!merge) {
      await db.delete(tableName);
    }

    final List<dynamic> jsonList = jsonDecode(jsonStr);

    // 合并模式：收集现有记录的 (title, type) 用于去重
    final Set<String> existingKeys = {};
    if (merge) {
      final existing = await db.query(tableName, columns: ['title', 'type']);
      for (final row in existing) {
        existingKeys.add('${row['title']}|${row['type']}');
      }
    }

    int count = 0;
    for (final item in jsonList) {
      final work = Work.fromJson(item as Map<String, dynamic>);
      if (merge) {
        final key = '${work.title}|${work.type.name}';
        if (existingKeys.contains(key)) continue; // 跳过重复记录
        existingKeys.add(key);
      }
      await db.insert(tableName, work.toMap());
      count++;
    }
    return count;
  }

  /// 从文件导入数据
  Future<int> importFromFile(String filePath, {bool merge = false}) async {
    final file = File(filePath);
    final jsonStr = await file.readAsString();
    return importFromJson(jsonStr, merge: merge);
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
