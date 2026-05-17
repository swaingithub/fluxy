import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import '../shared/web_layout.dart';
import '../shared/web_footer.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      child: Fx.scroll(
        child: FxWeb.container(
          maxWidth: 1200,
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.gap(120), // Spacing for navbar
              Fx.reveal(
                children: [
                  _buildHeroSection(context),
                  Fx.gap(100),
                  _buildStorySection(context),
                  Fx.gap(100),
                  _buildValuesSection(context),
                  Fx.gap(120),
                ],
              ),
              const WebFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = Fx.isMobile(context);
    return Fx.col(
      alignItems: CrossAxisAlignment.center,
      children: [
        Fx.text('OUR STORY').tw('text-blue-600 font-bold tracking-widest text-sm mb-6'),
        Fx.text('Crafting the Future of Web').tw(isMobile 
            ? 'text-5xl font-extrabold text-slate-900 text-center leading-tight tracking-tight' 
            : 'text-7xl font-extrabold text-slate-900 text-center leading-tight tracking-tight'),
        Fx.gap(32),
        FxWeb.container(
          maxWidth: 800,
          child: Fx.text('Fluxy Studio is a creative collective focused on building high-performance, minimalist digital experiences. We believe that speed and beauty should never be a trade-off.')
              .tw('text-xl text-slate-500 text-center leading-relaxed'),
        ),
      ],
    ).tw('px-8 w-full');
  }

  Widget _buildStorySection(BuildContext context) {
    final isMobile = Fx.isMobile(context);
    return Fx.row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isMobile) ...[
          Expanded(
            child: Fx.box(
              style: const FxStyle(
                shadows: [BoxShadow(color: Color(0x20000000), blurRadius: 40, offset: Offset(0, 20))],
              ),
              child: Fx.image(
                'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1200&auto=format&fit=crop',
                height: 500,
                fit: BoxFit.cover,
                radius: 32,
              ),
            ),
          ),
          Fx.gap(80),
        ],
        Expanded(
          child: Fx.col(
            alignItems: CrossAxisAlignment.start,
            children: [
              Fx.text('Founded in 2024.').tw('text-3xl font-bold text-slate-900 mb-6'),
              Fx.text('Started as a small experiment in declarative UI, Fluxy has evolved into a robust framework powering the next generation of aesthetic web applications. Our mission is to empower developers to build without constraints.')
                  .tw('text-lg text-slate-600 leading-relaxed mb-8'),
              Fx.row(
                children: [
                   _buildStat('200+', 'Projects Built'),
                   Fx.gap(40),
                   _buildStat('15k+', 'Community'),
                ],
              )
            ],
          ),
        ),
      ],
    ).tw('px-8');
  }

  Widget _buildStat(String value, String label) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.text(value).tw('text-3xl font-black text-blue-600'),
        Fx.text(label).tw('text-sm font-bold text-slate-400 tracking-wide uppercase'),
      ],
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final isMobile = Fx.isMobile(context);
    return Fx.col(
      children: [
        Fx.text('CORE PHILOSOPHY').tw('text-center text-blue-600 font-bold tracking-widest text-sm mb-12'),
        isMobile 
            ? Fx.col(children: _buildValues()) 
            : Fx.row(
                justify: MainAxisAlignment.center,
                gap: 32,
                children: _buildValues().map((e) => Expanded(child: e)).toList(),
              ),
      ],
    ).tw('px-8');
  }

  List<Widget> _buildValues() {
    return [
      _valueCard(Icons.bolt, 'Performance First', 'Every millisecond counts. We optimize for speed at every layer of the stack.'),
      _valueCard(Icons.auto_awesome, 'Aesthetic Integrity', 'Design is not just how it looks, but how it works and feels.'),
      _valueCard(Icons.extension, 'Modular Design', 'Build with components that are reusable, scalable, and easy to maintain.'),
    ];
  }

  Widget _valueCard(IconData icon, String title, String description) {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(40),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        shadows: FxTokens.shadow.sm,
      ),
      child: Fx.col(
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.box(
            style: FxStyle(
              backgroundColor: const Color(0xFFEFF6FF),
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Fx.icon(icon, color: Colors.blueAccent, size: 28),
          ),
          Fx.gap(24),
          Fx.text(title).tw('text-xl font-bold text-slate-900 mb-4'),
          Fx.text(description).tw('text-slate-500 leading-relaxed'),
        ],
      ),
    );
  }
}
