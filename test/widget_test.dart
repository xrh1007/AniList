import 'package:flutter_test/flutter_test.dart';
import 'package:anilist/app.dart';

void main() {
  testWidgets('App starts with splash then enters main screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AniListApp());

    // 启动页可见
    expect(find.text('AniList'), findsWidgets);

    // 推进 2 秒，启动页定时器触发并完成淡入过渡
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 主页底部导航可见（测试环境无数据库，列表为空但页面正常）
    expect(find.text('轻小说'), findsWidgets);
    expect(find.text('Galgame'), findsWidgets);
    expect(find.text('设置'), findsWidgets);

    // 空状态引导可见
    expect(find.text('还没有作品，快去添加吧~'), findsOneWidget);
  });
}
