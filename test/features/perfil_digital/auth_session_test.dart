import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/states/perfil_digital_state.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';

// 1. Doble de prueba (Mock) que sustituye al repositorio sin usar red ni emulador
class _MockPerfilRepository extends Mock implements PerfilDigitalRepository {}

void main() {
  late _MockPerfilRepository mockRepository;
  late ObtenerPerfilDigital useCase;
  late PerfilDigitalViewModel viewModel;

  setUp(() {
    mockRepository = _MockPerfilRepository();
    useCase = ObtenerPerfilDigital(mockRepository);
    viewModel = PerfilDigitalViewModel(obtenerPerfil: useCase);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test(
    'emite PerfilDigitalError cuando la autenticación falla (401 Unauthorized)',
    () async {
      // 2. Simula que el repositorio arroja fallo de no autorizado (sesión inválida)
      when(
        () => mockRepository.obtenerPerfilActual(),
      ).thenThrow(const UnauthorizedFailure('Sesión no autorizada'));

      // 3. Prepara la escucha del Stream para verificar que pase por Loading y termine en Error
      final expectativaDeEstados = expectLater(
        viewModel.states,
        emitsInOrder([
          isA<PerfilDigitalLoading>(),
          isA<PerfilDigitalError>().having(
            (e) => e.message,
            'message',
            'Sesión no autorizada',
          ),
        ]),
      );

      // 4. Ejecuta la acción de cargar
      await viewModel.cargar();

      // 5. Confirma que se emitieron los estados esperados
      await expectativaDeEstados;

      // 6. Verifica que el caso de uso consultó el repositorio exactamente 1 vez
      verify(() => mockRepository.obtenerPerfilActual()).called(1);
    },
  );
}
