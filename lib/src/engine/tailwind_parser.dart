import 'package:flutter/material.dart';
import '../styles/style.dart';

/// A Tailwind-style utility class parser for Fluxy.
/// Converts strings like 'p-4 bg-blue-500 rounded-lg' into FxStyle objects.
class Tailwind {
  static final Map<String, FxStyle> _cache = {};

  /// Parses a space-separated string of utility classes.
  static FxStyle parse(String classes) {
    if (_cache.containsKey(classes)) return _cache[classes]!;

    FxStyle finalStyle = FxStyle.none;
    final parts = classes.split(' ');

    for (var part in parts) {
      if (part.isEmpty) continue;
      finalStyle = finalStyle.merge(_parseUtility(part));
    }

    _cache[classes] = finalStyle;
    return finalStyle;
  }

  static FxStyle _parseUtility(String util) {
    // Spacing: p-4, m-2, px-4, py-2, pt-1, etc.
    if (util.startsWith('p-')) {
      return FxStyle(padding: EdgeInsets.all(_toSize(util.substring(2))));
    }
    if (util.startsWith('px-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.symmetric(horizontal: val));
    }
    if (util.startsWith('py-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.symmetric(vertical: val));
    }
    if (util.startsWith('pt-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.only(top: val));
    }
    if (util.startsWith('pb-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.only(bottom: val));
    }
    if (util.startsWith('pl-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.only(left: val));
    }
    if (util.startsWith('pr-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.only(right: val));
    }

    if (util.startsWith('m-')) {
      return FxStyle(margin: EdgeInsets.all(_toSize(util.substring(2))));
    }
    if (util.startsWith('mx-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.symmetric(horizontal: val));
    }
    if (util.startsWith('my-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.symmetric(vertical: val));
    }
    if (util.startsWith('mt-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.only(top: val));
    }
    if (util.startsWith('mb-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.only(bottom: val));
    }
    if (util.startsWith('ml-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.only(left: val));
    }
    if (util.startsWith('mr-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(margin: EdgeInsets.only(right: val));
    }

    // Sizing: w-64, h-32, w-full, h-screen
    if (util.startsWith('w-')) {
      final val = util.substring(2);
      if (val == 'full') return const FxStyle(width: double.infinity);
      return FxStyle(width: _toSize(val));
    }
    if (util.startsWith('h-')) {
      final val = util.substring(2);
      if (val == 'full') return const FxStyle(height: double.infinity);
      return FxStyle(height: _toSize(val));
    }
    if (util.startsWith('min-w-')) {
      final val = util.substring(6);
      if (val == 'full') return const FxStyle(minWidth: double.infinity);
      return FxStyle(minWidth: _toSize(val));
    }
    if (util.startsWith('min-h-')) {
      final val = util.substring(6);
      if (val == 'full' || val == 'screen') return const FxStyle(minHeight: double.infinity);
      return FxStyle(minHeight: _toSize(val));
    }
    if (util.startsWith('max-w-')) {
      final val = util.substring(6);
      if (val == 'full') return const FxStyle(maxWidth: double.infinity);
      return FxStyle(maxWidth: _toSize(val));
    }
    if (util.startsWith('max-h-')) {
      final val = util.substring(6);
      if (val == 'full' || val == 'screen') return const FxStyle(maxHeight: double.infinity);
      return FxStyle(maxHeight: _toSize(val));
    }

    // Colors: bg-blue-500, text-red-400
    if (util.startsWith('bg-')) {
      return FxStyle(backgroundColor: _toColor(util.substring(3)));
    }
    if (util.startsWith('text-')) {
      final val = util.substring(5);
      // Check alignments
      if (val == 'center') return const FxStyle(textAlign: TextAlign.center);
      if (val == 'left') return const FxStyle(textAlign: TextAlign.left);
      if (val == 'right') return const FxStyle(textAlign: TextAlign.right);
      if (val == 'justify') return const FxStyle(textAlign: TextAlign.justify);
      // Check if it's a size
      if (['xs', 'sm', 'base', 'lg', 'xl', '2xl', '3xl', '4xl', '5xl', '6xl', '7xl', '8xl'].contains(val)) {
        return FxStyle(fontSize: _toFontSize(val));
      }
      return FxStyle(color: _toColor(val));
    }
    
    // Typography properties
    if (util == 'italic') return const FxStyle(fontStyle: FontStyle.italic);
    if (util == 'not-italic') return const FxStyle(fontStyle: FontStyle.normal);
    if (util == 'underline') return const FxStyle(textDecoration: TextDecoration.underline);
    if (util == 'line-through') return const FxStyle(textDecoration: TextDecoration.lineThrough);
    if (util == 'no-underline') return const FxStyle(textDecoration: TextDecoration.none);
    if (util == 'truncate') return const FxStyle(overflow: TextOverflow.ellipsis, maxLines: 1);

    if (util.startsWith('leading-')) {
      final val = util.substring(8);
      if (val == 'none') return const FxStyle(lineHeight: 1.0);
      if (val == 'tight') return const FxStyle(lineHeight: 1.25);
      if (val == 'snug') return const FxStyle(lineHeight: 1.375);
      if (val == 'normal') return const FxStyle(lineHeight: 1.5);
      if (val == 'relaxed') return const FxStyle(lineHeight: 1.625);
      if (val == 'loose') return const FxStyle(lineHeight: 2.0);
    }

    if (util.startsWith('tracking-')) {
      final val = util.substring(9);
      if (val == 'tighter') return const FxStyle(letterSpacing: -0.8);
      if (val == 'tight') return const FxStyle(letterSpacing: -0.4);
      if (val == 'normal') return const FxStyle(letterSpacing: 0.0);
      if (val == 'wide') return const FxStyle(letterSpacing: 0.4);
      if (val == 'wider') return const FxStyle(letterSpacing: 0.8);
      if (val == 'widest') return const FxStyle(letterSpacing: 1.6);
    }

    // Font Weights
    if (util.startsWith('font-')) {
      final val = util.substring(5);
      if (val == 'bold') return const FxStyle(fontWeight: FontWeight.bold);
      if (val == 'semibold') return const FxStyle(fontWeight: FontWeight.w600);
      if (val == 'medium') return const FxStyle(fontWeight: FontWeight.w500);
      if (val == 'normal') return const FxStyle(fontWeight: FontWeight.normal);
      if (val == 'light') return const FxStyle(fontWeight: FontWeight.w300);
    }

    // Borders & Radius: rounded-lg, border-2, border-blue-500
    if (util.startsWith('rounded')) {
      if (util == 'rounded') {
        return const FxStyle(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        );
      }
      final val = util.contains('-') ? util.split('-').last : '';
      return FxStyle(
        borderRadius: BorderRadius.all(Radius.circular(_toRadius(val))),
      );
    }
    if (util.startsWith('border')) {
      if (util == 'border') {
        return FxStyle(border: Border.all(color: Colors.grey, width: 1));
      }
      final val = util.split('-').last;
      final double? width = double.tryParse(val);
      if (width != null) return FxStyle(border: Border.all(width: width));
      return FxStyle(border: Border.all(color: _toColor(val)));
    }

    // Flex: flex-row, flex-col, gap-4, items-center, justify-center
    if (util == 'flex-row') return const FxStyle(direction: Axis.horizontal);
    if (util == 'flex-col') return const FxStyle(direction: Axis.vertical);
    if (util == 'grow') return const FxStyle(flexGrow: 1);
    if (util == 'grow-0') return const FxStyle(flexGrow: 0);
    if (util == 'shrink') return const FxStyle(flexShrink: 1);
    if (util == 'shrink-0') return const FxStyle(flexShrink: 0);
    if (util.startsWith('flex-')) {
      final val = util.substring(5);
      if (val == '1') return const FxStyle(flex: 1, flexFit: FlexFit.tight);
      if (val == 'auto') return const FxStyle(flex: 1, flexFit: FlexFit.loose);
      if (val == 'none') return const FxStyle(flex: 0, flexFit: FlexFit.loose);
      final intVal = int.tryParse(val);
      if (intVal != null) return FxStyle(flex: intVal, flexFit: FlexFit.tight);
    }
    if (util.startsWith('gap-')) {
      return FxStyle(gap: _toSize(util.substring(4)));
    }
    if (util.startsWith('items-')) {
      return FxStyle(alignItems: _toCrossAlign(util.substring(6)));
    }
    if (util.startsWith('justify-')) {
      return FxStyle(justifyContent: _toMainAlign(util.substring(8)));
    }

    // Positioning
    if (util.startsWith('z-')) {
      final val = double.tryParse(util.substring(2));
      if (val != null) return FxStyle(zIndex: val);
    }
    if (util.startsWith('top-')) return FxStyle(top: _toSize(util.substring(4)));
    if (util.startsWith('bottom-')) return FxStyle(bottom: _toSize(util.substring(7)));
    if (util.startsWith('left-')) return FxStyle(left: _toSize(util.substring(5)));
    if (util.startsWith('right-')) return FxStyle(right: _toSize(util.substring(6)));

    // Cursor
    if (util.startsWith('cursor-')) {
      final val = util.substring(7);
      if (val == 'pointer') return const FxStyle(cursor: SystemMouseCursors.click);
      if (val == 'default') return const FxStyle(cursor: SystemMouseCursors.basic);
      if (val == 'text') return const FxStyle(cursor: SystemMouseCursors.text);
      if (val == 'wait') return const FxStyle(cursor: SystemMouseCursors.wait);
      if (val == 'not-allowed') return const FxStyle(cursor: SystemMouseCursors.forbidden);
    }

    // Shadows
    if (util.startsWith('shadow')) {
      if (util == 'shadow') return const FxStyle(shadows: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]);
      if (util == 'shadow-md') return const FxStyle(shadows: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))]);
      if (util == 'shadow-lg') return const FxStyle(shadows: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6))]);
      if (util == 'shadow-xl') return const FxStyle(shadows: [BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 10))]);
      if (util == 'shadow-none') return const FxStyle(shadows: []);
    }

    // Opacity
    if (util.startsWith('opacity-')) {
      final val = double.tryParse(util.substring(8));
      if (val != null) return FxStyle(opacity: val / 100);
    }

    // Transforms and Aspect Ratio
    if (util.startsWith('scale-')) {
      final val = double.tryParse(util.substring(6));
      if (val != null) return FxStyle(transformScale: val / 100);
    }
    if (util.startsWith('rotate-')) {
      final val = double.tryParse(util.substring(7));
      if (val != null) return FxStyle(transformRotation: val * 3.14159 / 180);
    }
    if (util.startsWith('aspect-')) {
      final val = util.substring(7);
      if (val == 'square') return const FxStyle(aspectRatio: 1.0);
      if (val == 'video') return const FxStyle(aspectRatio: 16 / 9);
      final parts = val.split('/');
      if (parts.length == 2) {
        final w = double.tryParse(parts[0]);
        final h = double.tryParse(parts[1]);
        if (w != null && h != null) return FxStyle(aspectRatio: w / h);
      }
    }

    return FxStyle.none;
  }

  static double _toSize(String val) {
    final num? n = num.tryParse(val);
    return (n ?? 0) * 4.0;
  }

  static double _toFontSize(String val) {
    switch (val) {
      case 'xs':
        return 12;
      case 'sm':
        return 14;
      case 'base':
        return 16;
      case 'lg':
        return 18;
      case 'xl':
        return 20;
      case '2xl':
        return 24;
      case '3xl':
        return 30;
      case '4xl':
        return 36;
      case '5xl':
        return 48;
      case '6xl':
        return 60;
      case '7xl':
        return 72;
      case '8xl':
        return 96;
      default:
        return 16;
    }
  }

  static double _toRadius(String val) {
    switch (val) {
      case 'sm':
        return 2;
      case 'md':
        return 6;
      case 'lg':
        return 8;
      case 'xl':
        return 12;
      case '2xl':
        return 16;
      case 'full':
        return 9999;
      default:
        return 4;
    }
  }

  static Color _toColor(String val) {
    if (val.contains('-')) {
      final parts = val.split('-');
      final colorBase = parts[0];
      final shade = int.tryParse(parts[1]) ?? 500;

      final Map<String, MaterialColor> colorMap = {
        'red': Colors.red,
        'blue': Colors.blue,
        'green': Colors.green,
        'yellow': Colors.yellow,
        'purple': Colors.purple,
        'pink': Colors.pink,
        'indigo': Colors.indigo,
        'gray': Colors.grey,
        'slate': Colors.blueGrey,
      };

      final base = colorMap[colorBase] ?? Colors.transparent;
      if (base is MaterialColor) return base[shade] ?? base;
      return base;
    }

    if (val == 'white') return Colors.white;
    if (val == 'black') return Colors.black;
    if (val == 'transparent') return Colors.transparent;

    return Colors.transparent;
  }

  static MainAxisAlignment _toMainAlign(String val) {
    switch (val) {
      case 'start':
        return MainAxisAlignment.start;
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'between':
        return MainAxisAlignment.spaceBetween;
      case 'around':
        return MainAxisAlignment.spaceAround;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _toCrossAlign(String val) {
    switch (val) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }
}
