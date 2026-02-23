import 'package:fluxy/fluxy.dart';

class ProfileRepository extends FluxRepository<bool> {
  @override
  Future<bool> fetchRemote() async {
    // Simulate auth check
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }

  Future<void> login(String email, String password) async {
    // Zero-dependency FluxyHttp!
    await Fluxy.http.post('/auth/login', body: {'email': email, 'password': password});
  }

  @override
  Future<bool> fetchLocal() async => false;
  @override
  Future<void> saveLocal(bool data) async {}
}
