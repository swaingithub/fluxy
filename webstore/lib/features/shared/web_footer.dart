import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: const FxStyle(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 120),
      ),
      child: Builder(
        builder: (context) {
          final isMobile = Fx.isMobile(context);
          return Fx.col(
            children: [
              Fx.box(
                style: FxStyle(padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 80)),
                child: isMobile ? _buildMobileGrid() : _buildDesktopGrid(),
              ),
              Fx.gap(120),
              // Massive Monolithic Branding
              Fx.text('FLUXY STUDIO').tw(isMobile 
                  ? 'text-6xl font-black text-white tracking-tighter w-full text-center px-8'
                  : 'text-9xl font-black text-white tracking-tighter w-full text-center'),
              Fx.gap(isMobile ? 40 : 80),
              // Separator Line
              Fx.box(style: const FxStyle(height: 1, backgroundColor: Color(0xFF333333))),
              Fx.gap(isMobile ? 32 : 48),
              // Legal / Bottom Bar
              Fx.box(
                style: FxStyle(padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 80)),
                child: isMobile
                    ? Fx.col(
                        children: [
                          Fx.text('© 2026 Fluxy Framework. All Rights Reserved.').tw('text-slate-500 text-sm mb-4'),
                          Fx.row(
                            gap: 24,
                            children: [
                               Fx.box(
                                 onTap: () => FluxyRouter.to('/about'),
                                 style: const FxStyle(cursor: SystemMouseCursors.click),
                                 child: Fx.text('About').tw('text-sm text-slate-400 hover:text-white cursor-pointer'),
                               ),
                               Fx.text('Privacy Policy').tw('text-sm text-slate-400 hover:text-white cursor-pointer'),
                               Fx.text('Terms of Service').tw('text-sm text-slate-400 hover:text-white cursor-pointer'),
                            ]
                          )
                        ]
                      )
                    : Fx.row(
                        justify: MainAxisAlignment.spaceBetween,
                        children: [
                          Fx.text('© 2026 Fluxy Framework. All Rights Reserved. Engineered for Performance.').tw('text-slate-500 text-sm'),
                          Fx.row(
                            gap: 32,
                            children: [
                               Fx.box(
                                 onTap: () => FluxyRouter.to('/about'),
                                 style: const FxStyle(cursor: SystemMouseCursors.click),
                                 child: Fx.text('About').tw('text-sm text-slate-400 hover:text-white cursor-pointer transition-colors duration-200'),
                               ),
                               Fx.text('Privacy Policy').tw('text-sm text-slate-400 hover:text-white cursor-pointer transition-colors duration-200'),
                               Fx.text('Terms of Service').tw('text-sm text-slate-400 hover:text-white cursor-pointer transition-colors duration-200'),
                               Fx.icon(Icons.language, color: const Color(0xFF94A3B8), size: 20),
                            ]
                          )
                        ]
                      ),
              )
            ]
          );
        }
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return Fx.row(
      alignItems: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildNewsletterForm(),
        ),
        Fx.gap(120),
        Expanded(
          flex: 2,
          child: _footerColumn('Shop', ['New Arrivals', 'Essentials', 'Accessories', 'Gift Cards']),
        ),
        Expanded(
          flex: 2,
          child: _footerColumn('Support', ['FAQ', 'Shipping Information', 'Returns Policy', 'Contact Us']),
        ),
        Expanded(
          flex: 2,
          child: _footerColumn('Company', ['About', 'Journal', 'Careers', 'Sustainability']),
        ),
      ]
    );
  }

  Widget _buildMobileGrid() {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        _buildNewsletterForm(),
        Fx.gap(80),
        _footerColumn('Shop', ['New Arrivals', 'Essentials', 'Accessories', 'Gift Cards']),
        Fx.gap(48),
        _footerColumn('Support', ['FAQ', 'Shipping Information', 'Returns Policy', 'Contact Us']),
        Fx.gap(48),
        _footerColumn('Company', ['About', 'Journal', 'Careers', 'Sustainability']),
      ]
    );
  }

  Widget _buildNewsletterForm() {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.text('JOIN THE ARCHIVE.').tw('text-2xl font-black text-white tracking-widest'),
        Fx.gap(24),
        Fx.text('Sign up for exclusive drops, architectural framework insights, and elite aesthetica updates.').tw('text-slate-400 leading-relaxed text-base'),
        Fx.gap(40),
        Fx.box(
          style: const FxStyle(
            border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
            padding: EdgeInsets.only(bottom: 12),
          ),
          child: Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Fx.text('Email Address...').tw('text-slate-500 font-medium text-lg'),
              ),
              Fx.text('SUBSCRIBE →').tw('text-white font-bold tracking-widest cursor-pointer'),
            ]
          ),
        )
      ]
    );
  }

  Widget _footerColumn(String title, List<String> links) {
    return Fx.col(
      alignItems: CrossAxisAlignment.start,
      children: [
        Fx.text(title).tw('text-white font-bold text-lg mb-8 tracking-widest uppercase'),
        ...links.map((link) => Fx.box(
          onTap: () {
            if (link.toLowerCase() == 'about') {
              FluxyRouter.to('/about');
            } else if (link.toLowerCase() == 'journal') {
              FluxyRouter.to('/journal');
            }
          },
          style: const FxStyle(
             cursor: SystemMouseCursors.click,
             margin: EdgeInsets.only(bottom: 24),
          ),
          child: Fx.text(link).tw('text-slate-400 font-medium text-base hover:text-white transition-colors duration-200')
        ))
      ],
    );
  }
}
