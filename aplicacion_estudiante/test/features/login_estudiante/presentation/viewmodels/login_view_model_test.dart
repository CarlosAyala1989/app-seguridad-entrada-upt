import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/flujo_login.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/sesion_estudiante.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/usuario.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/repositories/login_estudiante_repository.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/consultar_estado_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/iniciar_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/obtener_captcha_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/states/login_state.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/viewmodels/login_view_model.dart';

final class FakeLoginEstudianteRepository implements LoginEstudianteRepository {
  @override
  Future<CaptchaIntranet> obtenerCaptcha() async {
    return CaptchaIntranet(
      transaccionId: 'uuid-fake',
      imagenBase64:
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      tipoImagen: 'image/png',
      expiraEn: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<VerificacionIntranet> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) async {
    return VerificacionIntranet(
      codigo: codigo,
      nombreApellidos: 'ESTUDIANTE DE PRUEBA',
      verificacionIntranetId: 'verif-id-fake',
      verificacionExpiraEn: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<AutorizacionGoogle> iniciarGoogle({
    required String verificacionIntranetId,
  }) async {
    return AutorizacionGoogle(
      transaccionId: 'google-trans-id',
      urlAutorizacion: Uri.parse('https://accounts.google.com'),
      expiraEn: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  @override
  Future<ResultadoEstadoGoogle> consultarEstadoGoogle(
    String transaccionId,
  ) async {
    return const ResultadoEstadoGoogle(estado: EstadoGoogle.pendiente);
  }

  @override
  Future<SesionEstudiante> renovarSesion(String tokenRenovacion) =>
      throw UnimplementedError();

  @override
  Future<Usuario> consultarSesion(String tokenAcceso) =>
      throw UnimplementedError();

  @override
  Future<void> cerrarSesion(String tokenAcceso) async {}
}

void main() {
  group('LoginViewModel', () {
    late FakeLoginEstudianteRepository repository;
    late LoginViewModel viewModel;

    setUp(() {
      repository = FakeLoginEstudianteRepository();
      viewModel = LoginViewModel(
        obtenerCaptchaUseCase: ObtenerCaptchaUseCase(repository),
        verificarIntranetUseCase: VerificarIntranetUseCase(repository),
        iniciarGoogleUseCase: IniciarGoogleUseCase(repository),
        consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(repository),
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('estado inicial debe ser LoginInitialState', () {
      expect(viewModel.estadoActual, isA<LoginInitialState>());
    });

    test('cargarCaptcha transiciona a cargando y luego a listo', () async {
      final estados = <LoginState>[];
      final sub = viewModel.estado.listen(estados.add);

      await viewModel.cargarCaptcha();
      await Future<void>.delayed(Duration.zero);

      expect(estados.any((s) => s is LoginCargandoCaptchaState), isTrue);
      expect(viewModel.estadoActual, isA<LoginCaptchaListoState>());

      await sub.cancel();
    });

    test(
      'verificarIntranet rechaza códigos que no tengan 10 dígitos',
      () async {
        await viewModel.verificarIntranet(
          transaccionId: 'uuid',
          codigo: '12345',
          contrasena: '1234',
          captcha: '12',
        );

        expect(viewModel.estadoActual, isA<LoginErrorState>());
        final error = viewModel.estadoActual as LoginErrorState;
        expect(error.mensaje, contains('10 dígitos'));
      },
    );
  });
}
