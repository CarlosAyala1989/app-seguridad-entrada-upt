import '../../../../core/error/failure.dart';

/// Lee la respuesta de `POST /codigos-qr/preparar-offline` (campo `datos`).
final class PreparacionQrOfflineDto {
  const PreparacionQrOfflineDto({
    required this.dispositivoId,
    required this.secreto,
    required this.horaServidor,
    required this.periodoSegundos,
  });

  factory PreparacionQrOfflineDto.fromJson(Map<String, Object?> json) {
    final dispositivo = json['dispositivo_id'];
    final secreto = json['secreto'];
    final hora = DateTime.tryParse('${json['hora_servidor']}');
    final periodo = json['periodo_segundos'];
    if (dispositivo is! int ||
        secreto is! String ||
        !_secretoValido.hasMatch(secreto) ||
        hora == null ||
        periodo is! int ||
        periodo <= 0) {
      throw const DataFailure();
    }
    return PreparacionQrOfflineDto(
      dispositivoId: dispositivo,
      secreto: secreto,
      horaServidor: hora,
      periodoSegundos: periodo,
    );
  }

  /// 32 bytes en Base64URL sin relleno = 43 caracteres.
  static final _secretoValido = RegExp(r'^[A-Za-z0-9_-]{43}$');

  final int dispositivoId;
  final String secreto;
  final DateTime horaServidor;
  final int periodoSegundos;
}
