import 'package:flutter/material.dart';

import '../../features/login_estudiante/data/datasources/login_estudiante_remote_data_source.dart';
import '../../features/login_estudiante/data/repositories/login_estudiante_repository_impl.dart';
import '../../features/login_estudiante/domain/usecases/consultar_estado_google_use_case.dart';
import '../../features/login_estudiante/domain/usecases/iniciar_google_use_case.dart';
import '../../features/login_estudiante/domain/usecases/obtener_captcha_use_case.dart';
import '../../features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import '../../features/login_estudiante/presentation/viewmodels/login_view_model.dart';
import '../../features/login_estudiante/presentation/views/login_page.dart';
import '../../features/perfil_digital/data/datasources/perfil_digital_remote_data_source.dart';
import '../../features/perfil_digital/data/repositories/perfil_digital_repository_impl.dart';
import '../../features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import '../../features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import '../../features/perfil_digital/presentation/views/perfil_digital_page.dart';
import '../auth/secure_session_storage.dart';
import '../auth/session_token_provider.dart';
import '../network/api_config.dart';
import '../network/http_gateway.dart';

final class AppDependencies {
  const AppDependencies._();

  static Widget buildHome() {
    final gateway = IoHttpGateway(baseUrl: ApiConfig.baseUrl);
    const sessionStorage = SecureSessionStorage();

    final loginDataSource = LoginEstudianteRemoteDataSourceImpl(
      httpGateway: gateway,
    );
    final loginRepository = LoginEstudianteRepositoryImpl(
      remoteDataSource: loginDataSource,
      sessionStorage: sessionStorage,
    );

    final loginViewModel = LoginViewModel(
      obtenerCaptchaUseCase: ObtenerCaptchaUseCase(loginRepository),
      verificarIntranetUseCase: VerificarIntranetUseCase(loginRepository),
      iniciarGoogleUseCase: IniciarGoogleUseCase(loginRepository),
      consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(
        loginRepository,
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
    final gateway = IoHttpGateway(baseUrl: ApiConfig.baseUrl);
    const tokenProvider = DevelopmentSessionTokenProvider();
    final dataSource = PerfilDigitalRemoteDataSourceImpl(
      httpGateway: gateway,
      sessionTokenProvider: tokenProvider,
    );
    final repository = PerfilDigitalRepositoryImpl(dataSource);
    final obtenerPerfil = ObtenerPerfilDigital(repository);
    final viewModel = PerfilDigitalViewModel(obtenerPerfil: obtenerPerfil);
    return PerfilDigitalPage(viewModel: viewModel);
  }
}
