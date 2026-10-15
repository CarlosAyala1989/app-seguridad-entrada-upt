import '../repositories/codigo_qr_repository.dart';

final class RevocarCodigoQrUseCase {
  const RevocarCodigoQrUseCase(this._repository);

  final CodigoQrRepository _repository;

  Future<void> call() => _repository.revocarActual();
}
