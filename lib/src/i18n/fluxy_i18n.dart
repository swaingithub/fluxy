import 'package:flutter/widgets.dart';
import '../reactive/signal.dart';
import '../dsl/fx.dart';

/// Supported plural rules.
enum PluralRule { zero, one, two, few, many, other }

/// The centralized language and translation manager for Fluxy.
class FluxyI18n {
  static final Signal<Locale> _locale = flux(const Locale('en', 'US'));
  static final Signal<Map<String, Map<String, dynamic>>> _translations = flux({});
  static final Signal<bool> _isInitialized = flux(false);

  /// Current locale signal.
  static Signal<Locale> get localeSignal => _locale;
  
  /// Current active locale.
  static Locale get currentLocale => _locale.value;

  /// Loads translations into the engine.
  /// Map format: {'en': {'hello': 'Hello'}, 'es': {'hello': 'Hola'}}
  static void load(Map<String, Map<String, dynamic>> data) {
    _translations.value = data;
    _isInitialized.value = true;
  }

  /// Changes the current language.
  /// Triggers a reactive update for all UI using `.tr`.
  static void setLocale(Locale newLocale) {
    if (_locale.value == newLocale) return;
    _locale.value = newLocale;
  }

  /// Translates a key.
  static String translate(String key, [Map<String, dynamic>? args]) {
    if (!_isInitialized.value) return key;

    final langCode = _locale.value.languageCode;
    final Map<String, dynamic>? langData = _translations.value[langCode];

    if (langData == null) return key;

    // Handle nested keys: 'home.title'
    final keys = key.split('.');
    dynamic result = langData;
    
    for (final k in keys) {
      if (result is Map<String, dynamic> && result.containsKey(k)) {
        result = result[k];
      } else {
        return key; // Fallback to key if not found
      }
    }

    if (result is String) {
      return _interpolate(result, args);
    }
    
    return key;
  }

  /// Translates with pluralization.
  /// Keys should be nested: 'items.zero', 'items.one', 'items.other'
  static String translatePlural(String key, num count, [Map<String, dynamic>? args]) {
    final rule = _getPluralRule(count, _locale.value.languageCode);
    final ruleKey = rule.name;
    
    // Try explicit rule first (e.g., 'items.zero')
    String translation = translate('$key.$ruleKey', args);
    
    if (translation == '$key.$ruleKey') {
        // Fallback to 'other'
        translation = translate('$key.other', args);
    }

    // If strictly not found, fallback to key
    if (translation == '$key.other') return key;

    // Auto-inject 'n' or 'count'
    final finalArgs = {'n': count, 'count': count, ...?args};
    return _interpolate(translation, finalArgs);
  }

  static String _interpolate(String text, Map<String, dynamic>? args) {
    if (args == null || args.isEmpty) return text;
    
    return text.replaceAllMapped(RegExp(r'{(\w+)}'), (match) {
      final key = match.group(1);
      return args[key]?.toString() ?? match.group(0)!;
    });
  }

  /// Primitive plural implementation (can be replaced with intl package logic).
  static PluralRule _getPluralRule(num count, String languageCode) {
    if (count == 0) return PluralRule.zero;
    if (count == 1) return PluralRule.one;
    return PluralRule.other;
  }
}

/// Fluent extensions for translation.
extension FluxyI18nStringExtension on String {
  /// Reactive translation.
  /// Automatically re-renders used widgets when locale changes.
  String get tr {
    // Register dependency on locale so the widget rebuilds
    FluxyI18n.localeSignal.value; 
    return FluxyI18n.translate(this);
  }

  /// Reactive translation with arguments.
  String trArgs(Map<String, dynamic> args) {
    FluxyI18n.localeSignal.value; 
    return FluxyI18n.translate(this, args);
  }

  /// Reactive plural translation.
  String trPlural(num count, [Map<String, dynamic>? args]) {
    FluxyI18n.localeSignal.value; 
    return FluxyI18n.translatePlural(this, count, args);
  }
}

/// Allows direct usage in Fx text widgets.
extension FluxyI18nWidgetExtension on String {
  /// Shorthand to create a reactive Text widget that translates this string.
  /// Example: 'hello'.trText()
  Widget trText({TextStyle? style, TextAlign? align}) {
    return Fx(() => Text(
      tr,
      style: style,
      textAlign: align,
    ));
  }
}
