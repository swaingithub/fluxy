import 'package:fluxy/fluxy.dart';
import 'auth.repository.dart';

class AuthController extends FluxController {
  final repo = AuthRepository();
  
  final email = flux("");
  final password = flux("");
  final isLoading = flux(false);

  Future<void> submit() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Fx.toast.error("Please fill all fields");
      return;
    }

    isLoading.value = true;
    try {
      await repo.login(email.value, password.value);
      Fx.toast.success("Welcome back!");
      Fluxy.offAll('/home');
    } catch (e) {
      Fx.toast.error("Login failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
