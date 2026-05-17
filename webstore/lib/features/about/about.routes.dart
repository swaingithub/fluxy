import 'package:fluxy/fluxy.dart';
import 'about.view.dart';
import 'about.controller.dart';

final aboutRoutes = [
  FxRoute(
    path: '/about',
    controller: () => AboutController(),
    builder: (params, args) => const AboutView(),
  ),
];
