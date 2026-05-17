import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'journal.controller.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<JournalController>();
    return WebLayout(
      child: Fx.scroll(
        child: FxWeb.container(
          maxWidth: 1200,
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.gap(140),
              Fx.reveal(
                children: [
                  Fx.text('JOURNAL').tw('text-5xl font-extrabold text-slate-900 tracking-tight'),
                  Fx.gap(16),
                  Fx.text('Daily insights on design systems and interface perfection.').tw('text-xl text-slate-500'),
                ]
              ).tw('px-8'),
              Fx(() {
                if (!controller.isLoaded.value) return Fx.center(child: const CircularProgressIndicator());
                return Fx.reveal(
                  interval: const Duration(milliseconds: 100),
                  children: controller.entries.value.map((e) => _buildEntry(e)).toList(),
                ).tw('px-8');
              }),
              Fx.gap(120),
              const WebFooter(),
            ]
          )
        )
      )
    );
  }

  Widget _buildEntry(Map a) {
    return Fx.box(
      style: FxStyle(
        margin: const EdgeInsets.only(bottom: 48),
        padding: const EdgeInsets.all(32),
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(24),
        shadows: FxTokens.shadow.sm,
        cursor: SystemMouseCursors.click,
        transition: const Duration(milliseconds: 300),
        hover: FxStyle(transformScale: 1.02, shadows: FxTokens.shadow.lg),
      ),
      child: Fx.col(
        alignItems: CrossAxisAlignment.start,
        children: [
           Fx.text(a['date']).tw('text-sm font-bold text-slate-400 uppercase tracking-widest'),
           Fx.gap(16),
           Fx.text(a['title']).tw('text-3xl font-bold text-slate-900 tracking-tight'),
           Fx.gap(16),
           Fx.text(a['snippet']).tw('text-lg text-slate-600 leading-relaxed max-w-[1000px]'),
           Fx.gap(24),
           Fx.text('Read Entry →').tw('text-blue-600 font-bold text-sm'),
        ]
      )
    );
  }
}
