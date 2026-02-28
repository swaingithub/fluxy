import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluxy/fluxy.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Managed Device & Environment awareness for Fluxy.
class FluxyDevicePlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_device';

  final meta = flux<Map<String, dynamic>>({});
  final appVersion = flux<String>('1.0.0');

  @override
  FutureOr<void> onRegister() async {
    await _loadInfo();
    Fluxy.log('Device', 'INIT', 'Environment knowledge hydrated.');
  }

  Future<void> _loadInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    appVersion.value = packageInfo.version;

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      meta.value = {
        'platform': 'web',
        'browser': webInfo.browserName.name,
        'version': webInfo.appVersion,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      meta.value = {
        'platform': 'android',
        'model': androidInfo.model,
        'sdk': androidInfo.version.sdkInt,
        'brand': androidInfo.brand,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      meta.value = {
        'platform': 'ios',
        'model': iosInfo.utsname.machine,
        'os': iosInfo.systemVersion,
      };
    }
  }

  /// Returns true if the app is running on a physical device.
  bool get isPhysical => meta.value['isPhysical'] ?? true;
}
