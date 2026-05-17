import 'package:fluxy/fluxy.dart';
import 'journal.controller.dart';
import 'journal.view.dart';

final journalRoutes = [
  FxRoute(
    path: '/journal',
    builder: (params, args) => const JournalView(),
    transition: FxTransition.fade,
    controller: () => JournalController(),
  ),
];
