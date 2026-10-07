import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/work.dart';
import '../providers/work_provider.dart';
import '../widgets/cover_selector.dart';
import '../widgets/status_selector.dart';

/// 添加作品页面
class AddWorkPage extends StatefulWidget {
  final WorkType type;

  const AddWorkPage({super.key, required this.type});

  @override
  State<AddWorkPage> createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _urlController = TextEditingController();
  WorkStatus _status = WorkStatus.wantToSee;
  String? _coverPath;

  bool _isSaving = false;

  /// 保存作品
  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showToast('请输入作品标题');
      return;
    }

    setState(() => _isSaving = true);

    final work = Work(
      title: _titleController.text.trim(),
      type: widget.type,
      status: _status,
      coverPath: _coverPath,
      // 非必填：trim 后为空则存 null，保持数据干净
      platform: _readOptional(_platformController),
      url: _readOptional(_urlController),
      addDate: Work.todayStr(),
    );

    await context.read<WorkProvider>().addWork(work);
    setState(() => _isSaving = false);

    // 回传 true，通知上一页数据已变更，需要刷新列表
    if (mounted) Navigator.pop(context, true);
  }

  /// 读取非必填输入框内容，空串返回 null
  static String? _readOptional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('添加${widget.type.label}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片选择
            Center(
              child: CoverSelector(
                coverPath: _coverPath,
                type: widget.type,
                width: 160,
                height: 220,
                showBorder: true,
                placeholderText: '选择封面',
                onChanged: (path) => setState(() => _coverPath = path),
              ),
            ),
            const SizedBox(height: 24),

            // 标题输入
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '作品标题',
                hintText: '请输入作品标题',
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
            ),

            // 观看平台与网址（Galgame 无此两项）
            if (widget.type != WorkType.galgame) ...[
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
                textInputAction: TextInputAction.next,
              ),
            ],
            const SizedBox(height: 20),

            // 状态选择
            Text(
              '状态',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            StatusSelector(
              value: _status,
              type: widget.type,
              onChanged: (s) => setState(() => _status = s),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSaving
          ? const CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: _save,
              // 图标在上、文字在下垂直排列，水平居中
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.save, size: 20),
                  SizedBox(height: 4),
                  Text('保存', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
    );
  }
}
