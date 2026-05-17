import 'package:fluxy/fluxy.dart';
import 'home.view.dart';
import 'home.controller.dart';

final homeRoutes = [
  FxRoute(
    path: '/home',
    controller: () => HomeController(),
    builder: (params, args) => const HomeView(),
  ),
];
