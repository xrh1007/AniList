import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/work.dart';

class WorkProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 按分类缓存的作品列表
  final Map<WorkType, List<Work>> _worksByType = {};

  List<Work> getWorks(WorkType type) {
    return _worksByType[type] ?? [];
  }

  /// 从数据库加载所有作品
  /// 数据库不可用时静默降级为空列表，避免应用崩溃
  Future<void> loadAllWorks() async {
    try {
      for (final type in WorkType.values) {
        final works = await _dbHelper.getWorksByType(type.name);
        _worksByType[type] = works;
      }
    } catch (_) {
      for (final type in WorkType.values) {
        _worksByType[type] ??= [];
      }
    }
    notifyListeners();
  }

  /// 添加作品（含日期自动记录：直接以进行中/已完成状态创建时补记日期）
  Future<void> addWork(Work work) async {
    final now = Work.todayStr();
    if (work.status == WorkStatus.watching &&
        (work.startDate == null || work.startDate!.isEmpty)) {
      work.startDate = now;
    }
    if (work.status.isCompleted &&
        (work.completionDate == null || work.completionDate!.isEmpty)) {
      work.completionDate = now;
    }
    final added = await _dbHelper.insertWork(work);
    _worksByType[work.type]?.insert(0, added);
    notifyListeners();
  }

  /// 更新作品（含日期自动记录逻辑）
  Future<void> updateWork(Work oldWork, Work updatedWork) async {
    // 状态变更时自动记录日期
    if (updatedWork.status != oldWork.status) {
      final now = Work.todayStr();
      // 从"想看/想玩"变为进行中 → 记录开始日期
      if (oldWork.status == WorkStatus.wantToSee &&
          updatedWork.status == WorkStatus.watching &&
          (updatedWork.startDate == null || updatedWork.startDate!.isEmpty)) {
        updatedWork.startDate = now;
      }
      // 变为"已看完/结局" → 记录完成日期
      if (updatedWork.status.isCompleted) {
        updatedWork.completionDate = now;
      }
      // 离开"已看完/结局" → 清除完成日期
      if (oldWork.status.isCompleted && !updatedWork.status.isCompleted) {
        updatedWork.completionDate = null;
      }
    }
    await _dbHelper.updateWork(updatedWork);
    final works = _worksByType[updatedWork.type];
    if (works != null) {
      final idx = works.indexWhere((w) => w.id == updatedWork.id);
      if (idx != -1) {
        works[idx] = updatedWork;
      }
    }
    notifyListeners();
  }

  /// 删除作品
  Future<void> deleteWork(int id, WorkType type) async {
    await _dbHelper.deleteWork(id);
    _worksByType[type]?.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  /// 批量删除作品（一次通知刷新）
  Future<void> batchDelete(Set<int> ids) async {
    for (final id in ids) {
      await _dbHelper.deleteWork(id);
    }
    for (final type in WorkType.values) {
      _worksByType[type]?.removeWhere((w) => ids.contains(w.id));
    }
    notifyListeners();
  }

  /// 批量修改状态（逐条复用 updateWork，保留日期自动联动逻辑）
  Future<void> batchUpdateStatus(Set<int> ids, WorkStatus newStatus) async {
    for (final type in WorkType.values) {
      final works = _worksByType[type];
      if (works == null) continue;
      for (final w in List<Work>.from(works)) {
        if (!ids.contains(w.id) || w.status == newStatus) continue;
        final updated = Work(
          id: w.id,
          title: w.title,
          type: w.type,
          status: newStatus,
          coverPath: w.coverPath,
          platform: w.platform,
          url: w.url,
          addDate: w.addDate,
          startDate: w.startDate,
          completionDate: w.completionDate,
        );
        await updateWork(w, updated);
      }
    }
  }

  /// 清空所有作品
  Future<void> clearAll() async {
    await _dbHelper.clearAllWorks();
    for (final type in WorkType.values) {
      _worksByType[type] = [];
    }
    notifyListeners();
  }

  /// 导出 JSON 字符串（供文件保存对话框使用）
  Future<String> exportData() async {
    return await _dbHelper.exportToJson();
  }

  /// 从文件导入（merge=true 合并导入，false 覆盖导入），返回导入条数
  Future<int> importData(String filePath, {bool merge = false}) async {
    final count =
        await _dbHelper.importFromFile(filePath, merge: merge);
    await loadAllWorks();
    return count;
  }
}
