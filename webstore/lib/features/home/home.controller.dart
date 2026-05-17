import 'package:fluxy/fluxy.dart';
import 'home.repository.dart';

class HomeController extends FluxController {
  final repo = HomeRepository();
  
  // E-commerce state
  final isCartOpen = flux(false);
  final isMobileMenuOpen = flux(false);
  final cartItems = flux(<Map<String, dynamic>>[]);
  final products = flux(<Map<String, dynamic>>[]);
  final isLoading = flux(true);

  @override
  void onInit() async {
    super.onInit();
    // Dummy products data
    products.value = [
      {
        'id': '1',
        'name': 'Fluxy Premium Tee',
        'price': 49.99,
        'image': 'https://plus.unsplash.com/premium_photo-1673356302067-aac3b545a362?q=80&w=600&auto=format&fit=crop',
        'category': 'Apparel'
      },
      {
        'id': '2',
        'name': 'Architectural Mug',
        'price': 19.99,
        'image': 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?q=80&w=600&auto=format&fit=crop',
        'category': 'Accessories'
      },
      {
        'id': '3',
        'name': 'Nomad Backpack',
        'price': 129.50,
        'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=600&auto=format&fit=crop',
        'category': 'Gear'
      },
      {
        'id': '4',
        'name': 'Developer Mechanical Keyboard',
        'price': 189.00,
        'image': 'https://images.unsplash.com/photo-1595225476474-87563907a212?q=80&w=600&auto=format&fit=crop',
        'category': 'Electronics'
      },
    ];
    isLoading.value = false;
  }
  
  void addToCart(Map<String, dynamic> product) {
    cartItems.value = [...cartItems.value, product];
    Fx.toast.success('${product['name']} added to cart');
  }

  void toggleCart() {
    isCartOpen.value = !isCartOpen.value;
  }

  void toggleMobileMenu() {
    isMobileMenuOpen.value = !isMobileMenuOpen.value;
  }
}
