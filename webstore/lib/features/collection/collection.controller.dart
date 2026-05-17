import 'package:fluxy/fluxy.dart';

class CollectionController extends FluxController {
  final isLoaded = flux(false);
  final collections = flux(<Map<String, dynamic>>[]);

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(milliseconds: 400));
    collections.value = [
      {'name': 'Summer Framework Edit', 'tag': '01', 'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=1200&auto=format&fit=crop'},
      {'name': 'Winter Productivity', 'tag': '02', 'image': 'https://plus.unsplash.com/premium_photo-1673356302067-aac3b545a362?q=80&w=1200&auto=format&fit=crop'}
    ];
    isLoaded.value = true;
  }
}
