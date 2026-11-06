import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envUrl = String.fromEnvironment('URL_API_UPT');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) {
      return _envUrl;
    }
    if (kReleaseMode) {
      return 'https://api-moviles.fottuto.men/api';
    }
    // En desarrollo local por defecto se apunta a la API remota desplegada
    return 'https://api-moviles.fottuto.men/api';
  }

  // Autenticación
  static const String iniciarSesionPath = '/autenticacion/iniciar-sesion';
  static const String renovarSesionPath = '/autenticacion/renovar-sesion';
  static const String consultarSesionPath = '/autenticacion/sesion';
  static const String cerrarSesionPath = '/autenticacion/cerrar-sesion';

  // Validación de ingresos y recientes (Issues #9, #10, #15, #18, #24)
  static const String validarIngresoPath = '/ingresos/validar';
  static const String validarQrPath = validarIngresoPath;
  static const String ingresosRecientesPath = '/ingresos/recientes';

  // Búsqueda manual controlada para seguridad (Issue #14)
  static const String busquedaManualSeguridadPath = '/seguridad/identidades/buscar';

  // Turnos de guardia (Issue #18)
  static const String turnosSeguridadPath = '/seguridad/turnos';
  static const String turnoActualSeguridadPath = '/seguridad/turnos/actual';
  static String cerrarTurnoPath(int id) => '/seguridad/turnos/$id/cerrar';

  // Incidencias (Issue #16)
  static String registrarIncidenciaPath(int registroId) =>
      '/ingresos/$registroId/incidencias';
  static String consultarIncidenciasValidacionPath(int registroId) =>
      '/ingresos/$registroId/incidencias';
  static const String incidenciasAdminPath = '/administracion/incidencias';

  // Administración: Usuarios y Bloqueos (Issues #19, #20)
  static const String usuariosAdminPath = '/administracion/usuarios';
  static String detalleUsuarioAdminPath(int id) =>
      '/administracion/usuarios/$id';
  static String bloqueosUsuarioAdminPath(int usuarioId) =>
      '/administracion/usuarios/$usuarioId/bloqueos';
  static String rehabilitarBloqueoAdminPath(int usuarioId, int bloqueoId) =>
      '/administracion/usuarios/$usuarioId/bloqueos/$bloqueoId/rehabilitar';

  // Administración: Reglas de acceso (Issue #22)
  static const String reglasAccesoAdminPath = '/administracion/reglas-acceso';
  static String detalleReglaAccesoAdminPath(int id) =>
      '/administracion/reglas-acceso/$id';

  // Administración: Puertas y Guardias
  static const String puntosAccesoAdminPath = '/administracion/puntos-acceso';
  static const String guardiasAdminPath = '/administracion/guardias';
  static const String comprobarUbicacionSeguridadPath =
      '/seguridad/comprobar-ubicacion';

  static Uri uriFor(String path, [Map<String, String>? queryParameters]) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$cleanPath');
    return queryParameters == null
        ? uri
        : uri.replace(queryParameters: queryParameters);
  }
}
