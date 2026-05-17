import 'package:fluxy/fluxy.dart';
import 'editorial.controller.dart';
import 'editorial.view.dart';

final editorialRoutes = [
  FxRoute(
    path: '/editorial',
    builder: (params, args) => const EditorialView(),
    transition: FxTransition.fade,
    controller: () => EditorialController(),
  ),
];
