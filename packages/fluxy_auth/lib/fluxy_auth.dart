import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';

/// Core authentication plugin for Fluxy.
class FluxyAuthPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_auth';

  @override
  List<String> get permissions => ['network', 'storage'];

  final isAuthenticated = flux(false);
  final user = flux<Map<String, dynamic>?>(null);

  @override
  FutureOr<void> onRegister() {
    debugPrint('[AUTH] [INIT] Initializing...');
  }

  Future<bool> login(String email, String password) async {
    debugPrint('[AUTH] [LOGIN] Attempting login for $email...');
    await Future.delayed(const Duration(seconds: 1));
    isAuthenticated.value = true;
    user.value = {'email': email, 'name': 'Fluxy User'};
    return true;
  }

  void logout() {
    debugPrint('[AUTH] [LOGOUT] Terminating session...');
    isAuthenticated.value = false;
    user.value = null;
  }
}
