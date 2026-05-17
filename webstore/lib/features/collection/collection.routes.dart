import 'package:fluxy/fluxy.dart';
import 'collection.controller.dart';
import 'collection.view.dart';

final collectionRoutes = [
  FxRoute(
    path: '/collection',
    builder: (params, args) => const CollectionView(),
    transition: FxTransition.fade,
    controller: () => CollectionController(),
  ),
];
