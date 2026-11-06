import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/bloqueo_model.dart';
import '../models/regla_acceso_model.dart';

class AdministracionService {
  final http.Client _client;
  final SecureStorageService _storage;

  AdministracionService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<String> _obtenerTokenAdmin() async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa de administrador.',
        statusCode: 401,
      );
    }
    return token;
  }

  // --- Issue #19: Búsqueda y Detalle de Usuarios desde Administración ---

  Future<List<Map<String, dynamic>>> consultarUsuariosAdmin({
    String? buscar,
    String? estado,
    int pagina = 1,
    int limite = 20,
  }) async {
    final token = await _obtenerTokenAdmin();

    final query = <String, String>{
      'pagina': '$pagina',
      'limite': '$limite',
      if (buscar != null && buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
      if (estado != null && estado.isNotEmpty) 'estado': estado,
    };

    final url = ApiConfig.uriFor(ApiConfig.usuariosAdminPath, query);
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = body['datos'] as List<dynamic>? ?? [];
      return List<Map<String, dynamic>>.from(lista);
    }

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};
    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_ADMIN_USUARIOS',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo buscar usuarios.',
      statusCode: response.statusCode,
    );
  }

  // --- Issue #20: Bloqueos y Rehabilitación de Identidades ---

  Future<BloqueoModel> bloquearUsuario({
    required int usuarioId,
    required String motivo,
    DateTime? vigenteHasta,
  }) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(ApiConfig.bloqueosUsuarioAdminPath(usuarioId));
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'motivo': motivo.trim(),
        'vigente_hasta': vigenteHasta?.toIso8601String(),
        'confirmacion': true, // Confirmación estricta requerida por el backend
      }),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final datos = body['datos'] as Map<String, dynamic>? ?? body;
      return BloqueoModel.fromJson(datos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_BLOQUEO',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo registrar el bloqueo.',
      statusCode: response.statusCode,
    );
  }

  Future<List<BloqueoModel>> consultarBloqueosUsuario(int usuarioId) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(ApiConfig.bloqueosUsuarioAdminPath(usuarioId));
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = body['datos'] as List<dynamic>? ?? [];
      return lista
          .map((item) => BloqueoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<BloqueoModel> rehabilitarBloqueo({
    required int usuarioId,
    required int bloqueoId,
    required String motivo,
  }) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(
        ApiConfig.rehabilitarBloqueoAdminPath(usuarioId, bloqueoId));
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'motivo': motivo.trim(),
        'confirmacion': true,
      }),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200) {
      final datos = body['datos'] as Map<String, dynamic>? ?? body;
      return BloqueoModel.fromJson(datos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_REHABILITAR',
      mensaje:
          error?['mensaje'] as String? ?? 'No se pudo rehabilitar la identidad.',
      statusCode: response.statusCode,
    );
  }

  // --- Issue #22: Reglas Configurables de Acceso ---

  Future<List<ReglaAccesoModel>> consultarReglasAcceso({
    int pagina = 1,
    int limite = 20,
  }) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(ApiConfig.reglasAccesoAdminPath, {
      'pagina': '$pagina',
      'limite': '$limite',
    });
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = body['datos'] as List<dynamic>? ?? [];
      return lista
          .map((item) => ReglaAccesoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<ReglaAccesoModel> crearReglaAcceso(Map<String, dynamic> datos) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(ApiConfig.reglasAccesoAdminPath);
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resDatos = body['datos'] as Map<String, dynamic>? ?? body;
      return ReglaAccesoModel.fromJson(resDatos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_CREAR_REGLA',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo crear la regla de acceso.',
      statusCode: response.statusCode,
    );
  }

  Future<ReglaAccesoModel> actualizarReglaAcceso(
      int id, Map<String, dynamic> datos) async {
    final token = await _obtenerTokenAdmin();

    final url = ApiConfig.uriFor(ApiConfig.detalleReglaAccesoAdminPath(id));
    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200) {
      final resDatos = body['datos'] as Map<String, dynamic>? ?? body;
      return ReglaAccesoModel.fromJson(resDatos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_ACTUALIZAR_REGLA',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo actualizar la regla.',
      statusCode: response.statusCode,
    );
  }

  // --- Puertas y Guardias ---

  Future<List<Map<String, dynamic>>> consultarPuntosAcceso() async {
    final token = await _obtenerTokenAdmin();
    final url = ApiConfig.uriFor(ApiConfig.puntosAccesoAdminPath, {'limite': '100'});
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = body['datos'] as List<dynamic>? ?? [];
      return List<Map<String, dynamic>>.from(lista);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> consultarGuardias() async {
    final token = await _obtenerTokenAdmin();
    final url = ApiConfig.uriFor(ApiConfig.guardiasAdminPath);
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final lista = body['datos'] as List<dynamic>? ?? [];
      return List<Map<String, dynamic>>.from(lista);
    }
    return [];
  }

  Future<Map<String, dynamic>> crearGuardia(Map<String, dynamic> datos) async {
    final token = await _obtenerTokenAdmin();
    final url = ApiConfig.uriFor(ApiConfig.guardiasAdminPath);
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body['datos'] as Map<String, dynamic>? ?? body;
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_CREAR_GUARDIA',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo registrar el guardia.',
      statusCode: response.statusCode,
    );
  }
}

