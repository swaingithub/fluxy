import 'dart:async';
import 'package:flutter/foundation.dart';
import '../engine/plugin.dart';
import '../reactive/signal.dart';

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
    debugPrint('🔐 [FluxyAuth] Initializing...');
  }

  Future<bool> login(String email, String password) async {
    debugPrint('🔐 [FluxyAuth] Logging in $email...');
    await Future.delayed(const Duration(seconds: 1));
    isAuthenticated.value = true;
    user.value = {'email': email, 'name': 'Fluxy User'};
    return true;
  }

  void logout() {
    debugPrint('🔐 [FluxyAuth] Logging out...');
    isAuthenticated.value = false;
    user.value = null;
  }
}
