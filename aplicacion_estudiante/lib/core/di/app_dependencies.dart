import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/codigo_qr/data/datasources/codigo_qr_remote_data_source.dart';
import '../../features/codigo_qr/data/repositories/codigo_qr_repository_impl.dart';
import '../../features/codigo_qr/domain/usecases/generar_codigo_qr_use_case.dart';
import '../../features/codigo_qr/domain/usecases/revocar_codigo_qr_use_case.dart';
import '../../features/codigo_qr/presentation/viewmodels/codigo_qr_view_model.dart';
import '../../features/codigo_qr/presentation/views/codigo_qr_page.dart';

import '../../features/historial/data/datasources/historial_remote_data_source.dart';
import '../../features/historial/data/repositories/historial_repository_impl.dart';
import '../../features/historial/domain/usecases/obtener_historial_use_case.dart';
import '../../features/historial/presentation/viewmodels/historial_view_model.dart';
import '../../features/historial/presentation/views/historial_page.dart';
import '../../features/login_estudiante/data/datasources/login_estudiante_remote_data_source.dart';
import '../../features/login_estudiante/data/repositories/login_estudiante_repository_impl.dart';
import '../../features/login_estudiante/domain/usecases/cerrar_sesion_use_case.dart';
import '../../features/login_estudiante/domain/usecases/consultar_estado_google_use_case.dart';
import '../../features/login_estudiante/domain/usecases/iniciar_google_use_case.dart';
import '../../features/login_estudiante/domain/usecases/obtener_captcha_use_case.dart';
import '../../features/login_estudiante/domain/usecases/restaurar_o_renovar_sesion_use_case.dart';
import '../../features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import '../../features/login_estudiante/presentation/viewmodels/login_view_model.dart';
import '../../features/login_estudiante/presentation/views/login_page.dart';
import '../../features/login_estudiante/presentation/views/sesion_gate.dart';
import '../../features/perfil_digital/data/datasources/perfil_digital_remote_data_source.dart';
import '../../features/perfil_digital/data/repositories/perfil_digital_repository_impl.dart';
import '../../features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import '../../features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import '../../features/perfil_digital/presentation/views/perfil_digital_page.dart';
import '../../features/privacidad/data/aviso_privacidad_vigente.dart';
import '../../features/privacidad/presentation/views/aviso_privacidad_page.dart';
import '../../features/ubicacion/data/repositories/ubicacion_repository_impl.dart';
import '../../features/ubicacion/domain/repositories/ubicacion_repository.dart';
import '../../features/ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import '../auth/secure_session_storage.dart';
import '../auth/session_token_provider.dart';
import '../network/api_config.dart';
import '../network/http_gateway.dart';

final class AppDependencies {
  const AppDependencies._();

  static final HttpGateway _gateway = ApiHttpGateway(
    baseUrl: ApiConfig.baseUrl,
  );
  static const SecureSessionStorage _sessionStorage = SecureSessionStorage();
  static final LoginEstudianteRepositoryImpl _loginRepository =
      LoginEstudianteRepositoryImpl(
        remoteDataSource: LoginEstudianteRemoteDataSourceImpl(
          httpGateway: _gateway,
        ),
        sessionStorage: _sessionStorage,
      );

  /// Un único proveedor para toda la app, así las renovaciones simultáneas
  /// se comparten.
  static final SessionTokenProvider _tokenProvider =
      RenovableSessionTokenProvider(
        leerTokens: _sessionStorage.leerTokens,
        limpiar: _sessionStorage.limpiar,
        renovar: (tokenRenovacion) async =>
            (await _loginRepository.renovarSesion(tokenRenovacion))
                .tokenAcceso,
      );

  /// Pantalla inicial: restaura la sesión guardada o muestra el login.
  static Widget buildHome() {
    final restaurarSesion = RestaurarORenovarSesionUseCase(
      repository: _loginRepository,
      sessionStorage: _sessionStorage,
    );
    return SesionGate(
      restaurarSesion: restaurarSesion.call,
      construirLogin: (_) => buildLoginPage(),
      construirInicio: (_) => buildPerfilDigitalPage(),
    );
  }

  static Widget buildLoginPage() {
    final loginViewModel = LoginViewModel(
      obtenerCaptchaUseCase: ObtenerCaptchaUseCase(_loginRepository),
      verificarIntranetUseCase: VerificarIntranetUseCase(_loginRepository),
      iniciarGoogleUseCase: IniciarGoogleUseCase(_loginRepository),
      consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(
        _loginRepository,
      ),
    );

    return Builder(
      builder: (context) {
        return LoginPage(
          viewModel: loginViewModel,
          onLoginExitoso: (usuario) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => buildPerfilDigitalPage()),
            );
          },
        );
      },
    );
  }

  static Widget buildPerfilDigitalPage() {
    final dataSource = PerfilDigitalRemoteDataSourceImpl(
      httpGateway: _gateway,
      sessionTokenProvider: _tokenProvider,
    );
    final repository = PerfilDigitalRepositoryImpl(dataSource);
    final obtenerPerfil = ObtenerPerfilDigital(repository);
    final viewModel = PerfilDigitalViewModel(obtenerPerfil: obtenerPerfil);
    final cerrarSesion = CerrarSesionUseCase(
      repository: _loginRepository,
      sessionStorage: _sessionStorage,
    );

    return Builder(
      builder: (context) {
        return PerfilDigitalPage(
          viewModel: viewModel,
          onVerCodigoQr: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => buildCodigoQrPage()),
          ),
          onVerAvisoPrivacidad: () => abrirAvisoPrivacidad(context),
          onVerHistorial: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => buildHistorialPage()),
          ),
          onCerrarSesion: () async {
            // Revoca la sesión en el backend y borra los tokens locales,
            // aunque no haya red (ver LoginEstudianteRepositoryImpl).
            await cerrarSesion();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => buildLoginPage()),
              (_) => false,
            );
          },
        );
      },
    );
  }

  static Widget buildHistorialPage() {
    final repository = HistorialRepositoryImpl(
      HistorialRemoteDataSourceImpl(
        httpGateway: _gateway,
        sessionTokenProvider: _tokenProvider,
      ),
    );
    return HistorialPage(
      viewModel: HistorialViewModel(
        obtenerHistorial: ObtenerHistorialUseCase(repository),
      ),
    );
  }

  static Widget buildCodigoQrPage() {
    // La ubicación simulada solo existe en modo debug y con
    // --dart-define=UBICACION_SIMULADA=true (para probar fuera del campus).
    final UbicacionRepository ubicacion =
        kDebugMode && UbicacionSimuladaRepository.activada
        ? const UbicacionSimuladaRepository()
        : const UbicacionRepositoryImpl();
    final repository = CodigoQrRepositoryImpl(
      CodigoQrRemoteDataSourceImpl(
        httpGateway: _gateway,
        sessionTokenProvider: _tokenProvider,
      ),
    );
    final viewModel = CodigoQrViewModel(
      generarCodigoQr: GenerarCodigoQrUseCase(
        obtenerUbicacion: ObtenerUbicacionConfiableUseCase(ubicacion),
        repository: repository,
      ),
      revocarCodigoQr: RevocarCodigoQrUseCase(repository),
    );
    return Builder(
      builder: (context) => CodigoQrPage(
        viewModel: viewModel,
        onVerAvisoPrivacidad: () => abrirAvisoPrivacidad(context),
      ),
    );
  }

  /// Abre el aviso de privacidad vigente (US-24).
  static void abrirAvisoPrivacidad(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AvisoPrivacidadPage(aviso: avisoPrivacidadVigente),
      ),
    );
  }
}
