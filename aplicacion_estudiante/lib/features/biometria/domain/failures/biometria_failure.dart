import '../../../../core/error/failure.dart';

final class BiometriaNoDisponibleFailure extends Failure {
  const BiometriaNoDisponibleFailure([
    super.message =
        'Este teléfono no tiene huella ni rostro configurados para '
        'desbloquear la aplicación.',
  ]);
}
