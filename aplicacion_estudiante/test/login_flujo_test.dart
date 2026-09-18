import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/flujo_login.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/failures/login_failure.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/repositories/login_estudiante_repository.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/consultar_estado_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/iniciar_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/obtener_captcha_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/states/login_state.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/viewmodels/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginEstudianteRepository extends Mock
    implements LoginEstudianteRepository {}

void main() {
  late MockLoginEstudianteRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = MockLoginEstudianteRepository();
    viewModel = LoginViewModel(
      obtenerCaptchaUseCase: ObtenerCaptchaUseCase(repository),
      verificarIntranetUseCase: VerificarIntranetUseCase(repository),
      iniciarGoogleUseCase: IniciarGoogleUseCase(repository),
      consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(repository),
    );
  });

  tearDown(() => viewModel.dispose());

  test('(a) estado en frío: al iniciar no existe ninguna sesión previa', () {
    expect(viewModel.estadoActual, isA<LoginInitialState>());
    expect(viewModel.estadoActual, isNot(isA<LoginExitosoState>()));

    // No se consultó ni renovó sesión alguna, ni se tocó el repositorio.
    verifyZeroInteractions(repository);
  });

  test('(b) flujo exitoso: autentica y carga íntegra la autorización', () async {
    final verificacion = VerificacionIntranet(
      codigo: '2026087688',
      nombreApellidos: 'Estudiante de Prueba',
      verificacionIntranetId: 'ver-123',
      verificacionExpiraEn: DateTime(2030),
    );
    final autorizacion = AutorizacionGoogle(
      transaccionId: 'trx-google-1',
      urlAutorizacion: Uri.parse('https://accounts.example.com/auth'),
      expiraEn: DateTime(2030),
    );

    when(
      () => repository.verificarIntranet(
        transaccionId: any(named: 'transaccionId'),
        codigo: any(named: 'codigo'),
        contrasena: any(named: 'contrasena'),
        captcha: any(named: 'captcha'),
      ),
    ).thenAnswer((_) async => verificacion);
    when(
      () => repository.iniciarGoogle(
        verificacionIntranetId: any(named: 'verificacionIntranetId'),
      ),
    ).thenAnswer((_) async => autorizacion);

    await viewModel.verificarIntranet(
      transaccionId: 'trx-captcha-1',
      codigo: '2026087688',
      contrasena: '123456',
      captcha: 'AB12',
    );

    expect(viewModel.estadoActual, isA<LoginGooglePreparadoState>());
    final estado = viewModel.estadoActual as LoginGooglePreparadoState;
    expect(estado.transaccionId, autorizacion.transaccionId);
    expect(estado.urlAutorizacion, autorizacion.urlAutorizacion);
    expect(estado.expiraEn, autorizacion.expiraEn);

    verify(
      () => repository.verificarIntranet(
        transaccionId: 'trx-captcha-1',
        codigo: '2026087688',
        contrasena: '123456',
        captcha: 'AB12',
      ),
    ).called(1);
    verify(
      () => repository.iniciarGoogle(verificacionIntranetId: 'ver-123'),
    ).called(1);
  });

  test('(c) flujo denegado: credenciales rechazadas, sin peticiones extra', () async {
    when(
      () => repository.verificarIntranet(
        transaccionId: any(named: 'transaccionId'),
        codigo: any(named: 'codigo'),
        contrasena: any(named: 'contrasena'),
        captcha: any(named: 'captcha'),
      ),
    ).thenAnswer((_) => Future.error(const CredencialesInvalidasFailure()));

    await viewModel.verificarIntranet(
      transaccionId: 'trx-captcha-1',
      codigo: '2026087688',
      contrasena: '000000',
      captcha: 'AB12',
    );

    expect(viewModel.estadoActual, isA<LoginErrorState>());
    final estado = viewModel.estadoActual as LoginErrorState;
    expect(estado.mensaje, 'Credenciales de intranet no válidas.');

    verify(
      () => repository.verificarIntranet(
        transaccionId: any(named: 'transaccionId'),
        codigo: any(named: 'codigo'),
        contrasena: any(named: 'contrasena'),
        captcha: any(named: 'captcha'),
      ),
    ).called(1);
    verifyNever(
      () => repository.iniciarGoogle(
        verificacionIntranetId: any(named: 'verificacionIntranetId'),
      ),
    );
    verifyNever(() => repository.consultarEstadoGoogle(any()));
  });
}