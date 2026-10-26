import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/biometria/data/local_auth_autenticador.dart';
import '../../features/biometria/data/preferencia_biometria_secure_storage.dart';
import '../../features/biometria/domain/usecases/bloqueo_biometrico_use_case.dart';
import '../../features/biometria/presentation/views/bloqueo_biometrico_gate.dart';
import '../../features/biometria/presentation/widgets/ajustes_biometria_tile.dart';
import '../../features/codigo_qr/data/datasources/codigo_qr_remote_data_source.dart';
import '../../features/codigo_qr/data/datasources/qr_offline_local_data_source.dart';
import '../../features/codigo_qr/data/datasources/qr_offline_remote_data_source.dart';
import '../../features/codigo_qr/data/repositories/codigo_qr_repository_impl.dart';
import '../../features/codigo_qr/data/repositories/qr_offline_repository_impl.dart';
import '../../features/codigo_qr/domain/usecases/generar_codigo_qr_use_case.dart';
import '../../features/codigo_qr/domain/usecases/qr_offline_use_cases.dart';
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
import '../../features/login_estudiante/presentation/views/bienvenida_page.dart';
import '../../features/login_estudiante/presentation/views/login_page.dart';
import '../../features/login_estudiante/presentation/views/sesion_gate.dart';
import '../../features/notificaciones/data/datasources/notificaciones_remote_data_source.dart';
import '../../features/notificaciones/data/repositories/notificaciones_repository_impl.dart';
import '../../features/notificaciones/domain/entities/notificacion.dart';
import '../../features/notificaciones/domain/usecases/notificaciones_use_cases.dart';
import '../../features/notificaciones/presentation/controllers/resumen_notificaciones_controller.dart';
import '../../features/notificaciones/presentation/viewmodels/bandeja_view_model.dart';
import '../../features/notificaciones/presentation/views/bandeja_notificaciones_page.dart';
import '../../features/notificaciones/presentation/views/detalle_notificacion_page.dart';
import '../../features/notificaciones/presentation/widgets/alerta_seguridad_banner.dart';
import '../../features/notificaciones/presentation/widgets/campana_notificaciones.dart';
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
            (await _loginRepository.renovarSesion(tokenRenovacion)).tokenAcceso,
      );

  /// Vinculación del QR sin conexión (una por teléfono y cuenta).
  static final QrOfflineRepositoryImpl _qrOffline = QrOfflineRepositoryImpl(
    remote: QrOfflineRemoteDataSourceImpl(
      httpGateway: _gateway,
      sessionTokenProvider: _tokenProvider,
    ),
    local: QrOfflineLocalDataSource(),
  );

  /// ID de la cuenta guardada en el teléfono (sirve también sin internet).
  static Future<int?> _usuarioActual() async =>
      (await _loginRepository.usuarioGuardado())?.id;

  /// Permite navegar al login desde la pantalla de bloqueo, que está por
  /// encima de todas las rutas.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final BloqueoBiometricoUseCase _bloqueo = BloqueoBiometricoUseCase(
    autenticador: LocalAuthAutenticador(),
    preferencias: const PreferenciaBiometriaSecureStorage(),
    haySesion: () async => await _sessionStorage.leerTokens() != null,
  );

  /// Revoca la sesión en el backend, borra los tokens locales (aunque no haya
  /// red) y deja solo la bienvenida en la pila de pantallas.
  static Future<void> _cerrarSesionYVolverAlLogin(NavigatorState? nav) async {
    await CerrarSesionUseCase(
      repository: _loginRepository,
      sessionStorage: _sessionStorage,
      borrarDatosOffline: _qrOffline.borrar,
    )();
    nav?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => buildBienvenidaPage()),
      (_) => false,
    );
  }

  /// Cubre la app con la pantalla de bloqueo biométrico cuando corresponde.
  static Widget envolverConBloqueo(BuildContext context, Widget? child) {
    return BloqueoBiometricoGate(
      debeBloquear: _bloqueo.debeBloquear,
      desbloquear: _bloqueo.desbloquear,
      onCerrarSesion: () =>
          _cerrarSesionYVolverAlLogin(navigatorKey.currentState),
      child: child ?? const SizedBox.shrink(),
    );
  }

  /// Pantalla inicial: restaura la sesión guardada o muestra el login.
  static Widget buildHome() {
    final restaurarSesion = RestaurarORenovarSesionUseCase(
      repository: _loginRepository,
      sessionStorage: _sessionStorage,
    );
    return SesionGate(
      restaurarSesion: restaurarSesion.call,
      construirLogin: (_) => buildBienvenidaPage(),
      construirInicio: (_) => buildPerfilDigitalPage(),
    );
  }

  /// Bienvenida institucional: desde aquí se abre el login o el aviso de
  /// privacidad.
  static Widget buildBienvenidaPage() {
    return Builder(
      builder: (context) => BienvenidaPage(
        onIniciarSesion: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => buildLoginPage())),
        onVerAvisoPrivacidad: () => abrirAvisoPrivacidad(context),
      ),
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
            // La bienvenida y el login salen de la pila: con "atrás" no se
            // vuelve a ellos.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => buildPerfilDigitalPage()),
              (_) => false,
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
    // Un solo controlador de avisos para la campana y la alerta destacada;
    // lo descarta la campana al salir de la pantalla.
    final avisos = ResumenNotificacionesController(
      consultarResumen: ConsultarResumenNotificacionesUseCase(_notificaciones),
      obtenerNotificaciones: ObtenerNotificacionesUseCase(_notificaciones),
    );

    return Builder(
      builder: (context) {
        return PerfilDigitalPage(
          viewModel: viewModel,
          onVerCodigoQr: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => buildCodigoQrPage())),
          onVerQrSinConexion: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => buildCodigoQrPage(sinConexion: true),
            ),
          ),
          onVerAvisoPrivacidad: () => abrirAvisoPrivacidad(context),
          onVerHistorial: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => buildHistorialPage())),
          onCerrarSesion: () =>
              _cerrarSesionYVolverAlLogin(Navigator.of(context)),
          accionExtra: CampanaNotificaciones(
            controller: avisos,
            onAbrirBandeja: () => abrirBandejaNotificaciones(context),
          ),
          encabezado: AlertaSeguridadBanner(
            controller: avisos,
            onRevisar: () => abrirBandejaNotificaciones(
              context,
              filtro: TipoNotificacion.intentoSospechoso,
            ),
          ),
          ajustes: AjustesBiometriaTile(
            estaDisponible: _bloqueo.estaDisponible,
            estaActivada: _bloqueo.estaActivada,
            activar: _bloqueo.activar,
            desactivar: _bloqueo.desactivar,
          ),
        );
      },
    );
  }

  static final NotificacionesRepositoryImpl _notificaciones =
      NotificacionesRepositoryImpl(
        NotificacionesRemoteDataSource(
          httpGateway: _gateway,
          sessionTokenProvider: _tokenProvider,
        ),
      );

  /// Abre la bandeja de avisos (US-20 y US-21); [filtro] permite abrirla
  /// directamente en un tipo de aviso.
  static Future<void> abrirBandejaNotificaciones(
    BuildContext context, {
    TipoNotificacion? filtro,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BandejaNotificacionesPage(
          viewModel: BandejaViewModel(
            obtenerNotificaciones: ObtenerNotificacionesUseCase(
              _notificaciones,
            ),
            filtroInicial: filtro,
          ),
          abrirDetalle: (context, notificacion) =>
              Navigator.of(context).push<Notificacion>(
                MaterialPageRoute<Notificacion>(
                  builder: (_) => DetalleNotificacionPage(
                    notificacion: notificacion,
                    obtenerDetalle: ObtenerDetalleNotificacionUseCase(
                      _notificaciones,
                    ).call,
                    marcarLeida: MarcarNotificacionLeidaUseCase(
                      _notificaciones,
                    ).call,
                  ),
                ),
              ),
        ),
      ),
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

  static Widget buildCodigoQrPage({bool sinConexion = false}) {
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
      prepararQrOffline: PrepararQrOfflineUseCase(
        repository: _qrOffline,
        usuarioActual: _usuarioActual,
      ),
      obtenerVinculacionOffline: ObtenerVinculacionOfflineUseCase(
        repository: _qrOffline,
        usuarioActual: _usuarioActual,
      ),
    );
    return Builder(
      builder: (context) => CodigoQrPage(
        viewModel: viewModel,
        onVerAvisoPrivacidad: () => abrirAvisoPrivacidad(context),
        iniciarSinConexion: sinConexion,
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
