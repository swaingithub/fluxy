import 'package:fluxy/fluxy.dart';

class ShopController extends FluxController {
  final isLoaded = flux(false);
  final categories = flux(<String>[]);
  final products = flux(<Map<String, dynamic>>[]);
  final currentTabIndex = flux(0); // Track active tab

  /// Returns the filtered list of products based on the selected tab
  List<Map<String, dynamic>> get filteredProducts {
    final selectedCat = categories.value[currentTabIndex.value];
    if (selectedCat == 'All') return products.value;
    return products.value.where((p) => p['category'] == selectedCat).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    // Network delay simulation
    await Future.delayed(const Duration(milliseconds: 600));
    categories.value = ['All', 'Apparel', 'Accessories', 'Developer Gear'];
    products.value = [
      {'id': '1', 'name': 'Fluxy Premium Tee', 'price': 49.99, 'image': 'https://plus.unsplash.com/premium_photo-1673356302067-aac3b545a362?q=80&w=600&auto=format&fit=crop', 'category': 'Apparel'},
      {'id': '2', 'name': 'Architectural Mug', 'price': 19.99, 'image': 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?q=80&w=600&auto=format&fit=crop', 'category': 'Accessories'},
      {'id': '3', 'name': 'Nomad Backpack', 'price': 129.50, 'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=600&auto=format&fit=crop', 'category': 'Developer Gear'},
      {'id': '4', 'name': 'Mechanical Keycaps', 'price': 89.00, 'image': 'https://images.unsplash.com/photo-1595225476474-87563907a212?q=80&w=600&auto=format&fit=crop', 'category': 'Developer Gear'},
      {'id': '5', 'name': 'Ergonomic Desk Mat', 'price': 34.00, 'image': 'https://images.unsplash.com/photo-1616423640778-28d1b53229bd?q=80&w=600&auto=format&fit=crop', 'category': 'Accessories'},
      {'id': '6', 'name': 'Noise Cancelling Headphones', 'price': 299.99, 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop', 'category': 'Developer Gear'},
    ];
    isLoaded.value = true;
  }
}
