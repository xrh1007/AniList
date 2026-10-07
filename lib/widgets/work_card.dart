import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/work.dart';
import 'status_tag.dart';
import 'type_icon.dart';

/// 卡片视图中的单个作品卡片
/// [selectionMode] 为 true 时显示左侧 Checkbox，点击切换选中
class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  const WorkCard({
    super.key,
    required this.work,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 批量模式：左侧多选 Checkbox
              if (selectionMode) ...[
                Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  activeColor:
                      isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
                const SizedBox(width: 4),
              ],
              // 封面图片
              _CoverImage(coverPath: work.coverPath, type: work.type),
              const SizedBox(width: 12),
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        TypeIcon(type: work.type, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            work.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 状态标签
                    StatusTag(status: work.status, type: work.type),
                    const SizedBox(height: 4),
                    // 添加日期
                    Text(
                      '添加于 ${work.addDate}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? coverPath;
  final WorkType type;

  const _CoverImage({required this.coverPath, required this.type});

  @override
  Widget build(BuildContext context) {
    final size = 80.0;
    if (coverPath != null && coverPath!.isNotEmpty && File(coverPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(coverPath!),
          width: size,
          height: size * 1.4,
          fit: BoxFit.cover,
        ),
      );
    }
    // 无封面时显示默认占位图
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: AppColors.placeholderPink,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TypeIcon(type: type, size: 36),
      ),
    );
  }
}
