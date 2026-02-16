import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'auth.controller.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<AuthController>();

    return Scaffold(
      body: Fx.center(
        child: Fx.container(
          maxWidth: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Fx.text('LOGIN').font.h1().bold(),
              Fx.text('Enter your credentials').muted(),
              Fx.gap(40),
              
              Fx.input(
                signal: controller.email, 
                placeholder: 'Email',
                icon: Icons.email_outlined,
              ),
              Fx.gap(16),
              Fx.password(
                signal: controller.password,
                placeholder: 'Password',
              ),
              Fx.gap(24),
              
              Fx(() => Fx.button(
                controller.isLoading.value ? 'PROCESSING...' : 'SIGN IN',
                onTap: controller.submit,
              ).w(double.infinity).background(Colors.black)),
              
              Fx.gap(16),
              Fx.textButton('Forgot Password?', onTap: () {}),
            ],
          ).p(24),
        ),
      ),
    );
  }
}
