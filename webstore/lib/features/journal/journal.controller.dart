import 'package:fluxy/fluxy.dart';

class JournalController extends FluxController {
  final isLoaded = flux(false);
  final entries = flux(<Map<String, String>>[]);

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(milliseconds: 300));
    entries.value = [
      {'date': 'March 19, 2026', 'title': 'The Framework Philosophy', 'snippet': 'Why do we build what we build? It\'s not about the code, it\'s about the aesthetic feeling of delivering perfection without boilerplate.'},
      {'date': 'February 04, 2026', 'title': 'Design Iterations: Version 2', 'snippet': 'A glimpse into the internal discussions that led to swapping out explicit margins for comprehensive spacing scales inside layout primitives.'},
    ];
    isLoaded.value = true;
  }
}
