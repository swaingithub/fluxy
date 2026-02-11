import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Fx.section(
            title: "App Preferences",
            children: [
              _buildToggle("Dark Mode", true),
              _buildToggle("Push Notifications", false),
              _buildToggle("Biometric Authentication", true),
            ],
          ),
          Fx.gap(32),
          Fx.section(
            title: "Developer Tools",
            children: [
              _buildLink("View Source Code", Icons.code),
              _buildLink("API Documentation", Icons.library_books),
              _buildLink("Framework Logs", Icons.terminal),
            ],
          ),
          Fx.gap(48),
          Fx.button(
            onTap: () => Fx.offAll('/login'),
            child: "Logout",
          ).bg(Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value) {
    return Fx.row(
      children: [
        Fx.text(label).expanded().font(16),
        Switch(value: value, onChanged: (_) {}),
      ],
    ).padY(8);
  }

  Widget _buildLink(String label, IconData icon) {
    return Fx.row(
      gap: 16,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        Fx.text(label).expanded().font(16),
        const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
      ],
    ).padY(12).pointer();
  }
}
