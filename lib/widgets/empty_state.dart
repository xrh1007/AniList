import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 空状态引导图 + 提示文字
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, this.message = '还没有作品，快去添加吧~'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2D 萝莉引导插图（手绘/赛璐璐画风）
          Image.asset(
            'assets/images/empty_illust.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardBackground
                    : AppColors.placeholderPink,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.favorite,
                size: 48,
                color: accent.withValues(alpha: isDark ? 0.5 : 0.3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: subColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
