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
    'login y explicación de datos admiten texto grande en iPhone pequeño',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeLoginEstudianteRepository();
      final viewModel = LoginViewModel(
        obtenerCaptchaUseCase: ObtenerCaptchaUseCase(repository),
        verificarIntranetUseCase: VerificarIntranetUseCase(repository),
        iniciarGoogleUseCase: IniciarGoogleUseCase(repository),
        consultarEstadoGoogleUseCase: ConsultarEstadoGoogleUseCase(repository),
      );
      addTearDown(viewModel.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: LoginPage(viewModel: viewModel, onVerAvisoPrivacidad: () {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(AppStrings.loginDataNotice));
      expect(tester.takeException(), isNull);
    },
  );

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
      expect(find.text(AppStrings.loginVerify), findsOneWidget);

      viewModel.dispose();
    },
  );
}
