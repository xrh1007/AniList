import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import 'type_icon.dart';

/// 封面选择器：预览封面图，点击从相册选择并复制到应用文档目录
/// [showBorder] 为 true 时显示粉框 + 加号占位（添加页样式）；
/// 为 false 时显示类型图标占位（详情页样式），[placeholderText] 控制提示文字
class CoverSelector extends StatelessWidget {
  final String? coverPath;
  final WorkType type;
  final double width;
  final double height;
  final ValueChanged<String?> onChanged;
  final bool showBorder;
  final bool enabled;
  final String? placeholderText;
  final double borderRadius;

  const CoverSelector({
    super.key,
    required this.coverPath,
    required this.type,
    required this.width,
    required this.height,
    required this.onChanged,
    this.showBorder = false,
    this.enabled = true,
    this.placeholderText,
    this.borderRadius = 16,
  });

  /// 从相册选择封面并复制到应用文档目录，成功后回调新路径
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = p.join(dir.path, fileName);
      await File(picked.path).copy(savedPath);
      onChanged(savedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? _pickImage : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.placeholderPink,
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder
              ? Border.all(
                  color:
                      isDark ? AppColors.darkBorder : AppColors.lightPrimary,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : null,
        ),
        child: _buildChild(isDark),
      ),
    );
  }

  Widget _buildChild(bool isDark) {
    // 有封面：圆角裁剪显示图片
    if (coverPath != null && coverPath!.isNotEmpty && File(coverPath!).existsSync()) {
      return ClipRRect(
        // 有边框时内缩 2 像素避免覆盖边框
        borderRadius: BorderRadius.circular(borderRadius - (showBorder ? 2 : 0)),
        child: Image.file(File(coverPath!), fit: BoxFit.cover),
      );
    }

    // 无封面：加号占位（添加页）或类型图标占位（详情页）
    if (showBorder) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.lightPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            placeholderText ?? '选择封面',
            style: TextStyle(
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.lightPrimary,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TypeIcon(type: type, size: 64),
        if (placeholderText != null) ...[
          const SizedBox(height: 8),
          Text(
            placeholderText!,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
