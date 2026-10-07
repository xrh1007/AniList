import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 彩色状态标签
class StatusTag extends StatelessWidget {
  final WorkStatus status;
  final WorkType type;

  const StatusTag({super.key, required this.status, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.statusColor(status, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status.labelFor(type),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
