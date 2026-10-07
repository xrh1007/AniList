import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/work_provider.dart';
import '../widgets/draggable_fab.dart';
import '../widgets/type_icon.dart';
import 'work_list_page.dart';
import 'add_work_page.dart';
import 'settings_screen.dart';

/// 主屏幕 - 底部导航栏框架 + 全局可拖动 FAB
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  /// 各分类页是否处于批量模式（用于隐藏全局 FAB）
  final List<bool> _batchModeByTab = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkProvider>().loadAllWorks();
    });
  }

  /// FAB 自动匹配当前底部导航所在的分类
  Future<void> _onFabTap() async {
    final type = WorkType.values[_currentIndex];
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddWorkPage(type: type)),
    );
    // 保存成功后触发重建，列表页通过 watch 自动获取最新数据
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(0, WorkType.novel),
      _buildPage(1, WorkType.anime),
      _buildPage(2, WorkType.manga),
      _buildPage(3, WorkType.galgame),
      const SettingsScreen(),
    ];

    // 批量模式下隐藏 FAB，避免误触添加
    final showFab = _currentIndex < WorkType.values.length &&
        !_batchModeByTab[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // 页面主体
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          // 全局可拖动 FAB（设置页隐藏）
          if (showFab)
            Positioned.fill(
              child: DraggableFab(
                onTap: _onFabTap,
                child: _buildFabButton(context),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          _buildNavItem(0, WorkType.novel),
          _buildNavItem(1, WorkType.anime),
          _buildNavItem(2, WorkType.manga),
          _buildNavItem(3, WorkType.galgame),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, WorkType type) {
    return BottomNavigationBarItem(
      // 使用自定义 SVG 类型图标（选中/未选中自动着色）
      icon: TypeIconNavBar(
        type: type,
        isSelected: _currentIndex == index,
        withLabel: false,
      ),
      label: type.label,
    );
  }

  /// 构建分类列表页，跟踪其批量模式状态
  Widget _buildPage(int index, WorkType type) {
    return WorkListPage(
      type: type,
      onBatchModeChanged: (batchMode) {
        if (!mounted) return;
        setState(() => _batchModeByTab[index] = batchMode);
      },
    );
  }

  /// 自绘 FAB 外观，点击统一交给 DraggableFab 处理
  Widget _buildFabButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
