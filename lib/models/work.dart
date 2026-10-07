import 'package:anilist/constants/app_constants.dart';

/// 作品数据模型
class Work {
  int? id;
  String title;
  WorkType type;
  WorkStatus status;
  String? coverPath;

  /// 观看平台（仅轻小说/动漫/漫画使用，非必填）
  String? platform;

  /// 作品网址（非必填）
  String? url;

  String addDate;
  String? startDate;
  String? completionDate;

  Work({
    this.id,
    required this.title,
    required this.type,
    required this.status,
    this.coverPath,
    this.platform,
    this.url,
    required this.addDate,
    this.startDate,
    this.completionDate,
  });

  /// 从数据库 Map 创建 Work 对象
  factory Work.fromMap(Map<String, dynamic> map) {
    return Work(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: WorkType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WorkType.anime,
      ),
      status: WorkStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WorkStatus.wantToSee,
      ),
      coverPath: map['coverPath'] as String?,
      // 旧版本数据库行无这两列时自动为 null
      platform: map['platform'] as String?,
      url: map['url'] as String?,
      addDate: map['addDate'] as String,
      startDate: map['startDate'] as String?,
      completionDate: map['completionDate'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'status': status.name,
      'coverPath': coverPath,
      'platform': platform,
      'url': url,
      'addDate': addDate,
      'startDate': startDate,
      'completionDate': completionDate,
    };
  }

  /// 转换为 JSON（用于导出）
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'status': status.name,
      'coverPath': coverPath,
      'platform': platform,
      'url': url,
      'addDate': addDate,
      'startDate': startDate,
      'completionDate': completionDate,
    };
  }

  /// 从 JSON 创建 Work 对象（用于导入）
  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      title: json['title'] as String,
      type: WorkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WorkType.anime,
      ),
      status: WorkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkStatus.wantToSee,
      ),
      coverPath: json['coverPath'] as String?,
      // 旧版本导出的 JSON 无这两个 key 时自动为 null，导入完全兼容
      platform: json['platform'] as String?,
      url: json['url'] as String?,
      addDate: json['addDate'] as String? ?? todayStr(),
      startDate: json['startDate'] as String?,
      completionDate: json['completionDate'] as String?,
    );
  }

  /// 获取当前日期字符串 (yyyy-MM-dd)
  static String todayStr() {
    final now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 格式化日期显示
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '未记录';
    return dateStr;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Work && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
