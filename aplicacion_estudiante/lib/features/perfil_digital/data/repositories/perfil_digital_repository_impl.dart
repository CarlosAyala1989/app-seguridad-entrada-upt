import '../../domain/entities/perfil_digital.dart';
import '../../domain/repositories/perfil_digital_repository.dart';
import '../datasources/perfil_digital_remote_data_source.dart';
import '../mappers/perfil_digital_mapper.dart';

final class PerfilDigitalRepositoryImpl implements PerfilDigitalRepository {
  const PerfilDigitalRepositoryImpl(this._remoteDataSource);

  final PerfilDigitalRemoteDataSource _remoteDataSource;

  @override
  Future<PerfilDigital?> obtenerPerfilActual() async {
    final dto = await _remoteDataSource.obtenerPerfilActual();
    return dto?.toDomain();
  }
}
