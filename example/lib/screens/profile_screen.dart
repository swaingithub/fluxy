import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Fx.column(
          gap: 32,
          children: [
            // Avatar Section
            Fx.column(
              gap: 16,
              children: [
                Fx.box(
                  style: const FxStyle(
                    width: 120,
                    height: 120,
                    backgroundColor: Colors.indigo,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    alignment: Alignment.center,
                    border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 4)),
                  ),
                  child: Fx.text("JD").font(40).bold().color(Colors.white),
                ),
                Fx.column(
                  gap: 4,
                  children: [
                    Fx.text("Jane Doe").font(24).bold().center(),
                    Fx.text("Full-stack Fluxy Developer").color(Colors.grey).center(),
                  ],
                ),
              ],
            ).center(),

            // Stats
            Fx.row(
              gap: 24,
              children: [
                _buildStat("Projects", "24"),
                _buildStat("Followers", "1.2k"),
                _buildStat("Rating", "4.9"),
              ],
            ).center(),

            // Actions
            Fx.column(
              gap: 12,
              children: [
                _buildAction("Edit Profile", Icons.edit, Colors.blue),
                _buildAction("Security Settings", Icons.security, Colors.green),
                _buildAction("Subscription Plan", Icons.credit_card, Colors.orange),
                _buildAction("Support & Feedback", Icons.help_outline, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Fx.column(
      children: [
        Fx.text(value).font(20).bold(),
        Fx.text(label).font(12).color(Colors.grey),
      ],
    );
  }

  Widget _buildAction(String label, IconData icon, Color color) {
    return Fx.row(
      gap: 16,
      children: [
        Fx.box().size(40, 40).bg(color.withOpacity(0.1)).radius(10).center()
          .copyWith(child: Icon(icon, color: color, size: 20)),
        Fx.text(label).expanded().font(16).weight(FontWeight.w500),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    ).pad(12).radius(12).bg(Colors.blueGrey.withOpacity(0.05)).pointer();
  }
}
