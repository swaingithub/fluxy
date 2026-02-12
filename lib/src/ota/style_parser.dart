import 'package:flutter/material.dart';
import '../styles/style.dart';

/// Parses JSON styles into Fluxy FxStyle objects.
class FluxyStyleParser {
  
  static FxStyle parse(Map<String, dynamic>? json) {
    if (json == null) return FxStyle.none;

    return FxStyle(
      padding: _parseEdgeInsets(json['padding']) ?? EdgeInsets.zero,
      margin: _parseEdgeInsets(json['margin']) ?? EdgeInsets.zero,
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      backgroundColor: _parseColor(json['backgroundColor']),
      borderRadius: _parseBorderRadius(json['borderRadius']),
      border: _parseBorder(json['border']),
      shadows: _parseShadows(json['shadows']),
      opacity: _parseDouble(json['opacity']),
      alignment: _parseAlignment(json['alignment']),
      
      // Text Properties
      color: _parseColor(json['color']),
      fontSize: _parseDouble(json['fontSize']),
      fontWeight: _parseFontWeight(json['fontWeight']),
      letterSpacing: _parseDouble(json['letterSpacing']),
      lineHeight: _parseDouble(json['lineHeight']),
      fontFamily: json['fontFamily'],
      textAlign: _parseTextAlign(json['textAlign']),
    );
  }

  static TextAlign? _parseTextAlign(String? value) {
    switch (value) {
      case 'center': return TextAlign.center;
      case 'end': return TextAlign.end;
      case 'justify': return TextAlign.justify;
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'start': return TextAlign.start;
      default: return null;
    }
  }

  // --- Helpers ---

  static double? _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Color? _parseColor(dynamic value) {
    if (value is! String) return null;
    final buffer = StringBuffer();
    if (value.length == 6 || value.length == 7) buffer.write('ff');
    buffer.write(value.replaceFirst('#', ''));
    final int? colorInt = int.tryParse(buffer.toString(), radix: 16);
    return colorInt != null ? Color(colorInt) : null;
  }

  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value is num) return EdgeInsets.all(value.toDouble());
    if (value is List) {
      if (value.length == 2) return EdgeInsets.symmetric(vertical: value[0].toDouble(), horizontal: value[1].toDouble());
      if (value.length == 4) return EdgeInsets.fromLTRB(value[0].toDouble(), value[1].toDouble(), value[2].toDouble(), value[3].toDouble());
    }
    return null;
  }

  static BorderRadius? _parseBorderRadius(dynamic value) {
    if (value is num) return BorderRadius.circular(value.toDouble());
    // Could execute more complex logic (onlyTop, etc)
    return null;
  }

  static BoxBorder? _parseBorder(dynamic value) {
    if (value is Map) {
      final color = _parseColor(value['color']) ?? Colors.black;
      final width = _parseDouble(value['width']) ?? 1.0;
      return Border.all(color: color, width: width);
    }
    return null;
  }

  static List<BoxShadow>? _parseShadows(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          return BoxShadow(
            color: _parseColor(e['color']) ?? Colors.black12,
            blurRadius: _parseDouble(e['blur']) ?? 0,
            offset: Offset(
              _parseDouble(e['x']) ?? 0,
              _parseDouble(e['y']) ?? 0,
            ),
          );
        }
        return const BoxShadow();
      }).toList();
    }
    return null;
  }

  static Alignment? _parseAlignment(String? value) {
    switch (value) {
      case 'center': return Alignment.center;
      case 'topLeft': return Alignment.topLeft;
      case 'topRight': return Alignment.topRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomRight': return Alignment.bottomRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'centerRight': return Alignment.centerRight;
      case 'topCenter': return Alignment.topCenter;
      case 'bottomCenter': return Alignment.bottomCenter;
      default: return null;
    }
  }

  static FontWeight? _parseFontWeight(String? value) {
    switch (value) {
      case 'bold': return FontWeight.bold;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400; // normal
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700; // bold
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default: return null;
    }
  }
}
