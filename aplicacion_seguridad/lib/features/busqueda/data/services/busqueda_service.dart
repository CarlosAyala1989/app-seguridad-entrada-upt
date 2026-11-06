import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/usuario_busqueda_model.dart';

class BusquedaService {
  final http.Client _client;
  final SecureStorageService _storage;

  BusquedaService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<UsuarioBusquedaModel?> buscarIdentidadSeguridad({
    String? codigo,
    String? correo,
    required String motivo,
    required Map<String, dynamic> ubicacion,
  }) async {
    final token = await _storage.obtenerTokenAcceso();
    if (token == null) {
      throw const ApiException(
        codigo: 'NO_AUTENTICADO',
        mensaje: 'No hay una sesión activa de personal de seguridad.',
        statusCode: 401,
      );
    }

    final Map<String, dynamic> requestBody = {
      if (codigo != null && codigo.trim().isNotEmpty)
        'codigo': codigo.trim().toUpperCase(),
      if (correo != null && correo.trim().isNotEmpty)
        'correo': correo.trim().toLowerCase(),
      'motivo': motivo.trim(),
      'ubicacion': ubicacion,
    };

    final url = ApiConfig.uriFor(ApiConfig.busquedaManualSeguridadPath);
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    if (response.statusCode == 200) {
      final datos = body['datos'];
      if (datos == null) return null;
      return UsuarioBusquedaModel.fromJson(datos as Map<String, dynamic>);
    }

    if (response.statusCode == 429) {
      throw const ApiException(
        codigo: 'LIMITE_BUSQUEDA_MANUAL',
        mensaje:
            'Límite de 20 búsquedas por minuto alcanzado. Por favor espera antes de intentar nuevamente.',
        statusCode: 429,
      );
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_BUSQUEDA',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo realizar la búsqueda.',
      statusCode: response.statusCode,
    );
  }
}

