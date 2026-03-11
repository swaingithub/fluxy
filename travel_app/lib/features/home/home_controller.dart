import 'package:fluxy/fluxy.dart';
import '../../core/app_data.dart' as data;

class HomeController extends FluxController {
  final selectedCategory = flux('All');
  final searchQuery = flux('');
  final navIndex = flux(0);

  List<Map<String, dynamic>> get filteredDestinations {
    return data.destinations.where((d) {
      final catMatch = selectedCategory.value == 'All' || d['category'] == selectedCategory.value;
      final searchMatch = d['title'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());
      return catMatch && searchMatch;
    }).toList();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }

  void setNavIndex(int index) {
    navIndex.value = index;
  }
}
