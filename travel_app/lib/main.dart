import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/auth_controller.dart';
import 'features/home/home_controller.dart';
import 'features/journal/journal_controller.dart';
import 'core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Fluxy.autoRegister();
  await Fluxy.init();
  
  // Register Controllers using Fluxy DI
  FluxyDI.lazyPut(() => AuthController());
  FluxyDI.lazyPut(() => HomeController());
  FluxyDI.lazyPut(() => JournalController());

  runApp(Fluxy.debug(child: const EliteTravelApp()));
}

class EliteTravelApp extends StatelessWidget {
  const EliteTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Elite Travel',
      routes: AppRoutes.routes,
      initialRoute: '/splash',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          primary: const Color(0xFF6366F1),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyLarge: TextStyle(color: Color(0xFF1E293B)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
      ),
      home: const FluxyErrorBoundary(child: SplashScreen()),
    );
  }
}
