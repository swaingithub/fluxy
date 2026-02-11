import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fx.box(
        style: const FxStyle(
          width: double.infinity,
          height: double.infinity,
          backgroundColor: Color(0xFF0F172A),
        ),
        child: Fx.column(
          gap: 32,
          children: [
            // Logo area
            Fx.box(
              style: const FxStyle(
                width: 80,
                height: 80,
                backgroundColor: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                alignment: Alignment.center,
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 40),
            ),

            // Form
            Fx.container(
              className: "w-full max-w-md",
              child: Fx.column(
                gap: 24,
                children: [
                  Fx.column(
                    gap: 8,
                    children: [
                      Fx.text("Welcome to Fluxy").font(28).bold().center(),
                      Fx.text("Enter your credentials to continue").color(Colors.grey).center(),
                    ],
                  ),

                  Fx.column(
                    gap: 16,
                    children: [
                      _buildField("Email Address", Icons.email),
                      _buildField("Password", Icons.lock, isPassword: true),
                    ],
                  ),

                  Fx.button(
                    onTap: () => Fx.go('/dashboard'),
                    child: "Sign In",
                  ).width(double.infinity),

                  Fx.row(
                    className: "justify-center gap-2",
                    children: [
                      Fx.text("Don't have an account?").color(Colors.grey),
                      Fx.text("Create one").color(Colors.blue).bold().pointer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).center(),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, {bool isPassword = false}) {
    return Fx.row(
      gap: 12,
      children: [
        Icon(icon, color: Colors.white24, size: 20),
        Fx.text(hint).color(Colors.white54).expanded(),
      ],
    )
    .pad(16)
    .bg(Colors.white.withOpacity(0.05))
    .radius(12)
    .border(color: Colors.white.withOpacity(0.1));
  }
}
