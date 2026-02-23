import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:fluxy/fluxy.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY PERMISSIONS PLUGIN
// Unified permission management with:
//   - Reactive per-permission status signals
//   - Batch request with results map
//   - Auto-open settings if permanently denied
//   - Grouped permissions by category for easy access
// ─────────────────────────────────────────────────────────────────────────────

/// Fluxy permission identifiers — map to platform permissions.
enum FluxyPermission {
  camera,
  microphone,
  storage,
  gallery,
  location,
  locationAlways,
  contacts,
  calendar,
  notification,
  bluetooth,
  phone,
  sms,
  exactAlarm,
}

/// Result of a permission request.
enum FluxyPermissionStatus { granted, denied, permanentlyDenied, restricted, limited }

class FluxyPermissionsPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_permissions';

  @override
  List<String> get permissions => ['system_permissions'];

  // ── Reactive permission status cache ────────────────────────────────────────
  final Map<FluxyPermission, Flux<FluxyPermissionStatus?>> _statuses = {};

  /// Returns reactive status signal for a given permission.
  /// Auto-initialises the signal on first access.
  Flux<FluxyPermissionStatus?> statusOf(FluxyPermission p) {
    return _statuses.putIfAbsent(p, () => flux<FluxyPermissionStatus?>(null));
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    debugPrint('[SYS] [PERM] Subsystem initialized.');
    // Pre-check status of commonly needed permissions without requesting them
    await checkAll([
      FluxyPermission.camera,
      FluxyPermission.microphone,
      FluxyPermission.notification,
    ]);
  }

  // ── Single Permission ────────────────────────────────────────────────────────

  /// Check current status without requesting.
  Future<FluxyPermissionStatus> check(FluxyPermission p) async {
    final ph.PermissionStatus raw = await _toPhPermission(p).status;
    final status = _fromPh(raw);
    _updateSignal(p, status);
    return status;
  }

  /// Request a permission. Returns the resulting status.
  Future<FluxyPermissionStatus> request(FluxyPermission p) async {
    debugPrint('[SYS] [PERM] Requesting elevated access: ${p.name.toUpperCase()}...');
    final ph.PermissionStatus raw = await _toPhPermission(p).request();
    final status = _fromPh(raw);
    _updateSignal(p, status);

    if (status == FluxyPermissionStatus.granted) {
      debugPrint('[SYS] [PERM] [GRANTED] ${p.name.toUpperCase()} access verified.');
    } else if (status == FluxyPermissionStatus.permanentlyDenied) {
      debugPrint('[SYS] [PERM] [FATAL] ${p.name.toUpperCase()} permanently denied by policy.');
    } else {
      debugPrint('[SYS] [PERM] [WARN] ${p.name.toUpperCase()} request denied.');
    }

    return status;
  }

  /// Returns true if permission is granted.
  Future<bool> isGranted(FluxyPermission p) async =>
      (await check(p)) == FluxyPermissionStatus.granted;

  /// Requests only if not already granted. Avoids redundant prompts.
  Future<FluxyPermissionStatus> requestIfNeeded(FluxyPermission p) async {
    final current = await check(p);
    if (current == FluxyPermissionStatus.granted) return current;
    if (current == FluxyPermissionStatus.permanentlyDenied) return current;
    return request(p);
  }

  // ── Batch Operations ─────────────────────────────────────────────────────────

  /// Check multiple permissions, updates reactive signals. No dialogs shown.
  Future<Map<FluxyPermission, FluxyPermissionStatus>> checkAll(
      List<FluxyPermission> perms) async {
    final results = <FluxyPermission, FluxyPermissionStatus>{};
    for (final p in perms) {
      results[p] = await check(p);
    }
    return results;
  }

  /// Request multiple permissions at once (OS batches on iOS/Android 12+).
  Future<Map<FluxyPermission, FluxyPermissionStatus>> requestAll(
      List<FluxyPermission> perms) async {
    final phPerms = perms.map(_toPhPermission).toList();
    final rawResults = await phPerms.request();

    final results = <FluxyPermission, FluxyPermissionStatus>{};
    for (int i = 0; i < perms.length; i++) {
      final status = _fromPh(rawResults[phPerms[i]] ?? ph.PermissionStatus.denied);
      results[perms[i]] = status;
      _updateSignal(perms[i], status);
    }
    return results;
  }

  /// Returns true only if ALL provided permissions are granted.
  Future<bool> areAllGranted(List<FluxyPermission> perms) async {
    final results = await checkAll(perms);
    return results.values.every((s) => s == FluxyPermissionStatus.granted);
  }

  // ── Settings Redirect ────────────────────────────────────────────────────────

  /// Opens OS app settings so user can manually grant permanently-denied permissions.
  Future<bool> openSettings() async {
    debugPrint('[SYS] [PERM] Redirecting to OS App Settings...');
    return ph.openAppSettings();
  }

  /// If [p] is permanently denied, open settings. Otherwise request.
  Future<FluxyPermissionStatus> requestOrOpenSettings(FluxyPermission p) async {
    final status = await requestIfNeeded(p);
    if (status == FluxyPermissionStatus.permanentlyDenied) {
      await openSettings();
    }
    return status;
  }

  // ── Private Helpers ──────────────────────────────────────────────────────────

  void _updateSignal(FluxyPermission p, FluxyPermissionStatus status) {
    statusOf(p).value = status;
    notifyListeners();
  }

  ph.Permission _toPhPermission(FluxyPermission p) => switch (p) {
    FluxyPermission.camera         => ph.Permission.camera,
    FluxyPermission.microphone     => ph.Permission.microphone,
    FluxyPermission.storage        => ph.Permission.storage,
    FluxyPermission.gallery        => ph.Permission.photos,
    FluxyPermission.location       => ph.Permission.locationWhenInUse,
    FluxyPermission.locationAlways => ph.Permission.locationAlways,
    FluxyPermission.contacts       => ph.Permission.contacts,
    FluxyPermission.calendar       => ph.Permission.calendarFullAccess,
    FluxyPermission.notification   => ph.Permission.notification,
    FluxyPermission.bluetooth      => ph.Permission.bluetooth,
    FluxyPermission.phone          => ph.Permission.phone,
    FluxyPermission.sms            => ph.Permission.sms,
    FluxyPermission.exactAlarm     => ph.Permission.scheduleExactAlarm,
  };

  FluxyPermissionStatus _fromPh(ph.PermissionStatus s) => switch (s) {
    ph.PermissionStatus.granted           => FluxyPermissionStatus.granted,
    ph.PermissionStatus.denied            => FluxyPermissionStatus.denied,
    ph.PermissionStatus.permanentlyDenied => FluxyPermissionStatus.permanentlyDenied,
    ph.PermissionStatus.restricted        => FluxyPermissionStatus.restricted,
    ph.PermissionStatus.limited           => FluxyPermissionStatus.limited,
    _                                     => FluxyPermissionStatus.denied,
  };
}
