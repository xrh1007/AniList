import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

/// 作品类型 SVG 图标
class TypeIcon extends StatelessWidget {
  final WorkType type;
  final double size;

  const TypeIcon({super.key, required this.type, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/${type.assetName}.svg',
      width: size,
      height: size,
    );
  }
}

/// 底部导航使用的类型图标（带选中/未选中状态着色）
/// [withLabel] 为 false 时只显示图标（配合 BottomNavigationBarItem 的 label 使用）
class TypeIconNavBar extends StatelessWidget {
  final WorkType type;
  final bool isSelected;
  final bool withLabel;

  const TypeIconNavBar({
    super.key,
    required this.type,
    this.isSelected = false,
    this.withLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;
    final color = isSelected
        ? navTheme.selectedItemColor
        : navTheme.unselectedItemColor;

    final icon = ColorFiltered(
      colorFilter: ColorFilter.mode(
        color ?? Colors.grey,
        BlendMode.srcIn,
      ),
      child: SvgPicture.asset(
        'assets/icons/${type.assetName}.svg',
        width: 24,
        height: 24,
      ),
    );

    if (!withLabel) return icon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 4),
        Text(
          type.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
