import 'package:fluxy/fluxy.dart';

class AuthController extends FluxController {
  final email = flux('');
  final password = flux('');
  final isLoggingIn = flux(false);


  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Fx.toast.info('Please fill in all fields');
      return;
    }

    isLoggingIn.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    isLoggingIn.value = false;
    Fx.to('/home');
    Fx.toast.success('Welcome back, adventurer!');
  }

  void reset() {
    email.value = '';
    password.value = '';
    isLoggingIn.value = false;
  }
}
