import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/work_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class AniListApp extends StatelessWidget {
  const AniListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WorkProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'AniList',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
