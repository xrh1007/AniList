import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/work.dart';
import '../providers/work_provider.dart';
import '../widgets/work_card.dart';
import '../widgets/work_list_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_bar.dart';
import '../widgets/status_selector.dart';
import '../widgets/view_toggle.dart';
import 'work_detail_page.dart';

/// 单个分类的作品列表页（含状态筛选、搜索、排序、视图切换、批量管理）
class WorkListPage extends StatefulWidget {
  final WorkType type;
  /// 批量模式状态变更回调（MainScreen 用于隐藏全局 FAB）
  final ValueChanged<bool>? onBatchModeChanged;

  const WorkListPage({super.key, required this.type, this.onBatchModeChanged});

  @override
  State<WorkListPage> createState() => _WorkListPageState();
}

class _WorkListPageState extends State<WorkListPage> {
  bool _isCardView = true;
  String _searchQuery = '';
  WorkStatus? _filterStatus;
  SortMode _sortMode = SortMode.addDate;

  // 批量管理状态
  bool _isBatchMode = false;
  final Set<int> _selectedWorkIds = {};

  List<Work> get _filteredWorks {
    // watch 建立监听：数据变更（添加/编辑/删除）时自动重建列表
    final provider = context.watch<WorkProvider>();
    var works = provider.getWorks(widget.type);

    if (_filterStatus != null) {
      works = works.where((w) => w.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      works = works
          .where((w) =>
              w.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_sortMode) {
      case SortMode.addDate:
        break; // 默认已按添加时间倒序
      case SortMode.title:
        // 按拼音顺序（中文标题转拼音，英文标题原样比较）
        works.sort((a, b) =>
            _pinyinKey(a.title).compareTo(_pinyinKey(b.title)));
      case SortMode.status:
        // 按状态分组，同状态内保持添加时间倒序
        works.sort((a, b) {
          final c = a.status.index.compareTo(b.status.index);
          if (c != 0) return c;
          return (b.id ?? 0).compareTo(a.id ?? 0);
        });
    }
    return works;
  }

  /// 生成用于拼音排序的键：中文转无声调拼音，其他字符转小写
  static final Map<String, String> _pinyinCache = {};
  static String _pinyinKey(String title) {
    return _pinyinCache.putIfAbsent(
      title,
      () => PinyinHelper.getPinyinE(
        title.toLowerCase(),
        separator: '',
        defPinyin: '#',
      ),
    );
  }

  /// 跳转详情页，返回 true 表示数据已变更，刷新列表
  Future<void> _navigateToDetail(Work work) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WorkDetailPage(work: work)),
    );
    if (changed == true && mounted) {
      setState(() {}); // 重新执行 _filteredWorks 获取最新数据
    }
  }

  // ==================== 批量管理 ====================

  void _setBatchMode(bool value) {
    setState(() => _isBatchMode = value);
    widget.onBatchModeChanged?.call(value);
  }

  /// 进入批量模式（[workId] 为长按的作品，默认选中）
  void _enterBatchMode([int? workId]) {
    if (workId != null) _selectedWorkIds.add(workId);
    _setBatchMode(true);
  }

  /// 退出批量模式并清空选中
  void _exitBatchMode() {
    _selectedWorkIds.clear();
    _setBatchMode(false);
  }

  void _toggleSelect(int id) {
    setState(() {
      if (!_selectedWorkIds.add(id)) _selectedWorkIds.remove(id);
    });
  }

  /// 全选 / 取消全选（以当前筛选结果为范围）
  void _toggleSelectAll() {
    final ids = _filteredWorks.map((w) => w.id!).toSet();
    setState(() {
      if (_selectedWorkIds.length == ids.length) {
        _selectedWorkIds.clear();
      } else {
        _selectedWorkIds
          ..clear()
          ..addAll(ids);
      }
    });
  }

  /// 批量修改状态：底部弹窗选择，选择后立即执行
  void _showStatusSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '批量修改状态（${_selectedWorkIds.length} 项）',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StatusSelector(
                value: null,
                type: widget.type,
                onChanged: (status) {
                  Navigator.pop(sheetContext);
                  _batchUpdateStatus(status);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _batchUpdateStatus(WorkStatus status) async {
    final ids = Set<int>.from(_selectedWorkIds);
    await context.read<WorkProvider>().batchUpdateStatus(ids, status);
    if (!mounted) return;
    _showToast('已将 ${ids.length} 部作品状态更新为「${status.labelFor(widget.type)}」');
    _exitBatchMode();
  }

  Future<void> _batchDelete() async {
    final ids = Set<int>.from(_selectedWorkIds);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${ids.length} 部作品吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<WorkProvider>().batchDelete(ids);
    if (!mounted) return;
    _showToast('已删除 ${ids.length} 部作品');
    _exitBatchMode();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ==================== 页面构建 ====================

  @override
  Widget build(BuildContext context) {
    final works = _filteredWorks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isBatchMode ? '已选 ${_selectedWorkIds.length} 项' : widget.type.label,
        ),
        actions: [
          // 批量管理入口（批量模式下退出按钮在底部操作栏）
          if (!_isBatchMode)
            IconButton(
              icon: const Icon(Icons.library_add_check_outlined),
              tooltip: '批量管理',
              onPressed: _enterBatchMode,
            ),
        ],
      ),
      // SafeArea 让内容避开系统状态栏（刘海屏/挖孔屏安全区），
      // bottom: false 避免与底部导航栏重复避让
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 状态筛选标签
            _buildFilterChips(),
            // 搜索框 + 排序 + 视图切换
            _buildToolBar(),
            // 作品列表
            Expanded(
              child: works.isEmpty
                  ? const EmptyState()
                  : _isCardView
                      ? _buildCardList(works)
                      : _buildTileList(works),
            ),
          ],
        ),
      ),
      // 批量模式底部操作栏
      bottomNavigationBar: _isBatchMode ? _buildBatchBar() : null,
    );
  }

  /// 顶部状态筛选标签
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('全部', null),
            const SizedBox(width: 8),
            ...WorkStatus.values
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildChip(s.labelFor(widget.type), s),
                    ))
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, WorkStatus? status) {
    final isSelected = _filterStatus == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 搜索框 + 排序 + 视图切换工具栏
  Widget _buildToolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: AppSearchBar(onChanged: (v) => setState(() => _searchQuery = v))),
          const SizedBox(width: 8),
          // 排序按钮
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort, size: 22),
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (_) => SortMode.values
                .map((m) => PopupMenuItem(
                      value: m,
                      child: Row(
                        children: [
                          if (_sortMode == m)
                            const Icon(Icons.check, size: 16, color: AppColors.lightAccent)
                          else
                            const SizedBox(width: 16),
                          const SizedBox(width: 8),
                          Text(m.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
          ViewToggle(
            isCardView: _isCardView,
            onToggle: () => setState(() => _isCardView = !_isCardView),
          ),
        ],
      ),
    );
  }

  /// 批量模式底部操作栏（全选 / 改状态 / 删除 / 退出）
  Widget _buildBatchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _batchAction(
            icon: _isAllSelected ? Icons.deselect : Icons.select_all,
            label: _isAllSelected ? '取消全选' : '全选',
            onTap: _toggleSelectAll,
            enabled: _filteredWorks.isNotEmpty,
          ),
          _batchAction(
            icon: Icons.flag_outlined,
            label: '改状态',
            onTap: _showStatusSheet,
            enabled: _selectedWorkIds.isNotEmpty,
          ),
          _batchAction(
            icon: Icons.delete_outline,
            label: '删除',
            onTap: _batchDelete,
            enabled: _selectedWorkIds.isNotEmpty,
            danger: true,
          ),
          _batchAction(
            icon: Icons.close,
            label: '退出',
            onTap: _exitBatchMode,
          ),
        ],
      ),
    );
  }

  bool get _isAllSelected =>
      _filteredWorks.isNotEmpty &&
      _selectedWorkIds.length >= _filteredWorks.length;

  /// 单个批量操作按钮（图标 + 文字纵向排列）
  Widget _batchAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool danger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color;
    if (!enabled) {
      color = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    } else if (danger) {
      color = Colors.redAccent;
    } else {
      color = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /// 卡片列表
  Widget _buildCardList(List<Work> works) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: works.length,
      itemBuilder: (_, index) {
        final work = works[index];
        return WorkCard(
          work: work,
          selectionMode: _isBatchMode,
          selected: _selectedWorkIds.contains(work.id),
          onTap: _isBatchMode
              ? () => _toggleSelect(work.id!)
              : () => _navigateToDetail(work),
          onLongPress: _isBatchMode ? null : () => _enterBatchMode(work.id),
        );
      },
    );
  }

  /// 列表视图
  Widget _buildTileList(List<Work> works) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: works.length,
      itemBuilder: (_, index) {
        final work = works[index];
        return WorkListTile(
          work: work,
          selectionMode: _isBatchMode,
          selected: _selectedWorkIds.contains(work.id),
          onTap: _isBatchMode
              ? () => _toggleSelect(work.id!)
              : () => _navigateToDetail(work),
          onLongPress: _isBatchMode ? null : () => _enterBatchMode(work.id),
        );
      },
    );
  }
}
