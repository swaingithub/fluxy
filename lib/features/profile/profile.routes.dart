import 'package:fluxy/fluxy.dart';
import 'profile.view.dart';
import 'profile.controller.dart';

final profileRoutes = [
  FxRoute(
    path: '/profile',
    controller: () => ProfileController(),
    builder: (params, args) => const ProfileView(),
  ),
];
