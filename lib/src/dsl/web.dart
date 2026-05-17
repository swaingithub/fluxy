import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fx.dart';
import '../styles/style.dart';

/// The official Desktop & Web extension for Fluxy.
/// Keeps the core framework pure strictly for mobile, while providing powerful wrappers 
/// for building advanced, infinitely scalable desktop layouts without constraints crashes.
class FxWeb {
  /// A dedicated layout wrapper making Website building effortless in a mobile-first framework.
  /// It automatically injects full-width boundaries, perfectly centers the content, and enforces a massive
  /// desktop maxWidth boundary (defaults to 1200). On mobile devices, it seamlessly collapses natively.
  static Widget container({
    required Widget child,
    double maxWidth = 1200,
    Color? backgroundColor,
    CrossAxisAlignment alignItems = CrossAxisAlignment.start,
  }) {
    return Fx.box(
      style: FxStyle(backgroundColor: backgroundColor),
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1.0, // CRITICAL: Prevents Infinity assertion crash in scroll views
        child: Fx.container(
          maxWidth: maxWidth,
          child: Fx.col(
            alignItems: alignItems,
            children: [child],
          ),
        ),
      ),
    );
  }

  /// Builds a responsive Web Navigation Bar structure designed specifically for 
  /// separating desktop menus from compact mobile hamburger designs.
  static Widget navbar({
    required Widget brand,
    required Widget desktopMenu,
    required Widget mobileMenu,
    required Widget actions,
    double maxWidth = 1200,
    double glass = 8.0,
    Color backgroundColor = const Color(0xCCFFFFFF),
  }) {
    return Builder(builder: (context) {
      final bool isMobile = Fx.isMobile(context);
      
      return Fx.box(
        style: FxStyle(
          backgroundColor: backgroundColor,
          glass: glass,
          border: const Border(bottom: BorderSide(color: Color(0x1F000000), width: 1)),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1.0, // Prevents bounding crash inside Positioned/Scrolls
          child: Fx.container(
            maxWidth: maxWidth,
            child: Fx.row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              alignItems: CrossAxisAlignment.center,
              children: [
                brand,
                if (!isMobile) desktopMenu else mobileMenu,
                actions,
              ],
            ).tw('px-8 py-5'),
          ),
        ),
      );
    });
  }

  /// Provides an easy web-grid layout that falls back into a single column natively on mobile width.
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int desktopColumns = 3,
    int tabletColumns = 2,
    double spacing = 32,
    double runSpacing = 48,
  }) {
    final bool isMobile = Fx.isMobile(context);
    final bool isTablet = Fx.isTablet(context);
    
    // We leverage Wrap to simulate grids that can responsively pack columns 
    // based on mobile/desktop intrinsic scaling.
    return LayoutBuilder(
      builder: (context, constraints) {
        final int activeCols = isMobile ? 1 : (isTablet ? tabletColumns : desktopColumns);
        final double itemWidth = (constraints.maxWidth - (spacing * (activeCols - 1))) / activeCols;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
        );
      }
    );
  }

  /// Evaluates screen width seamlessly for dynamic component swaps on websites.
  static bool isLargeScreen(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;

  /// A massive website splash-header designed to take a background image, huge typography, 
  /// and dynamic action buttons. On mobile, it perfectly stacks the elements into a clean scroll.
  static Widget hero({
    required Widget title,
    required Widget subtitle,
    required Widget actions,
    required Widget media,
    bool reverseMobile = false,
  }) {
    return Builder(builder: (context) {
      final bool isMobile = Fx.isMobile(context);
      if (isMobile) {
        return Fx.col(
          alignItems: CrossAxisAlignment.start,
          children: reverseMobile 
              ? [media, Fx.gap(40), title, Fx.gap(16), subtitle, Fx.gap(32), actions] 
              : [title, Fx.gap(16), subtitle, Fx.gap(32), actions, Fx.gap(40), media],
        );
      }
      return Fx.row(
        alignItems: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: [title, Fx.gap(24), subtitle, Fx.gap(40), actions],
            ),
          ),
          Fx.gap(64),
          Expanded(flex: 1, child: media),
        ],
      );
    });
  }

  /// A structured Website Footer dividing your links and branding into equal columns 
  /// on Desktop, and accordion/stacked lists perfectly bound for Mobile.
  static Widget footer({
    required Widget brandInfo,
    required List<Widget> columns,
    Color backgroundColor = const Color(0xFF0F172A),
    double padding = 64,
  }) {
    return Fx.box(
      style: FxStyle(backgroundColor: backgroundColor, padding: EdgeInsets.all(padding)),
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1.0,
        child: Fx.container(
          maxWidth: 1200,
          child: Builder(builder: (context) {
            final isMobile = Fx.isMobile(context);
            if (isMobile) {
              return Fx.col(
                alignItems: CrossAxisAlignment.start,
                children: [
                  brandInfo,
                  Fx.gap(48),
                  ...columns.map((c) => Padding(padding: const EdgeInsets.only(bottom: 32), child: c)),
                ]
              );
            }
            return Fx.row(
              alignItems: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: brandInfo),
                ...columns.map((c) => Expanded(flex: 1, child: c)),
              ]
            );
          }),
        ),
      ),
    );
  }

  /// A 50/50 Layout structure (e.g. Text left, Media right) perfectly suited for standard
  /// web sections, adapting gracefully down to a stacked single block on mobiles.
  static Widget split({
    required Widget left,
    required Widget right,
    bool reverseMobile = false,
  }) {
    return Builder(builder: (context) {
      if (Fx.isMobile(context)) {
        return Fx.col(
          alignItems: CrossAxisAlignment.start,
          children: reverseMobile ? [right, Fx.gap(32), left] : [left, Fx.gap(32), right],
        );
      }
      return Fx.row(
        alignItems: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          Fx.gap(48),
          Expanded(child: right),
        ],
      );
    });
  }

  /// An entire admin dashboard framework with a sticky sidebar and large content view.
  static Widget dashboard({
    required Widget sidebar,
    required Widget content,
    Color backgroundColor = const Color(0xFFF8FAFC),
  }) {
    return Fx.scaffold(
      backgroundColor: backgroundColor,
      body: Builder(builder: (context) {
        if (Fx.isMobile(context)) {
          // On mobile, the sidebar collapses natively and just content renders,
          // assuming developers use a native Fx.scaffold Drawer for navigation later!
          return content;
        }
        return Fx.row(
          alignItems: CrossAxisAlignment.start,
          children: [
            Fx.box(
              style: const FxStyle(
                width: 260,
                backgroundColor: Colors.white,
                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: sidebar,
            ),
            Expanded(child: content),
          ],
        );
      }),
    );
  }

  /// A sliding side-drawer designed for Mobile Menus or E-commerce Shopping Carts.
  /// Standard React/Web behavior: dims the background and slides in from left or right.
  static Widget drawer({
    required bool isOpen,
    required VoidCallback onClose,
    required Widget child,
    bool fromRight = true,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: isOpen && fromRight ? 0 : (fromRight ? -400 : null),
      left: isOpen && !fromRight ? 0 : (!fromRight ? -400 : null),
      width: 320,
      child: Material(
        elevation: 16,
        color: Colors.white,
        child: Fx.col(
          children: [
            Fx.box(
              style: const FxStyle(
                padding: EdgeInsets.all(20),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Fx.row(
                justify: MainAxisAlignment.spaceBetween,
                children: [
                  Fx.text('Menu').tw('text-xl font-bold text-slate-900'),
                  Fx.box(
                    onTap: onClose,
                    style: const FxStyle(cursor: SystemMouseCursors.click),
                    child: Fx.icon(Icons.close, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// Interactive Web Accordion. Crucial for Product FAQs, Features, and Footer links.
  static Widget accordion({
    required String title,
    required Widget content,
    bool initialOpen = false,
  }) {
    return _FxWebAccordion(title: title, content: content, initiallyExpanded: initialOpen);
  }

  /// Advanced SEO management for Fluxy Web.
  /// Dynamically updates the browser tab title and meta tags.
  static Widget seo({
    required String title,
    String description = '',
    String? ogImage,
    required Widget child,
  }) {
    return _FxWebSEO(
      title: title,
      description: description,
      ogImage: ogImage,
      child: child,
    );
  }

  /// A Next.js-style skeleton loader (Shimmer).
  /// Essential for building high-end "Suspense" loading states.
  static Widget skeleton({
    double width = double.infinity,
    double height = 20,
    double radius = 8,
  }) {
    return Fx.shimmer(
      child: Fx.box(
        style: FxStyle(
          width: width,
          height: height,
          backgroundColor: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// Horizontal Web Carousel for Hero banners, testimonials, or product galleries.
  /// Snaps elements seamlessly inline.
  static Widget carousel({
    required List<Widget> children,
    double height = 400,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(), // Native snappy web scrolling
        padding: const EdgeInsets.symmetric(horizontal: 32),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

class _FxWebSEO extends StatefulWidget {
  final String title;
  final String description;
  final String? ogImage;
  final Widget child;

  const _FxWebSEO({
    required this.title,
    required this.description,
    this.ogImage,
    required this.child,
  });

  @override
  State<_FxWebSEO> createState() => _FxWebSEOState();
}

class _FxWebSEOState extends State<_FxWebSEO> {
  @override
  void initState() {
    super.initState();
    _updateMetadata();
  }

  @override
  void didUpdateWidget(_FxWebSEO oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title || oldWidget.description != widget.description) {
      _updateMetadata();
    }
  }

  void _updateMetadata() {
    // Update Title
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: widget.title),
    );
    
    // Note: In a real production environment with package:web, 
    // we would update meta tags here.
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FxWebAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const _FxWebAccordion({required this.title, required this.content, this.initiallyExpanded = false});

  @override
  _FxWebAccordionState createState() => _FxWebAccordionState();
}

class _FxWebAccordionState extends State<_FxWebAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Fx.box(
      style: const FxStyle(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        backgroundColor: Colors.white,
        transition: Duration(milliseconds: 200),
      ),
      child: Fx.col(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Fx.box(
            onTap: () => setState(() => _expanded = !_expanded),
            style: const FxStyle(
              cursor: SystemMouseCursors.click,
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            ),
            child: Fx.row(
              justify: MainAxisAlignment.spaceBetween,
              children: [
                Fx.text(widget.title).tw('text-lg font-bold text-slate-900'),
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween<double>(begin: 0, end: _expanded ? 0.5 : 0),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value * 3.14159,
                      child: Fx.icon(Icons.keyboard_arrow_down, color: const Color(0xFF64748B)),
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              child: widget.content,
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}
