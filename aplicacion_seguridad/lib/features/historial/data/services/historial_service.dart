import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/registro_historial_model.dart';

class HistorialService {
  final http.Client _client;
  final SecureStorageService _storage;

  HistorialService({
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? FlutterSecureStorageService();

  Future<List<RegistroHistorialModel>> consultarIngresosRecientes({
    int pagina = 1,
    int limite = 20,
    String? puntoAccesoCodigo,
    int? turnoId,
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

    final query = <String, String>{
      'pagina': '$pagina',
      'limite': '$limite',
      if (puntoAccesoCodigo != null && puntoAccesoCodigo.isNotEmpty)
        'punto_acceso_codigo': puntoAccesoCodigo,
      if (turnoId != null) 'turno_id': '$turnoId',
      'latitud': '${ubicacion['latitud']}',
      'longitud': '${ubicacion['longitud']}',
      'precision_metros': '${ubicacion['precision_metros']}',
      'obtenida_en': '${ubicacion['obtenida_en']}',
    };

    final url = ApiConfig.uriFor(ApiConfig.ingresosRecientesPath, query);
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
          .map((item) =>
              RegistroHistorialModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      codigo: error?['codigo'] as String? ?? 'ERROR_CONSULTAR_HISTORIAL',
      mensaje: error?['mensaje'] as String? ??
          'No se pudo consultar el historial de validaciones recientes.',
      statusCode: response.statusCode,
    );
  }
}

