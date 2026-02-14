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
    if (util.startsWith('p-'))
      return FxStyle(padding: EdgeInsets.all(_toSize(util.substring(2))));
    if (util.startsWith('m-'))
      return FxStyle(margin: EdgeInsets.all(_toSize(util.substring(2))));
    if (util.startsWith('px-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.symmetric(horizontal: val));
    }
    if (util.startsWith('py-')) {
      final val = _toSize(util.substring(3));
      return FxStyle(padding: EdgeInsets.symmetric(vertical: val));
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

    // Colors: bg-blue-500, text-red-400
    if (util.startsWith('bg-'))
      return FxStyle(backgroundColor: _toColor(util.substring(3)));
    if (util.startsWith('text-')) {
      final val = util.substring(5);
      // Check if it's a color or a size
      if (['xs', 'sm', 'base', 'lg', 'xl', '2xl', '3xl'].contains(val)) {
        return FxStyle(fontSize: _toFontSize(val));
      }
      return FxStyle(color: _toColor(val));
    }

    // Borders & Radius: rounded-lg, border-2, border-blue-500
    if (util.startsWith('rounded')) {
      if (util == 'rounded')
        return const FxStyle(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        );
      final val = util.contains('-') ? util.split('-').last : '';
      return FxStyle(
        borderRadius: BorderRadius.all(Radius.circular(_toRadius(val))),
      );
    }
    if (util.startsWith('border')) {
      if (util == 'border')
        return FxStyle(border: Border.all(color: Colors.grey, width: 1));
      final val = util.split('-').last;
      final double? width = double.tryParse(val);
      if (width != null) return FxStyle(border: Border.all(width: width));
      return FxStyle(border: Border.all(color: _toColor(val)));
    }

    // Flex: flex-row, flex-col, gap-4, items-center, justify-center
    if (util == 'flex-row') return const FxStyle(direction: Axis.horizontal);
    if (util == 'flex-col') return const FxStyle(direction: Axis.vertical);
    if (util.startsWith('gap-'))
      return FxStyle(gap: _toSize(util.substring(4)));
    if (util.startsWith('items-'))
      return FxStyle(alignItems: _toCrossAlign(util.substring(6)));
    if (util.startsWith('justify-'))
      return FxStyle(justifyContent: _toMainAlign(util.substring(8)));

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
