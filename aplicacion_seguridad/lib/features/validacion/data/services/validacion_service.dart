import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/resultado_validacion_model.dart';

class ValidacionService {
  final http.Client _client;
  final SecureStorageService _storage;

  ValidacionService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<ResultadoValidacionModel> validarIngreso({
    required String codigoQr,
    required String puntoAccesoCodigo,
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

    final url = ApiConfig.uriFor(ApiConfig.validarIngresoPath);
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'codigo_qr': codigoQr,
        'punto_acceso_codigo': puntoAccesoCodigo,
        'ubicacion': ubicacion,
      }),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>
        : {};

    // El resultado de negocio puede responder 200 tanto para AUTORIZADO como para DENEGADO
    if (response.statusCode == 200) {
      return ResultadoValidacionModel.fromJson(body);
    }

    // Errores HTTP de protocolo o validación
    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_VALIDACION',
      mensaje: error?['mensaje'] as String? ?? 'No se pudo procesar la validación.',
      statusCode: response.statusCode,
    );
  }
}
