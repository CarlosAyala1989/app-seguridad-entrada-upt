import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../domain/repositories/perfil_digital_repository.dart';
import '../states/perfil_digital_state.dart';

final class PerfilDigitalViewModel {
  PerfilDigitalViewModel({required PerfilDigitalRepository repository})
      : _repository = repository;

  final PerfilDigitalRepository _repository;
  final StreamController<PerfilDigitalState> _states =
      StreamController<PerfilDigitalState>.broadcast();

  PerfilDigitalState currentState = const PerfilDigitalLoading();

  Stream<PerfilDigitalState> get states => _states.stream;

  Future<void> cargar() async {
    _emit(const PerfilDigitalLoading());
    try {
      final perfil = await _repository.obtenerPerfilActual();
      _emit(
        perfil == null
            ? const PerfilDigitalEmpty()
            : PerfilDigitalData(perfil),
      );
    } on Failure catch (failure) {
      _emit(PerfilDigitalError(message: failure.message, retry: cargar));
    } catch (_) {
      _emit(
        PerfilDigitalError(
          message: AppStrings.unexpectedError,
          retry: cargar,
        ),
      );
    }
  }

  void _emit(PerfilDigitalState state) {
    currentState = state;
    if (!_states.isClosed) {
      _states.add(state);
    }
  }

  Future<void> dispose() => _states.close();
}
