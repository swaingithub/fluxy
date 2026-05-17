import 'package:fluxy/fluxy.dart';

class HomeRepository extends FluxRepository<String> {
  @override
  Future<String> fetchRemote() async {
    final response = await Fluxy.http.get('/data');
    return response.data['message'] ?? "Fluxy Engine Active";
  }

  @override
  Future<String> fetchLocal() async => "Offline Cache Ready";
  
  @override
  Future<void> saveLocal(String data) async {}
}
