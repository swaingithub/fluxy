import 'package:fluxy/fluxy.dart';

class JournalEntry {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String content;
  final List<String> images;
  final double rating;

  JournalEntry({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.content,
    required this.images,
    required this.rating,
  });
}

class JournalController extends FluxController {
  final entries = flux<List<JournalEntry>>([
    JournalEntry(
      id: '1',
      title: 'Majestic Bali Mornings',
      location: 'Ubud, Bali',
      date: DateTime.now().subtract(const Duration(days: 5)),
      content: 'The sunrise over the rice terraces was absolutely breathtaking. I spent the morning meditation and enjoy nature.',
      images: ['https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=400&q=80'],
      rating: 5.0,
    ),
    JournalEntry(
      id: '2',
      title: 'Swiss Alps Hiking',
      location: 'Zermatt, Switzerland',
      date: DateTime.now().subtract(const Duration(days: 12)),
      content: 'Challenging hike but the view of the Matterhorn made it all worth it. The air is so fresh here.',
      images: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=400&q=80'],
      rating: 4.5,
    ),
  ]);

  void addEntry(JournalEntry entry) {
    entries.value = [...entries.value, entry];
  }

  void removeEntry(String id) {
    entries.value = entries.value.where((e) => e.id != id).toList();
  }
}
