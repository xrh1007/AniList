import 'package:flutter/material.dart';

/// 自定义搜索框（带可交互的清除按钮）
class AppSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const AppSearchBar({
    super.key,
    this.hint = '搜索作品...',
    required this.onChanged,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}
