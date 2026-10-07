import 'package:flutter/material.dart';

/// 卡片/列表视图切换按钮
class ViewToggle extends StatelessWidget {
  final bool isCardView;
  final VoidCallback onToggle;

  const ViewToggle({
    super.key,
    required this.isCardView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isCardView ? Icons.view_list : Icons.grid_view),
      onPressed: onToggle,
      tooltip: isCardView ? '切换为列表视图' : '切换为卡片视图',
    );
  }
}
