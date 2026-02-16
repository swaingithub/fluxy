import 'package:fluxy/fluxy.dart';

class NewsRepository extends FluxRepository<List<String>> {
  @override
  Future<List<String>> fetchRemote() async {
    final response = await Fluxy.http.get('/posts');
    return List<String>.from(response.data.map((e) => e['title']));
  }

  @override
  Future<List<String>> fetchLocal() async => [];
  @override
  Future<void> saveLocal(List<String> data) async {}
}
