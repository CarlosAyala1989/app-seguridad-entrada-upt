import '../../domain/entities/perfil_digital.dart';

sealed class PerfilDigitalState {
  const PerfilDigitalState();
}

final class PerfilDigitalLoading extends PerfilDigitalState {
  const PerfilDigitalLoading();
}

final class PerfilDigitalData extends PerfilDigitalState {
  const PerfilDigitalData(this.perfil);

  final PerfilDigital perfil;
}

final class PerfilDigitalEmpty extends PerfilDigitalState {
  const PerfilDigitalEmpty();
}

final class PerfilDigitalError extends PerfilDigitalState {
  const PerfilDigitalError({required this.message, required this.retry});

  final String message;
  final Future<void> Function() retry;
}
