import 'package:aplicacion_estudiante/features/login_estudiante/domain/failures/login_failure.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/repositories/login_estudiante_repository.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import 'package:aplicacion_estudiante/shared/utils/input_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginEstudianteRepository extends Mock
    implements LoginEstudianteRepository {}

void main() {
  test('(a) saneamiento efectivo: quita tabulaciones, espacios e impurezas', () {
    const entrada = '  \t Juan   \t Pérez\u0007  ';

    final resultado = InputSanitizer.sanitize(entrada);

    expect(resultado, 'Juan Pérez');
  });

  test('(b) interrupción de red: código inválido no llama al repositorio',
      () async {
    final repository = MockLoginEstudianteRepository();
    final useCase = VerificarIntranetUseCase(repository);

    // Código de 5 dígitos: viola la regla de negocio (exactamente 10).
    await expectLater(
      useCase(
        transaccionId: 'trx-1',
        codigo: '12345',
        contrasena: '123456',
        captcha: 'AB12',
      ),
      throwsA(isA<CodigoInvalidoFailure>()),
    );

    // El mock registra exactamente cero llamadas.
    verifyZeroInteractions(repository);
  });
}