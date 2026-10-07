import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'main_screen.dart';

/// 启动页 - 2D 萝莉插画 + App 名称
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // 启动淡入动画
    _controller.forward();

    // 1.5秒后跳转到主页
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 2D 萝莉插画（手绘/赛璐璐画风）
              Image.asset(
                'assets/images/splash_illust.png',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.placeholderPink,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: AppColors.lightAccent,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AniList',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightAccent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '二次元作品追踪',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
