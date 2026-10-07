import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../providers/work_provider.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 深色模式
          _SectionTitle('外观'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('切换亮色/深色主题'),
              secondary: Icon(
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleDarkMode(),
              activeTrackColor: AppColors.lightAccent,
            ),
          ),
          const Divider(height: 32),

          // 数据管理
          _SectionTitle('数据管理'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('导出数据'),
            subtitle: const Text('将所有作品数据导出为 JSON 文件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导入数据'),
            subtitle: const Text('从 JSON 备份文件导入（支持合并/覆盖）'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('清除所有数据', style: TextStyle(color: Colors.red)),
            subtitle: const Text('删除全部作品记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearData(context),
          ),
          const Divider(height: 32),

          // 关于
          _SectionTitle('关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('AniList'),
            subtitle: Text('版本 1.1.0'),
          ),
          const ListTile(
            leading: Icon(Icons.favorite, color: AppColors.lightAccent),
            title: Text('专为二次元爱好者打造'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<WorkProvider>();
      final jsonStr = await provider.exportData();

      // 通过系统文件保存对话框选择保存位置（移动端由插件写入 bytes）
      final savePath = await FilePicker.platform.saveFile(
        fileName: 'anilist_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonStr),
      );
      if (savePath == null) return; // 用户取消

      // 桌面平台插件只返回路径，需要自行写入文件
      try {
        final file = File(savePath);
        if (!file.existsSync() || file.lengthSync() == 0) {
          await file.writeAsString(jsonStr, flush: true);
        }
      } catch (_) {
        // 移动端返回 content:// URI 时忽略（插件已通过 bytes 写入）
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已导出为 anilist_backup.json'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  /// 导入方式选择：合并（推荐）/ 覆盖
  Future<void> _importData(BuildContext context) async {
    final bool? mergeMode = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('导入数据'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('请选择导入方式：'),
            SizedBox(height: 12),
            Text('· 合并导入：保留现有作品，自动跳过重复项（推荐）',
                style: TextStyle(fontSize: 13)),
            SizedBox(height: 4),
            Text('· 覆盖导入：清空现有全部数据后导入备份',
                style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('覆盖导入', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightAccent,
            ),
            child: const Text('合并导入'),
          ),
        ],
      ),
    );
    if (mergeMode == null || !context.mounted) return;

    try {
      // 通过系统文件选择器选取 JSON 备份文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
      );
      final filePath = result?.files.single.path;
      if (filePath == null) return; // 用户取消

      if (!context.mounted) return;
      final count = await context
          .read<WorkProvider>()
          .importData(filePath, merge: mergeMode);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mergeMode
              ? '合并导入完成，共导入 $count 条新记录'
              : '覆盖导入完成，共导入 $count 条记录'),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _clearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有作品数据吗？此操作不可撤销！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<WorkProvider>().clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清除所有数据')),
                );
              }
            },
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.lightAccent,
        ),
      ),
    );
  }
}
