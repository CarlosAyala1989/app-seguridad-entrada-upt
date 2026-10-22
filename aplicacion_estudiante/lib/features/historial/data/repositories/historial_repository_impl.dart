import '../../domain/entities/registro_historial.dart';
import '../../domain/repositories/historial_repository.dart';
import '../datasources/historial_remote_data_source.dart';

final class HistorialRepositoryImpl implements HistorialRepository {
  const HistorialRepositoryImpl(this._remoteDataSource);

  final HistorialRemoteDataSource _remoteDataSource;

  @override
  Future<PaginaHistorial> obtenerPagina({
    required int pagina,
    required int limite,
    ResultadoIngreso? resultado,
  }) => _remoteDataSource.obtenerPagina(
    pagina: pagina,
    limite: limite,
    resultado: resultado,
  );
}
