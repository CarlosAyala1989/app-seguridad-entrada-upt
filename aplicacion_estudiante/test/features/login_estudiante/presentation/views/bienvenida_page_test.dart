import 'package:aplicacion_estudiante/features/login_estudiante/presentation/views/bienvenida_page.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:aplicacion_estudiante/shared/theme/app_theme.dart';
import 'package:aplicacion_estudiante/shared/widgets/logo_upt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required VoidCallback onIniciarSesion,
  VoidCallback? onVerAvisoPrivacidad,
}) => MaterialApp(
  theme: AppTheme.light,
  home: BienvenidaPage(
    onIniciarSesion: onIniciarSesion,
    onVerAvisoPrivacidad: onVerAvisoPrivacidad,
  ),
);

void main() {
  testWidgets('muestra el escudo, el título y la universidad', (tester) async {
    await tester.pumpWidget(_app(onIniciarSesion: () {}));

    expect(find.byType(LogoUpt), findsOneWidget);
    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
    expect(find.text(AppStrings.universityName), findsOneWidget);
  });

  testWidgets('el botón principal avisa que se quiere iniciar sesión', (
    tester,
  ) async {
    var veces = 0;
    await tester.pumpWidget(_app(onIniciarSesion: () => veces++));

    await tester.ensureVisible(find.text(AppStrings.welcomeLogin));
    await tester.tap(find.text(AppStrings.welcomeLogin));
    expect(veces, 1);
  });

  testWidgets('el aviso de privacidad solo aparece si hay a dónde ir', (
    tester,
  ) async {
    await tester.pumpWidget(_app(onIniciarSesion: () {}));
    expect(find.text(AppStrings.welcomePrivacy), findsNothing);

    var abierto = false;
    await tester.pumpWidget(
      _app(onIniciarSesion: () {}, onVerAvisoPrivacidad: () => abierto = true),
    );
    await tester.ensureVisible(find.text(AppStrings.welcomePrivacy));
    await tester.tap(find.text(AppStrings.welcomePrivacy));
    expect(abierto, isTrue);
  });
}
