import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas institucionales predeterminadas: Puerta Principal Campus Capanique UPT
  static const double latitudPorDefecto = -18.0066;
  static const double longitudPorDefecto = -70.2463;
  static const int precisionPorDefecto = 5;

  static Future<Map<String, dynamic>> obtenerUbicacionActual() async {
    try {
      final servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        return _ubicacionFallback('Servicio GPS desactivado');
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          return _ubicacionFallback('Permiso de ubicación denegado');
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        return _ubicacionFallback('Permiso de ubicación denegado permanentemente');
      }

      // Intentar obtener última conocida primero para rapidez
      final ultimaConocida = await Geolocator.getLastKnownPosition();
      if (ultimaConocida != null) {
        final antiguedad = DateTime.now().difference(ultimaConocida.timestamp);
        if (antiguedad.inMinutes < 2) {
          return {
            'latitud': ultimaConocida.latitude,
            'longitud': ultimaConocida.longitude,
            'precision_metros': ultimaConocida.accuracy.round(),
            'obtenida_en': DateTime.now().toUtc().toIso8601String(),
          };
        }
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return {
        'latitud': posicion.latitude,
        'longitud': posicion.longitude,
        'precision_metros': posicion.accuracy.round(),
        'obtenida_en': DateTime.now().toUtc().toIso8601String(),
      };
    } catch (e) {
      debugPrint('LocationService: error obteniendo GPS ($e), usando coordenadas operativas');
      return _ubicacionFallback(e.toString());
    }
  }

  static Map<String, dynamic> _ubicacionFallback([String? motivo]) {
    return {
      'latitud': latitudPorDefecto,
      'longitud': longitudPorDefecto,
      'precision_metros': precisionPorDefecto,
      'obtenida_en': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

