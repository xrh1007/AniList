import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/work.dart';
import '../providers/work_provider.dart';
import '../widgets/cover_selector.dart';
import '../widgets/status_selector.dart';
import '../widgets/status_tag.dart';
import '../widgets/type_icon.dart';

/// 作品详情 + 内嵌编辑页
class WorkDetailPage extends StatefulWidget {
  final Work work;

  const WorkDetailPage({super.key, required this.work});

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _platformController;
  late TextEditingController _urlController;
  late WorkStatus _status;
  late String? _coverPath;
  late Work _work;
  bool _isEditing = false;
  /// 是否发生过修改（保存/删除），返回列表页时用于触发刷新
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _work = widget.work;
    _titleController = TextEditingController(text: widget.work.title);
    _platformController = TextEditingController(text: widget.work.platform);
    _urlController = TextEditingController(text: widget.work.url);
    _status = widget.work.status;
    _coverPath = widget.work.coverPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  /// 读取非必填输入框内容，空串返回 null
  static String? _readOptional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  /// 保存编辑
  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showToast('标题不能为空');
      return;
    }

    final updated = Work(
      id: _work.id,
      title: _titleController.text.trim(),
      type: _work.type,
      status: _status,
      coverPath: _coverPath,
      platform: _readOptional(_platformController),
      url: _readOptional(_urlController),
      addDate: _work.addDate,
      startDate: _work.startDate,
      completionDate: _work.completionDate,
    );

    await context.read<WorkProvider>().updateWork(_work, updated);
    // 更新本地状态，确保日期等信息实时刷新
    setState(() {
      _work = updated;
      _isEditing = false;
      _changed = true;
    });

    if (mounted) _showToast('已保存');
  }

  /// 删除作品
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${_work.title}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 关闭对话框
              await context.read<WorkProvider>().deleteWork(
                    _work.id!,
                    _work.type,
                  );
              if (mounted) Navigator.pop(context, true); // 返回列表并通知刷新
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 打开作品网址（外部浏览器）
  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _showToast('网址格式无效');
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) _showToast('无法打开链接');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // PopScope 拦截返回：若发生过修改（保存/删除），回传 true 触发列表刷新
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _changed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('作品详情'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              )
            else
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _save,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面大图
              CoverSelector(
                coverPath: _coverPath,
                type: _work.type,
                width: double.infinity,
                height: 280,
                enabled: _isEditing,
                placeholderText: _isEditing ? '点击更换封面' : null,
                onChanged: (path) => setState(() => _coverPath = path),
              ),
              const SizedBox(height: 24),

              // 标题
              if (_isEditing)
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '作品标题',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textInputAction: TextInputAction.next,
                )
              else ...[
                Row(
                  children: [
                    TypeIcon(type: _work.type, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _work.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatusTag(status: _status, type: _work.type),
              ],

              // 观看平台与网址（编辑模式，Galgame 无此两项）
              if (_isEditing && _work.type != WorkType.galgame) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _platformController,
                  decoration: const InputDecoration(
                    labelText: '观看平台（选填）',
                    hintText: '如 Bilibili / 番茄小说',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: '网址（选填）',
                    hintText: '作品链接',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
              ],
              const SizedBox(height: 20),

              // 状态选择（编辑模式）
              if (_isEditing) ...[
                Text(
                  '状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                StatusSelector(
                  value: _status,
                  type: _work.type,
                  onChanged: (s) => setState(() => _status = s),
                ),
                const SizedBox(height: 20),
              ],

              // 观看平台与网址（仅非 Galgame 且已填写时显示）
              if (_work.type != WorkType.galgame) ...[
                if (_hasValue(_work.platform))
                  _buildInfoRow('观看平台', _work.platform!, textColor, subColor),
                if (_hasValue(_work.url))
                  _buildUrlRow(_work.url!, textColor, subColor),
              ],

              // 日期信息
              _buildDateRow('添加日期', Work.formatDate(_work.addDate), textColor, subColor),
              _buildDateRow('开始日期', Work.formatDate(_work.startDate), textColor, subColor),
              _buildDateRow('完成日期', Work.formatDate(_work.completionDate), textColor, subColor),
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasValue(String? s) => s != null && s.isNotEmpty;

  Widget _buildInfoRow(String label, String value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: subColor, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// 网址行：点击跳转外部浏览器
  Widget _buildUrlRow(String url, Color textColor, Color subColor) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('网址', style: TextStyle(color: subColor, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _launchUrl(url),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 14, color: accent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: subColor, fontSize: 14)),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
