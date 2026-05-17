import 'package:fluxy/fluxy.dart';

class EditorialController extends FluxController {
  final isLoaded = flux(false);
  final articles = flux(<Map<String, dynamic>>[]);

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(milliseconds: 500));
    articles.value = [
      {
        'id': '1', 
        'title': 'The Era of Spatial Computing in Web', 
        'author': 'Design Team',
        'date': 'Oct 12, 2026',
        'excerpt': 'As 3D interfaces merge with standard web DOM, developers are tasked with balancing aesthetics, performance, and accessibility in unprecedented ways.',
        'image': 'https://images.unsplash.com/photo-1616423640778-28d1b53229bd?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'id': '2', 
        'title': 'Redefining Digital Minimalism with Fluxy', 
        'author': 'Engineering',
        'date': 'Sep 28, 2026',
        'excerpt': 'We break down the mathematical design tokens that power Fluxy\'s auto-scaling metrics to build apps that simply look better right out of the box.',
        'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=1200&auto=format&fit=crop'
      },
    ];
    isLoaded.value = true;
  }
}
