import 'package:fluxy/fluxy.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/details/details_page.dart';
import '../features/saved/saved_page.dart';
import '../features/tickets/tickets_page.dart';
import '../features/profile/profile_page.dart';
import '../features/journal/journal_page.dart';

class AppRoutes {
  static final routes = [
    FxRoute(path: '/splash', builder: (p, a) => const SplashScreen()),
    FxRoute(path: '/login', builder: (p, a) => const LoginScreen()),
    FxRoute(path: '/home', builder: (p, a) => const TravelMainNavigation()),
    FxRoute(path: '/details', builder: (p, a) => DestinationDetailsPage(data: a as Map<String, dynamic>)),
    FxRoute(path: '/saved', builder: (p, a) => const SavedPage()),
    FxRoute(path: '/tickets', builder: (p, a) => const TicketsPage()),
    FxRoute(path: '/profile', builder: (p, a) => const ProfilePage()),
    FxRoute(path: '/journal', builder: (p, a) => const JournalPage()),
  ];
}
