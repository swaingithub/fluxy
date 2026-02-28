import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluxy/fluxy.dart';

/// Industrial Geolocation Plugin for Fluxy.
/// Provides high-frequency tracking, geofencing, and reactive position signals.
class FluxyGeoPlugin extends FluxyPlugin {
  @override
  String get name => 'fluxy_geo';

  @override
  List<String> get permissions => ['location'];

  /// Reactive signals for the current location.
  final latitude = flux(0.0);
  final longitude = flux(0.0);
  final altitude = flux(0.0);
  final speed = flux(0.0);
  final heading = flux(0.0);
  final isTracking = flux(false);

  /// Geofencing signals.
  final activeGeofences = flux<Set<String>>({});
  final _geofenceDefinitions = <String, _Geofence>{};

  StreamSubscription<Position>? _positionStream;

  @override
  FutureOr<void> onRegister() {
    debugPrint('[GEO] [INIT] Geolocation Engine Ready.');
  }

  /// Starts high-frequency tracking.
  Future<void> startTracking({
    LocationSettings settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied (User rejected).');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    isTracking.value = true;
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position position) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        altitude.value = position.altitude;
        speed.value = position.speed;
        heading.value = position.heading;
        
        _checkGeofences(position.latitude, position.longitude);
        debugPrint('[GEO] [UPDATE] Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}');
      },
    );
  }

  /// Adds a circular geofence.
  void addGeofence(String id, double lat, double lng, double radiusInMeters) {
    _geofenceDefinitions[id] = _Geofence(id, lat, lng, radiusInMeters);
    debugPrint('[GEO] [GEOFENCE] Add: $id ($lat, $lng) Radius: $radiusInMeters m');
  }

  /// Removes a geofence.
  void removeGeofence(String id) {
    _geofenceDefinitions.remove(id);
    final active = Set<String>.from(activeGeofences.value);
    active.remove(id);
    activeGeofences.value = active;
    debugPrint('[GEO] [GEOFENCE] Remove: $id');
  }

  void _checkGeofences(double lat, double lng) {
    final currentlyActive = Set<String>.from(activeGeofences.value);
    bool changed = false;

    for (final gf in _geofenceDefinitions.values) {
      final distance = distanceBetween(lat, lng, gf.lat, gf.lng);
      final isInside = distance <= gf.radius;

      if (isInside && !currentlyActive.contains(gf.id)) {
        currentlyActive.add(gf.id);
        changed = true;
        debugPrint('[GEO] [GEOFENCE] [ENTER] ${gf.id}');
      } else if (!isInside && currentlyActive.contains(gf.id)) {
        currentlyActive.remove(gf.id);
        changed = true;
        debugPrint('[GEO] [GEOFENCE] [EXIT] ${gf.id}');
      }
    }

    if (changed) {
      activeGeofences.value = currentlyActive;
    }
  }

  /// Stops tracking and releases resources.
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    isTracking.value = false;
    activeGeofences.value = {};
    debugPrint('[GEO] [STOP] Tracking terminated.');
  }

  /// Calculates the distance between two points in meters.
  double distanceBetween(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  @override
  void onDispose() {
    stopTracking();
    super.onDispose();
  }
}

class _Geofence {
  final String id;
  final double lat;
  final double lng;
  final double radius;

  _Geofence(this.id, this.lat, this.lng, this.radius);
}
