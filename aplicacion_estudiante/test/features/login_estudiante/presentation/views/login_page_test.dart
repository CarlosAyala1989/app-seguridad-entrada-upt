import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/views/login_page.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/viewmodels/login_view_model.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/consultar_estado_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/iniciar_google_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/obtener_captcha_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/verificar_intranet_use_case.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import '../viewmodels/login_view_model_test.dart';

void main() {
  testWidgets(
    'LoginPage renderiza inputs de credenciales y botón de continuar',
    (tester) async {
      final repository = FakeLoginEstudianteRepository();
      final viewModel = LoginViewModel(
        obtenerCaptchaUseCase: ObtenerCaptchaUseCase(repository),
        verificarIntranetUseCase: VerificarIntranetUseCase(repository),
        iniciarGoogleUseCase: IniciarGoogleUseCase(repository),
        consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(repository),
      );

      await tester.pumpWidget(
        MaterialApp(home: LoginPage(viewModel: viewModel)),
      );

      // Permite procesar el initState que llama a cargarCaptcha
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loginTitle), findsOneWidget);
      expect(find.textContaining('Paso 1 de 2'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(FilledButton), findsOneWidget);

      viewModel.dispose();
    },
  );
}
