import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 状态选择器：彩色圆角选项横向排列，选中时填充状态色
/// [value] 为 null 时无选中高亮（批量修改场景），点击直接触发 onChanged
class StatusSelector extends StatelessWidget {
  final WorkStatus? value;
  final WorkType type;
  final ValueChanged<WorkStatus> onChanged;

  const StatusSelector({
    super.key,
    required this.value,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          WorkStatus.values.map((s) => _buildOption(context, s)).toList(),
    );
  }

  Widget _buildOption(BuildContext context, WorkStatus status) {
    final isSelected = value == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.statusColor(status, isDark);

    return GestureDetector(
      onTap: () => onChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          status.labelFor(type),
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
