import 'package:flutter/foundation.dart';

import '../../domain/entities/vinculacion_qr_offline.dart';
import '../../domain/repositories/qr_offline_repository.dart';
import '../datasources/qr_offline_local_data_source.dart';
import '../datasources/qr_offline_remote_data_source.dart';

final class QrOfflineRepositoryImpl implements QrOfflineRepository {
  QrOfflineRepositoryImpl({
    required QrOfflineRemoteDataSource remote,
    required QrOfflineLocalDataSource local,
    String? plataforma,
    DateTime Function()? ahora,
  }) : _remote = remote,
       _local = local,
       _plataforma = plataforma ?? plataformaActual(),
       _ahora = ahora ?? DateTime.now;

  final QrOfflineRemoteDataSource _remote;
  final QrOfflineLocalDataSource _local;
  final String _plataforma;
  final DateTime Function() _ahora;

  /// Valor de `plataforma` que acepta la API.
  static String plataformaActual() {
    if (kIsWeb) return 'WEB';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ANDROID',
      TargetPlatform.iOS => 'IOS',
      _ => 'OTRA',
    };
  }

  @override
  Future<VinculacionQrOffline> preparar({required int usuarioId}) async {
    final identificador = await _local.identificadorDispositivo();
    final dto = await _remote.preparar(
      identificadorDispositivo: identificador,
      plataforma: _plataforma,
    );
    final recibidoEn = _ahora();
    final vinculacion = VinculacionQrOffline(
      usuarioId: usuarioId,
      dispositivoId: dto.dispositivoId,
      secreto: dto.secreto,
      periodoSegundos: dto.periodoSegundos,
      desfaseRelojMs:
          dto.horaServidor.millisecondsSinceEpoch -
          recibidoEn.millisecondsSinceEpoch,
    );
    // Cada preparación trae un secreto nuevo: se reemplaza el guardado.
    await _local.guardar(vinculacion);
    return vinculacion;
  }

  @override
  Future<VinculacionQrOffline?> recuperar(int usuarioId) async {
    final guardada = await _local.leer();
    if (guardada == null || guardada.usuarioId != usuarioId) return null;
    return guardada;
  }

  @override
  Future<void> borrar() => _local.borrar();
}
