import 'package:flutter/material.dart';

/// 作品类型枚举
enum WorkType {
  novel('轻小说', 'novel'),
  anime('动漫', 'anime'),
  manga('漫画', 'manga'),
  galgame('Galgame', 'galgame');

  const WorkType(this.label, this.assetName);
  final String label;
  final String assetName;
}

/// 通用状态枚举（用于轻小说/动漫/漫画）
enum WorkStatus {
  /// 想看 / 想玩
  wantToSee('想看', '想玩'),
  /// 追番中 / 推线中
  watching('追番中', '推线中'),
  /// 已看完 / 结局
  completed('已看完', '结局'),
  /// 弃坑
  dropped('弃坑', '弃坑');

  const WorkStatus(this.labelForAnime, this.labelForGalgame);
  final String labelForAnime;
  final String labelForGalgame;

  /// 根据作品类型获取对应标签文字
  String labelFor(WorkType type) {
    return type == WorkType.galgame ? labelForGalgame : labelForAnime;
  }

  /// 是否为"已完成"状态
  bool get isCompleted => this == WorkStatus.completed;
}

/// 排序方式枚举
enum SortMode {
  addDate('添加时间'),
  title('标题'),
  status('状态');

  const SortMode(this.label);
  final String label;
}

// ==================== 颜色常量 ====================

class AppColors {
  // 亮色模式
  static const Color lightPrimary = Color(0xFFFFB7C5);
  static const Color lightAccent = Color(0xFFFF69B4);
  static const Color lightBackground = Color(0xFFFFF0F5);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF888888);
  static const Color lightSurface = Color(0xFFFFF5F8);

  // 深色模式
  static const Color darkPrimary = Color(0xFFD4728C);
  static const Color darkAccent = Color(0xFFFF69B4);
  static const Color darkBackground = Color(0xFF1E1E2E);
  static const Color darkCardBackground = Color(0xFF2D2D3D);
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkSurface = Color(0xFF252535);

  // 通用（亮/暗共用）
  /// 封面占位浅粉背景
  static const Color placeholderPink = Color(0xFFFFE4EC);
  /// 深色模式边框
  static const Color darkBorder = Color(0xFF444444);

  // 状态标签颜色 - 亮色
  static const Color statusWantLight = Color(0xFF4A9EFF);
  static const Color statusWatchingLight = Color(0xFFFF69B4);
  static const Color statusCompletedLight = Color(0xFF4CAF50);
  static const Color statusDroppedLight = Color(0xFF9E9E9E);

  // 状态标签颜色 - 深色
  static const Color statusWantDark = Color(0xFF6BB5FF);
  static const Color statusWatchingDark = Color(0xFFFF8DC7);
  static const Color statusCompletedDark = Color(0xFF66BB6A);
  static const Color statusDroppedDark = Color(0xFF757575);

  /// 根据亮/暗模式获取状态标签颜色
  static Color statusColor(WorkStatus status, bool isDark) {
    switch (status) {
      case WorkStatus.wantToSee:
        return isDark ? statusWantDark : statusWantLight;
      case WorkStatus.watching:
        return isDark ? statusWatchingDark : statusWatchingLight;
      case WorkStatus.completed:
        return isDark ? statusCompletedDark : statusCompletedLight;
      case WorkStatus.dropped:
        return isDark ? statusDroppedDark : statusDroppedLight;
    }
  }
}
