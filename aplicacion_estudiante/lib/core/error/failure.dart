import '../../shared/l10n/app_strings.dart';

sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = AppStrings.networkError,
  ]);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = AppStrings.unauthorizedError,
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = AppStrings.serverError,
  ]);
}

final class DataFailure extends Failure {
  const DataFailure([
    super.message = AppStrings.dataError,
  ]);
}
