import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/turno_model.dart';

class TurnosService {
  final http.Client _client;
  final SecureStorageService _storage;

  TurnosService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<TurnoModel> iniciarTurno(Map<String, dynamic> ubicacion) async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa.',
        statusCode: 401,
      );
    }

    final url = ApiConfig.uriFor(ApiConfig.turnosSeguridadPath);
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'ubicacion': ubicacion}),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final datos = body['datos'] as Map<String, dynamic>? ?? body;
      return TurnoModel.fromJson(datos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_INICIAR_TURNO',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo iniciar el turno.',
      statusCode: response.statusCode,
    );
  }

  Future<TurnoModel?> consultarTurnoActual() async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) return null;

    final url = ApiConfig.uriFor(ApiConfig.turnoActualSeguridadPath);
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final datos = body['datos'];
      if (datos == null) return null;
      return TurnoModel.fromJson(datos as Map<String, dynamic>);
    }

    return null;
  }

  Future<List<TurnoModel>> consultarTurnos() async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) return [];

    final url = ApiConfig.uriFor(ApiConfig.turnosSeguridadPath);
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
          .map((item) => TurnoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> cerrarTurno(int turnoId) async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa.',
        statusCode: 401,
      );
    }

    final url = ApiConfig.uriFor(ApiConfig.cerrarTurnoPath(turnoId));
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) return;

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};
    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_CERRAR_TURNO',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo cerrar el turno.',
      statusCode: response.statusCode,
    );
  }
}

