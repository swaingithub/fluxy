import 'package:fluxy/fluxy.dart';
import 'news.repository.dart';

class NewsController extends FluxController {
  final repo = NewsRepository();
  final items = flux(<String>[]);
  final isLoading = flux(true);

  @override
  void onInit() async {
    super.onInit();
    await refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    items.value = await repo.sync();
    isLoading.value = false;
  }
}
