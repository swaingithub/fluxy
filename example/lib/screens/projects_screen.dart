import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Projects")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Fx.column(
        children: [
          // Filter Chips
          Fx.row(
            gap: 12,
            children: [
              _buildChip("All", active: true),
              _buildChip("Active"),
              _buildChip("Completed"),
              _buildChip("Archived"),
            ],
          ).padX(24).padY(16),

          // Project List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: 10,
              separatorBuilder: (_, __) => Fx.gap(16),
              itemBuilder: (context, index) => _buildProjectCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool active = false}) {
    return Fx.box(
      className: "px-4 py-2 rounded-full",
      style: FxStyle(
        backgroundColor: active ? Colors.blue : Colors.blue.withOpacity(0.1),
      ),
      child: Fx.text(label).color(active ? Colors.white : Colors.blue).font(14).bold(),
    ).pointer();
  }

  Widget _buildProjectCard(int index) {
    return Fx.card(
      child: Fx.column(
        gap: 12,
        children: [
          Fx.row(
            children: [
              Fx.text("Project Alpha ${index + 1}").font(18).bold().expanded(),
              Fx.box().padOnly(left: 8, right: 8, top: 4, bottom: 4).bg(Colors.green.withOpacity(0.1)).radius(4)
                .child(Fx.text("V-1.2").color(Colors.green).font(10).bold()),
            ],
          ),
          Fx.text("A distributed reactive system built with Fluxy Framework and Dart signals.").color(Colors.grey).maxLines(2),
          Fx.row(
            gap: 16,
            children: [
              _buildTag("Reactive", Colors.purple),
              _buildTag("Flutter", Colors.blue),
              const Spacer(),
              Fx.text("2h ago").font(12).color(Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Fx.row(
      gap: 4,
      children: [
        Fx.box().size(8, 8).bg(color).radius(4),
        Fx.text(label).font(12).color(color.withOpacity(0.8)),
      ],
    );
  }
}
