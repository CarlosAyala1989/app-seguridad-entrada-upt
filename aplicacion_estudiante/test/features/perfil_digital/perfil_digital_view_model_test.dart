import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/entities/perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/states/perfil_digital_state.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const perfil = PerfilDigital(
    nombreCompleto: 'Estudiante de Prueba',
    codigoInstitucional: '2022000000',
    correoInstitucional: '2022000000@virtual.upt.pe',
    rol: 'STUDENT',
    escuela: 'Ingeniería de Sistemas',
    estadoVerificacion: 'VERIFIED',
    estadoAcceso: 'ACTIVE',
  );

  test('emite Loading y luego Data cuando el repositorio responde', () async {
    final viewModel = PerfilDigitalViewModel(
      obtenerPerfil: ObtenerPerfilDigital(
        _FakePerfilRepository(result: perfil),
      ),
    );
    final emittedFuture = viewModel.states.take(2).toList();

    await viewModel.cargar();
    final emitted = await emittedFuture;

    expect(emitted, hasLength(2));
    expect(emitted.first, isA<PerfilDigitalLoading>());
    expect(emitted.last, isA<PerfilDigitalData>());
    expect((emitted.last as PerfilDigitalData).perfil.nombreCompleto,
        'Estudiante de Prueba');

    await viewModel.dispose();
  });

  test('emite Empty cuando el repositorio no encuentra perfil', () async {
    final viewModel = PerfilDigitalViewModel(
      obtenerPerfil: const ObtenerPerfilDigital(
        _FakePerfilRepository(result: null),
      ),
    );
    final emittedFuture = viewModel.states.take(2).toList();

    await viewModel.cargar();
    final emitted = await emittedFuture;

    expect(emitted, hasLength(2));
    expect(emitted.first, isA<PerfilDigitalLoading>());
    expect(emitted.last, isA<PerfilDigitalEmpty>());

    await viewModel.dispose();
  });

  test('emite Error con reintento cuando el repositorio falla', () async {
    final viewModel = PerfilDigitalViewModel(
      obtenerPerfil: const ObtenerPerfilDigital(
        _FakePerfilRepository(
          failure: NetworkFailure('Sin conexión de prueba.'),
        ),
      ),
    );
    final emittedFuture = viewModel.states.take(2).toList();

    await viewModel.cargar();
    final emitted = await emittedFuture;

    expect(emitted, hasLength(2));
    expect(emitted.first, isA<PerfilDigitalLoading>());
    expect(emitted.last, isA<PerfilDigitalError>());
    final error = emitted.last as PerfilDigitalError;
    expect(error.message, 'Sin conexión de prueba.');
    expect(error.retry, isNotNull);

    await viewModel.dispose();
  });

  test('emite Error cuando el perfil no cumple los datos mínimos', () async {
    final viewModel = PerfilDigitalViewModel(
      obtenerPerfil: const ObtenerPerfilDigital(
        _FakePerfilRepository(
          result: PerfilDigital(
            nombreCompleto: '',
            codigoInstitucional: '2022000000',
            correoInstitucional: '2022000000@virtual.upt.pe',
            rol: 'STUDENT',
            escuela: 'Ingeniería de Sistemas',
            estadoVerificacion: 'VERIFIED',
            estadoAcceso: 'ACTIVE',
          ),
        ),
      ),
    );
    final emittedFuture = viewModel.states.take(2).toList();

    await viewModel.cargar();
    final emitted = await emittedFuture;

    expect(emitted.last, isA<PerfilDigitalError>());
    expect(
      (emitted.last as PerfilDigitalError).message,
      'La respuesta recibida no tiene el formato esperado.',
    );

    await viewModel.dispose();
  });
}

final class _FakePerfilRepository implements PerfilDigitalRepository {
  const _FakePerfilRepository({this.result, this.failure});

  final PerfilDigital? result;
  final Failure? failure;

  @override
  Future<PerfilDigital?> obtenerPerfilActual() async {
    if (failure case final currentFailure?) {
      throw currentFailure;
    }
    return result;
  }
}
