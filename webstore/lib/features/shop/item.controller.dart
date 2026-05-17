import 'package:fluxy/fluxy.dart';
import '../home/home.controller.dart';

class ItemController extends FluxController {
  final isLoading = flux(true);
  final product = flux<Map<String, dynamic>?>(null);
  final selectedSize = flux<String>('M');

  void loadItem(String targetId) async {
    if (product.value != null && product.value!['id'] == targetId) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final homeCtrl = Fluxy.find<HomeController>();
    try {
      product.value = homeCtrl.products.value.firstWhere((p) => p['id'] == targetId);
    } catch (_) {
      product.value = null; // 404
    }
    
    isLoading.value = false;
  }

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void addToCart() {
    if (product.value != null) {
      final homeCtrl = Fluxy.find<HomeController>();
      final cartItem = Map<String, dynamic>.from(product.value!);
      cartItem['selectedSize'] = selectedSize.value;
      homeCtrl.addToCart(cartItem);
      homeCtrl.isCartOpen.value = true; // Auto-open cart!
    }
  }
}
