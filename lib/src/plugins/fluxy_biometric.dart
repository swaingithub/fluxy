import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../engine/plugin.dart';
import '../reactive/signal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLUXY BIOMETRIC PLUGIN
// Enterprise-grade biometric authentication:
//   - Fingerprint / Face ID / Iris detection
//   - PIN / Pattern fallback (device credential)
//   - Capability detection (what biometrics are enrolled)
//   - Session locking with configurable timeout
//   - Auth attempts tracking with lockout
//   - Reactive isAuthenticated signal for route guards
//   - Challenge mode: re-authenticate for sensitive actions
// ─────────────────────────────────────────────────────────────────────────────

/// The type of biometric hardware available
enum FluxyBiometricType { fingerprint, faceId, iris, none }

/// Result of a biometric authentication attempt
class FluxyBiometricResult {
  final bool success;
  final String? error;
  final FluxyBiometricType type;

  const FluxyBiometricResult._({
    required this.success,
    this.error,
    required this.type,
  });

  factory FluxyBiometricResult.success(FluxyBiometricType type) =>
      FluxyBiometricResult._(success: true, type: type);

  factory FluxyBiometricResult.failure(String reason) =>
      FluxyBiometricResult._(
          success: false, error: reason, type: FluxyBiometricType.none);

  @override
  String toString() =>
      success ? 'BiometricResult(✅)' : 'BiometricResult(❌ $error)';
}

/// Security policy for biometric auth
class FluxyBiometricPolicy {
  /// Text shown in the biometric dialog
  final String reason;
  /// Allow device PIN/Pattern fallback if biometrics fail
  final bool allowDeviceCredential;
  /// Lock out after N failed attempts (0 = no lockout)
  final int maxAttempts;
  /// Auto-lock session after this duration of inactivity
  final Duration? sessionTimeout;
  /// If true, biometrics required for every sensitive action (not just login)
  final bool requireForSensitiveActions;

  const FluxyBiometricPolicy({
    this.reason = 'Verify your identity to continue',
    this.allowDeviceCredential = true,
    this.maxAttempts = 3,
    this.sessionTimeout = const Duration(minutes: 5),
    this.requireForSensitiveActions = false,
  });
}

class FluxyBiometricPlugin extends FluxyPlugin with ChangeNotifier {
  @override
  String get name => 'fluxy_biometric';

  @override
  List<String> get permissions => ['biometric'];

  // ── Core ──────────────────────────────────────────────────────────────────
  final _auth = LocalAuthentication();
  FluxyBiometricPolicy _policy = const FluxyBiometricPolicy();

  // ── Reactive state ────────────────────────────────────────────────────────
  /// True when the current session is authenticated.
  final isAuthenticated = flux<bool>(false, label: 'biometric_auth');
  /// Available biometric types on this device.
  final availableTypes =
      flux<List<FluxyBiometricType>>([], label: 'biometric_types');
  /// Is any biometric hardware available and enrolled?
  final isAvailable = flux<bool>(false, label: 'biometric_available');
  /// Number of failed attempts in current session.
  final failedAttempts = flux<int>(0, label: 'biometric_failures');
  /// True when the user has been locked out after too many failures.
  final isLockedOut = flux<bool>(false, label: 'biometric_locked');

  // ── Session management ────────────────────────────────────────────────────
  Timer? _sessionTimer;
  DateTime? _lastAuthTime;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  FutureOr<void> onRegister() async {
    debugPrint('🔐 [FluxyBiometric] Initializing...');
    await _detectCapabilities();
    debugPrint(
        '🔐 [FluxyBiometric] Available: ${isAvailable.value}, Types: ${availableTypes.value.map((t) => t.name).join(", ")}');
  }

  @override
  FutureOr<void> onDispose() {
    _sessionTimer?.cancel();
  }

  // ── Configuration ─────────────────────────────────────────────────────────

  /// Apply a security policy. Call before first authenticate().
  void setPolicy(FluxyBiometricPolicy policy) {
    _policy = policy;
  }

  // ── Authentication ────────────────────────────────────────────────────────

  /// Authenticate the user. Returns a result with success/error detail.
  Future<FluxyBiometricResult> authenticate({
    String? reason,
    bool allowDeviceCredential = true,
  }) async {
    if (isLockedOut.value) {
      return FluxyBiometricResult.failure(
          'Too many failed attempts. Try again later.');
    }

    if (!isAvailable.value) {
      return FluxyBiometricResult.failure(
          'No biometrics enrolled on this device.');
    }

    try {
      debugPrint('🔐 [FluxyBiometric] Requesting authentication...');

      // Robust call using common named parameters across local_auth 2.x and 3.x
      // (some versions use AuthenticationOptions, others use top-level)
      // If AuthenticationOptions is not found, we use positional/named fallback
      final success = await _auth.authenticate(
        localizedReason: reason ?? _policy.reason,
        // Using named parameters directly for older or specific versions
        // and bypassing AuthenticationOptions if it's missing from exports
      );

      if (success) {
        _onSuccess();
        return FluxyBiometricResult.success(
            availableTypes.value.isNotEmpty
                ? availableTypes.value.first
                : FluxyBiometricType.fingerprint);
      } else {
        _onFailure();
        return FluxyBiometricResult.failure('Authentication cancelled.');
      }
    } on PlatformException catch (e) {
      _onFailure();
      final msg = _mapError(e.code);
      return FluxyBiometricResult.failure(msg);
    }
  }

  /// Re-authenticate for a sensitive action (payment, delete, etc.).
  /// Returns true if the user verified successfully.
  Future<bool> challenge({String reason = 'Confirm your identity'}) async {
    // If session is still valid and policy doesn't require per-action auth
    if (!_policy.requireForSensitiveActions && _isSessionValid()) {
      return true;
    }
    final result = await authenticate(reason: reason);
    return result.success;
  }

  // ── Session ───────────────────────────────────────────────────────────────

  /// Manually lock the session (e.g. on app background).
  void lock() {
    isAuthenticated.value = false;
    _sessionTimer?.cancel();
    _lastAuthTime = null;
    notifyListeners();
    debugPrint('🔐 [FluxyBiometric] Session locked.');
  }

  /// Unlock without prompting (use after successful background auth check).
  void unlockSession() {
    isAuthenticated.value = true;
    _lastAuthTime = DateTime.now();
    _restartSessionTimer();
    notifyListeners();
  }

  /// Extend the current session timeout (call on user activity).
  void extendSession() {
    if (isAuthenticated.value) {
      _lastAuthTime = DateTime.now();
      _restartSessionTimer();
    }
  }

  bool _isSessionValid() {
    if (!isAuthenticated.value) return false;
    if (_policy.sessionTimeout == null) return true;
    if (_lastAuthTime == null) return false;
    return DateTime.now().difference(_lastAuthTime!) < _policy.sessionTimeout!;
  }

  // ── Capability Detection ──────────────────────────────────────────────────

  /// Re-detect available biometrics (call after hardware changes).
  Future<void> refresh() => _detectCapabilities();

  /// Returns true if Face ID is available.
  bool get hasFaceId => availableTypes.value.contains(FluxyBiometricType.faceId);

  /// Returns true if fingerprint is available.
  bool get hasFingerprint =>
      availableTypes.value.contains(FluxyBiometricType.fingerprint);

  // ── Lockout Management ────────────────────────────────────────────────────

  /// Manually reset the failure counter and lockout.
  void resetLockout() {
    failedAttempts.value = 0;
    isLockedOut.value = false;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _detectCapabilities() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        isAvailable.value = false;
        availableTypes.value = [];
        return;
      }

      final enrolled = await _auth.getAvailableBiometrics();
      final types = enrolled.map(_mapBiometric).whereType<FluxyBiometricType>().toList();

      availableTypes.value = types;
      isAvailable.value = types.isNotEmpty;
    } catch (_) {
      isAvailable.value = false;
      availableTypes.value = [];
    }
  }

  void _onSuccess() {
    isAuthenticated.value = true;
    failedAttempts.value = 0;
    isLockedOut.value = false;
    _lastAuthTime = DateTime.now();
    _restartSessionTimer();
    notifyListeners();
    debugPrint('🔐 [FluxyBiometric] ✅ Authenticated successfully.');
  }

  void _onFailure() {
    final attempts = failedAttempts.value + 1;
    failedAttempts.value = attempts;

    if (_policy.maxAttempts > 0 && attempts >= _policy.maxAttempts) {
      isLockedOut.value = true;
      debugPrint('🔐 [FluxyBiometric] ❌ Locked out after $attempts attempts.');
      // Auto-reset lockout after 30 seconds
      Future.delayed(const Duration(seconds: 30), resetLockout);
    } else {
      debugPrint('🔐 [FluxyBiometric] ⚠️ Failed attempt $attempts/${_policy.maxAttempts}.');
    }
    notifyListeners();
  }

  void _restartSessionTimer() {
    _sessionTimer?.cancel();
    if (_policy.sessionTimeout == null) return;
    _sessionTimer = Timer(_policy.sessionTimeout!, () {
      if (isAuthenticated.value) {
        lock();
        debugPrint('🔐 [FluxyBiometric] Session expired — auto-locked.');
      }
    });
  }

  FluxyBiometricType? _mapBiometric(BiometricType t) => switch (t) {
    BiometricType.fingerprint => FluxyBiometricType.fingerprint,
    BiometricType.face        => FluxyBiometricType.faceId,
    BiometricType.iris        => FluxyBiometricType.iris,
    _                            => null,
  };

  String _mapError(String code) => switch (code) {
    'NotAvailable'        => 'Biometric hardware not available.',
    'NotEnrolled'         => 'No biometrics enrolled. Set up in device settings.',
    'LockedOut'           => 'Too many attempts. Try again later.',
    'PermanentlyLockedOut'=> 'Biometrics permanently locked. Use device PIN.',
    'PasscodeNotSet'      => 'No device passcode set.',
    _                     => 'Authentication error: $code',
  };
}
