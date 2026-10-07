import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:anilist/constants/app_constants.dart';
import 'package:anilist/models/work.dart';

void main() {
  group('导出数据导入兼容性', () {
    test('旧版本导出的 JSON（无 platform/url 字段）可正常导入', () {
      // 旧版本 toJson 输出的格式（不含新字段）
      final oldJson = jsonEncode([
        {
          'title': '葬送的芙莉莲',
          'type': 'anime',
          'status': 'watching',
          'coverPath': '/data/user/0/cover_1.jpg',
          'addDate': '2026-08-01',
          'startDate': '2026-08-02',
          'completionDate': null,
        },
        {
          'title': 'Galgame 作品',
          'type': 'galgame',
          'status': 'completed',
          'coverPath': null,
          'addDate': '2026-07-01',
          'startDate': null,
          'completionDate': '2026-07-15',
        },
      ]);

      final list = jsonDecode(oldJson) as List;
      final works =
          list.map((e) => Work.fromJson(e as Map<String, dynamic>)).toList();

      expect(works.length, 2);
      // 旧数据导入后新字段为空，其余字段原样保留
      expect(works[0].platform, isNull);
      expect(works[0].url, isNull);
      expect(works[0].title, '葬送的芙莉莲');
      expect(works[0].type, WorkType.anime);
      expect(works[0].status, WorkStatus.watching);
      expect(works[0].startDate, '2026-08-02');
      expect(works[1].completionDate, '2026-07-15');
    });

    test('新版本导出的 JSON（含 platform/url）可正常回导', () {
      final work = Work(
        title: '轻小说作品',
        type: WorkType.novel,
        status: WorkStatus.wantToSee,
        platform: '番茄小说',
        url: 'https://example.com/book/1',
        addDate: '2026-10-01',
      );

      final restored = Work.fromJson(
        jsonDecode(jsonEncode(work.toJson())) as Map<String, dynamic>,
      );

      expect(restored.platform, '番茄小说');
      expect(restored.url, 'https://example.com/book/1');
      expect(restored.title, '轻小说作品');
    });
  });
}
