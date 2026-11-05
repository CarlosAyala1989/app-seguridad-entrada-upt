import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../models/incidencia_model.dart';

class IncidenciasService {
  final http.Client _client;
  final SecureStorageService _storage;

  IncidenciasService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<IncidenciaModel> registrarIncidencia({
    required int registroId,
    required String tipo,
    required String observacion,
    String? claveIdempotencia,
  }) async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa para registrar la incidencia.',
        statusCode: 401,
      );
    }

    final idempotencia = claveIdempotencia ?? UuidGenerator.nuevoV4();

    final url = ApiConfig.uriFor(ApiConfig.registrarIncidenciaPath(registroId));
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'observacion': observacion.trim(),
        'clave_idempotencia': idempotencia,
      }),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final datos = body['datos'] as Map<String, dynamic>? ?? body;
      return IncidenciaModel.fromJson(datos);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_REGISTRAR_INCIDENCIA',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo registrar la incidencia.',
      statusCode: response.statusCode,
    );
  }

  Future<List<IncidenciaModel>> consultarIncidenciasValidacion(int registroId) async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa.',
        statusCode: 401,
      );
    }

    final url = ApiConfig.uriFor(ApiConfig.consultarIncidenciasValidacionPath(registroId));
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200) {
      final lista = body['datos'] as List<dynamic>? ?? [];
      return lista
          .map((item) => IncidenciaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_CONSULTAR_INCIDENCIAS',
      mensaje: error?['mensaje'] as String? ?? 'No se pudieron consultar las incidencias.',
      statusCode: response.statusCode,
    );
  }
}
