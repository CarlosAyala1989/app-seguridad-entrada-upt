import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';

/// No hay internet y este teléfono todavía no fue vinculado para el QR sin
/// conexión (o la vinculación guardada es de otra cuenta).
final class SinVinculacionOfflineFailure extends Failure {
  const SinVinculacionOfflineFailure([
    super.message = AppStrings.qrOfflineNotLinked,
  ]);
}
