import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/work.dart';
import 'status_tag.dart';
import 'type_icon.dart';

/// 列表视图中的单行作品条目
/// [selectionMode] 为 true 时显示左侧 Checkbox，点击切换选中
class WorkListTile extends StatelessWidget {
  final Work work;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  const WorkListTile({
    super.key,
    required this.work,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: selectionMode
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onTap(),
                    activeColor: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                  const SizedBox(width: 4),
                  _ThumbnailCover(coverPath: work.coverPath, type: work.type),
                ],
              )
            : _ThumbnailCover(coverPath: work.coverPath, type: work.type),
        title: Row(
          children: [
            TypeIcon(type: work.type, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                work.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            StatusTag(status: work.status, type: work.type),
            const SizedBox(width: 8),
            Text(
              work.addDate,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class _ThumbnailCover extends StatelessWidget {
  final String? coverPath;
  final WorkType type;

  const _ThumbnailCover({required this.coverPath, required this.type});

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    if (coverPath != null && coverPath!.isNotEmpty && File(coverPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(coverPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.placeholderPink,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: TypeIcon(type: type, size: 20)),
    );
  }
}
