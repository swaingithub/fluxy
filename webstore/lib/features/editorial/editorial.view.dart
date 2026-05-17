import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'editorial.controller.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';

class EditorialView extends StatelessWidget {
  const EditorialView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Fluxy.find<EditorialController>();

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
                  Fx.text('EDITORIAL').tw('text-5xl font-extrabold text-slate-900 tracking-tight'),
                  Fx.gap(16),
                  Fx.text('Stories, techniques, and thought leadership from the frontend.').tw('text-xl text-slate-500'),
                ]
              ).tw('px-8'),
              Fx.gap(64),
              
              Fx(() {
                if (!controller.isLoaded.value) return Fx.center(child: const CircularProgressIndicator());
                return Fx.reveal(
                  interval: const Duration(milliseconds: 100),
                  children: [
                    Fx.box(
                      child: FxWeb.responsiveGrid(
                        context: context,
                        desktopColumns: 3,
                        tabletColumns: 2,
                        spacing: 32,
                        runSpacing: 48,
                        children: controller.articles.value.map((a) => _buildArticle(a)).toList(),
                      )
                    ).tw('px-8')
                  ]
                );
              }),
              Fx.gap(120),
              const WebFooter(),
            ]
          )
        )
      )
    );
  }

  Widget _buildArticle(Map a) {
    return Fx.box(
      style: const FxStyle(
        margin: EdgeInsets.only(bottom: 64),
        cursor: SystemMouseCursors.click,
        transition: Duration(milliseconds: 300),
        hover: FxStyle(transformScale: 1.02),
      ),
      child: Fx.col(
        alignItems: CrossAxisAlignment.start,
        children: [
           Fx.image(a['image'], height: 400, width: double.infinity, fit: BoxFit.cover, radius: 24),
           Fx.gap(32),
           Fx.row(
             children: [
                Fx.text(a['author']).tw('text-sm font-bold text-blue-600 uppercase tracking-widest'),
                Fx.gap(16),
                Fx.text('•').tw('text-sm text-slate-300'),
                Fx.gap(16),
                Fx.text(a['date']).tw('text-sm font-medium text-slate-500'),
             ]
           ),
           Fx.gap(16),
           Fx.text(a['title']).tw('text-4xl font-extrabold text-slate-900 tracking-tight'),
           Fx.gap(16),
           Fx.text(a['excerpt']).tw('text-lg text-slate-600 leading-relaxed max-w-[800px]'), // if max-w fails we are safe because of overall container
        ]
      )
    );
  }
}
