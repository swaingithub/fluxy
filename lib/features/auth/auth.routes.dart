import 'package:fluxy/fluxy.dart';
import 'auth.view.dart';
import 'auth.controller.dart';

final authRoutes = [
  FxRoute(
    path: '/auth',
    controller: () => AuthController(),
    builder: (params, args) => const AuthView(),
  ),
];
