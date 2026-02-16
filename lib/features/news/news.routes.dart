import 'package:fluxy/fluxy.dart';
import 'news.view.dart';
import 'news.controller.dart';

final newsRoutes = [
  FxRoute(
    path: '/news',
    controller: () => NewsController(),
    builder: (params, args) => const NewsView(),
  ),
];
