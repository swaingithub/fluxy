import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Fx.to('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Fx(() {
      final isDark = FxTheme.isDarkMode;
      
      return Scaffold(
        body: Stack(
          children: [
            if (isDark)
              const FxMeshGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF6366F1), Color(0xFF0F172A)],
                speed: 0.5,
              )
            else
              const FxMeshGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFF6366F1), Color(0xFFEEF2FF)],
                speed: 0.5,
              ),
            Center(
              child: Fx.col(
                gap: 20,
                children: [
                  FxPulsar(
                    child: Icon(Icons.travel_explore_rounded, size: 80, color: isDark ? Colors.white : const Color(0xFF6366F1)),
                  ),
                  FxEntrance(
                    slideOffset: const Offset(0, 20),
                    child: Fx.text('ELITE TRAVEL')
                        .bold()
                        .fontSize(36)
                        .spacing(4)
                        .color(isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  FxEntrance(
                    delay: const Duration(milliseconds: 500),
                    child: Fx.text('Your Journey Begins Here')
                        .color(isDark ? Colors.white60 : Colors.black45)
                        .textSm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
