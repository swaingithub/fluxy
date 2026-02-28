import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxy/fluxy.dart';

/// Core authentication plugin for Fluxy with secure persistence.
class FluxyAuthPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_auth';

  @override
  List<String> get permissions => ['network', 'storage'];

  final _storage = const FlutterSecureStorage();
  final isAuthenticated = flux(false);
  final user = flux<Map<String, dynamic>?>(null);

  @override
  FutureOr<void> onRegister() async {
    debugPrint('[AUTH] [INIT] Initializing and checking persistence...');
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      isAuthenticated.value = true;
      // In a real app, you would fetch the user profile here
      user.value = {'email': 'persisted@user.com', 'name': 'Fluxy User'};
      debugPrint('[AUTH] [PERSISTENCE] Session restored.');
    }
  }

  Future<bool> login(String email, String password) async {
    debugPrint('[AUTH] [LOGIN] Attempting login for $email...');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you'd get a token from your API
    const token = 'fake_secure_jwt_token';
    await _storage.write(key: 'auth_token', value: token);
    
    isAuthenticated.value = true;
    user.value = {'email': email, 'name': 'Fluxy User'};
    return true;
  }

  Future<void> logout() async {
    debugPrint('[AUTH] [LOGOUT] Terminating session...');
    await _storage.delete(key: 'auth_token');
    isAuthenticated.value = false;
    user.value = null;
  }
}
