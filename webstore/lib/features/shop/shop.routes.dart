import 'package:fluxy/fluxy.dart';
import 'shop.controller.dart';
import 'shop.view.dart';
import 'item.controller.dart';
import 'item.view.dart';

final shopRoutes = [
  FxRoute(
    path: '/shop',
    builder: (params, args) => const ShopView(),
    transition: FxTransition.fade,
    controller: () => ShopController(),
  ),
  FxRoute(
    path: '/shop/:id',
    builder: (params, args) => ItemView(itemId: params['id'] ?? '1'),
    transition: FxTransition.fade,
    controller: () => ItemController(),
  ),
];
