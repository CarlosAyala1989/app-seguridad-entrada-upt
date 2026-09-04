import 'package:flutter/widgets.dart';

import '../../features/perfil_digital/data/datasources/perfil_digital_remote_data_source.dart';
import '../../features/perfil_digital/data/repositories/perfil_digital_repository_impl.dart';
import '../../features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import '../../features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import '../../features/perfil_digital/presentation/views/perfil_digital_page.dart';
import '../auth/session_token_provider.dart';
import '../network/api_config.dart';
import '../network/http_gateway.dart';

final class AppDependencies {
  const AppDependencies._();

  static Widget buildHome() {
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
