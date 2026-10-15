import '../../../ubicacion/domain/entities/ubicacion_dispositivo.dart';
import '../../domain/entities/codigo_qr.dart';
import '../../domain/repositories/codigo_qr_repository.dart';
import '../datasources/codigo_qr_remote_data_source.dart';

final class CodigoQrRepositoryImpl implements CodigoQrRepository {
  const CodigoQrRepositoryImpl(this._remoteDataSource);

  final CodigoQrRemoteDataSource _remoteDataSource;

  @override
  Future<CodigoQr> generar(UbicacionDispositivo ubicacion) async {
    final dto = await _remoteDataSource.generar(ubicacion);
    return dto.toDomain();
  }

  @override
  Future<void> revocarActual() => _remoteDataSource.revocarActual();
}
