import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/flujo_login.dart';
import '../../domain/usecases/consultar_estado_google_use_case.dart';
import '../../domain/usecases/iniciar_google_use_case.dart';
import '../../domain/usecases/obtener_captcha_use_case.dart';
import '../../domain/usecases/verificar_intranet_use_case.dart';
import '../states/login_state.dart';

final class LoginViewModel {
  LoginViewModel({
    required ObtenerCaptchaUseCase obtenerCaptchaUseCase,
    required VerificarIntranetUseCase verificarIntranetUseCase,
    required IniciarGoogleUseCase iniciarGoogleUseCase,
    required ConsultarEstadoGoogleUseCase consultarEstadoGoogleUseCase,
  }) : _obtenerCaptchaUseCase = obtenerCaptchaUseCase,
       _verificarIntranetUseCase = verificarIntranetUseCase,
       _iniciarGoogleUseCase = iniciarGoogleUseCase,
       _consultarEstadoGoogleUseCase = consultarEstadoGoogleUseCase {
    _emitir(const LoginInitialState());
  }

  final ObtenerCaptchaUseCase _obtenerCaptchaUseCase;
  final VerificarIntranetUseCase _verificarIntranetUseCase;
  final IniciarGoogleUseCase _iniciarGoogleUseCase;
  final ConsultarEstadoGoogleUseCase _consultarEstadoGoogleUseCase;

  final _stateController = StreamController<LoginState>.broadcast();
  LoginState _estadoActual = const LoginInitialState();

  Timer? _pollingTimer;

  Stream<LoginState> get estado => _stateController.stream;
  LoginState get estadoActual => _estadoActual;

  void _emitir(LoginState nuevoEstado) {
    _estadoActual = nuevoEstado;
    if (!_stateController.isClosed) {
      _stateController.add(nuevoEstado);
    }
  }

  /// 1. Solicita un nuevo CAPTCHA para iniciar el flujo.
  Future<void> cargarCaptcha() async {
    _cancelarPolling();
    _emitir(const LoginCargandoCaptchaState());

    try {
      final captcha = await _obtenerCaptchaUseCase();
      _emitir(LoginCaptchaListoState(captcha));
    } on Failure catch (e) {
      _emitir(LoginErrorState(mensaje: e.message));
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'Error inesperado al obtener el CAPTCHA.',
        ),
      );
    }
  }

  /// 2. Valida las credenciales de intranet y el CAPTCHA ingresado.
  Future<void> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) async {
    final codigoLimpio = codigo.trim();
    final contrasenaLimpia = contrasena.trim();
    final captchaLimpio = captcha.trim();

    if (codigoLimpio.length != 10) {
      _emitir(
        const LoginErrorState(
          mensaje: 'El código institucional debe tener 10 dígitos.',
        ),
      );
      return;
    }

    if (contrasenaLimpia.isEmpty || contrasenaLimpia.length > 6) {
      _emitir(
        const LoginErrorState(
          mensaje: 'La contraseña de intranet debe tener de 1 a 6 dígitos.',
        ),
      );
      return;
    }

    if (captchaLimpio.isEmpty || captchaLimpio.length > 5) {
      _emitir(
        const LoginErrorState(
          mensaje: 'El CAPTCHA debe tener entre 1 y 5 caracteres.',
        ),
      );
      return;
    }

    _emitir(const LoginVerificandoIntranetState());

    try {
      final verificacion = await _verificarIntranetUseCase(
        transaccionId: transaccionId,
        codigo: codigoLimpio,
        contrasena: contrasenaLimpia,
        captcha: captchaLimpio,
      );

      // Una vez verificada la intranet, iniciamos automáticamente la transacción Google.
      await _iniciarGoogle(verificacion.verificacionIntranetId);
    } on Failure catch (e) {
      _emitir(LoginErrorState(mensaje: e.message));
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'Ocurrió un error al verificar con la intranet.',
        ),
      );
    }
  }

  /// 3. Inicia la transacción de Google y lanza el navegador externo.
  Future<void> _iniciarGoogle(String verificacionIntranetId) async {
    try {
      final autorizacion = await _iniciarGoogleUseCase(
        verificacionIntranetId: verificacionIntranetId,
      );

      _emitir(
        LoginEsperandoGoogleState(
          transaccionId: autorizacion.transaccionId,
          urlAutorizacion: autorizacion.urlAutorizacion,
        ),
      );

      await abrirNavegadorGoogle(autorizacion.urlAutorizacion);

      _iniciarPollingGoogle(
        transaccionId: autorizacion.transaccionId,
        expiraEn: autorizacion.expiraEn,
      );
    } on Failure catch (e) {
      _emitir(LoginErrorState(mensaje: e.message));
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'No se pudo iniciar el proceso con Google Workspace.',
        ),
      );
    }
  }

  /// Abre la URL en el navegador externo del dispositivo.
  Future<void> abrirNavegadorGoogle(Uri url) async {
    try {
      final puedeAbrir = await canLaunchUrl(url);
      if (puedeAbrir) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _emitir(
          const LoginErrorState(
            mensaje: 'No se pudo abrir el navegador web externo.',
          ),
        );
      }
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'Ocurrió un problema al abrir el navegador.',
        ),
      );
    }
  }

  /// 4. Polling cada 2 segundos hasta COMPLETA, ERROR o vencimiento.
  void _iniciarPollingGoogle({
    required String transaccionId,
    required DateTime expiraEn,
  }) {
    _cancelarPolling();

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      // Validar si la transacción expiró por tiempo límite del contrato
      if (DateTime.now().isAfter(expiraEn)) {
        _cancelarPolling();
        _emitir(
          const LoginErrorState(
            mensaje: 'El tiempo límite para iniciar con Google ha expirado.',
          ),
        );
        return;
      }

      try {
        final resultado = await _consultarEstadoGoogleUseCase(transaccionId);

        switch (resultado.estado) {
          case EstadoGoogle.pendiente:
          case EstadoGoogle.procesando:
            // Sigue en espera, la siguiente iteración del timer volverá a consultar
            break;

          case EstadoGoogle.completa:
            _cancelarPolling();
            if (resultado.sesion != null) {
              _emitir(LoginExitosoState(resultado.sesion!.usuario));
            } else {
              _emitir(
                const LoginErrorState(
                  mensaje: 'No se recibió la sesión del estudiante.',
                ),
              );
            }
            break;

          case EstadoGoogle.error:
            _cancelarPolling();
            _emitir(
              LoginErrorState(
                mensaje:
                    resultado.errorMensaje ??
                    'Error al completar autenticación con Google.',
              ),
            );
            break;
        }
      } on Failure catch (e) {
        _cancelarPolling();
        _emitir(LoginErrorState(mensaje: e.message));
      } catch (_) {
        // En caso de micro-caída de red durante el polling, no detenemos inmediatamente el timer
      }
    });
  }

  void _cancelarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Libera los recursos y detiene el temporizador.
  void dispose() {
    _cancelarPolling();
    _stateController.close();
  }
}
