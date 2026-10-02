import 'dart:async';

import 'package:flutter/foundation.dart';
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

  bool _pollingActivo = false;

  Stream<LoginState> get estado => _stateController.stream;
  LoginState get estadoActual => _estadoActual;

  void _emitir(LoginState nuevoEstado) {
    _estadoActual = nuevoEstado;
    if (!_stateController.isClosed) {
      _stateController.add(nuevoEstado);
    }
  }

  /// 1. Carga el CAPTCHA institucional.
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

  /// 2. Valida las credenciales de intranet y prepara la autorización de Google.
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

      // Prepara la URL de Google sin abrirla automáticamente
      await _prepararGoogle(verificacion.verificacionIntranetId);
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

  /// 3. Obtiene la URL de Google y emite el estado LoginGooglePreparadoState.
  Future<void> _prepararGoogle(String verificacionIntranetId) async {
    try {
      final autorizacion = await _iniciarGoogleUseCase(
        verificacionIntranetId: verificacionIntranetId,
      );

      _emitir(
        LoginGooglePreparadoState(
          transaccionId: autorizacion.transaccionId,
          urlAutorizacion: autorizacion.urlAutorizacion,
          expiraEn: autorizacion.expiraEn,
        ),
      );
    } on Failure catch (e) {
      _emitir(LoginErrorState(mensaje: e.message));
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'No se pudo preparar la autenticación con Google.',
        ),
      );
    }
  }

  /// 4. Acción directa del botón «Continuar con Google»: abre el navegador e inicia polling.
  Future<void> ejecutarContinuarGoogle({
    required Uri urlAutorizacion,
    required String transaccionId,
    required DateTime expiraEn,
  }) async {
    _emitir(
      LoginEsperandoGoogleState(
        transaccionId: transaccionId,
        urlAutorizacion: urlAutorizacion,
      ),
    );

    await abrirNavegadorGoogle(urlAutorizacion);
    unawaited(
      _iniciarPollingSecuencial(
        transaccionId: transaccionId,
        expiraEn: expiraEn,
      ),
    );
  }

  /// Abre la URL en el navegador externo respetando las reglas de Chrome/Web y móvil.
  Future<void> abrirNavegadorGoogle(Uri url) async {
    try {
      await launchUrl(
        url,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      _emitir(
        const LoginErrorState(
          mensaje: 'No se pudo abrir el navegador. Vuelve a intentarlo.',
        ),
      );
    }
  }

  /// 5. Polling secuencial: espera al menos 2s entre respuestas sin solapamientos.
  Future<void> _iniciarPollingSecuencial({
    required String transaccionId,
    required DateTime expiraEn,
  }) async {
    _cancelarPolling();
    _pollingActivo = true;

    while (_pollingActivo) {
      if (DateTime.now().isAfter(expiraEn)) {
        _pollingActivo = false;
        _emitir(
          const LoginErrorState(
            mensaje: 'El tiempo límite para autenticar con Google ha expirado.',
          ),
        );
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 2));
      if (!_pollingActivo) break;

      // Verificación de expiración tras la espera
      if (DateTime.now().isAfter(expiraEn)) {
        _pollingActivo = false;
        _emitir(
          const LoginErrorState(
            mensaje: 'El tiempo límite para autenticar con Google ha expirado.',
          ),
        );
        return;
      }

      try {
        final resultado = await _consultarEstadoGoogleUseCase(transaccionId);

        switch (resultado.estado) {
          case EstadoGoogle.pendiente:
          case EstadoGoogle.procesando:
            break;

          case EstadoGoogle.completa:
            _pollingActivo = false;
            if (resultado.sesion != null) {
              _emitir(LoginExitosoState(resultado.sesion!.usuario));
            } else {
              _emitir(
                const LoginErrorState(
                  mensaje: 'No se recibió la sesión del estudiante.',
                ),
              );
            }
            return;

          case EstadoGoogle.error:
            _pollingActivo = false;
            debugPrint('DETALLE ERROR GOOGLE: ${resultado.errorMensaje}');
            _emitir(
              LoginErrorState(
                mensaje:
                    resultado.errorMensaje ??
                    'Error al completar autenticación con Google.',
              ),
            );
            return;
        }
      } on Failure catch (e) {
        _pollingActivo = false;
        _emitir(LoginErrorState(mensaje: e.message));
        return;
      } catch (_) {
        // En micro-fallas de red continúa en la siguiente iteración sin abortar
      }
    }
  }

  void _cancelarPolling() {
    _pollingActivo = false;
  }

  void dispose() {
    _cancelarPolling();
    _stateController.close();
  }
}
