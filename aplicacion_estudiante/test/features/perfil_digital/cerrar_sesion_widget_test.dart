import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/views/perfil_digital_page.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _SinPerfil implements PerfilDigitalRepository {
  const _SinPerfil();

  @override
  Future<Never?> obtenerPerfilActual() async => null;
}

PerfilDigitalViewModel _viewModel() => PerfilDigitalViewModel(
  obtenerPerfil: const ObtenerPerfilDigital(_SinPerfil()),
);

void main() {
  testWidgets('sin onCerrarSesion no muestra el botón', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PerfilDigitalPage(viewModel: _viewModel())),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.logout), findsNothing);
  });

  testWidgets('cancelar el diálogo no cierra la sesión', (tester) async {
    var cerrada = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilDigitalPage(
          viewModel: _viewModel(),
          onCerrarSesion: () async => cerrada = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(cerrada, isFalse);
  });

  testWidgets('confirmar el diálogo cierra la sesión', (tester) async {
    var cerrada = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilDigitalPage(
          viewModel: _viewModel(),
          onCerrarSesion: () async => cerrada = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.logout));
    await tester.pumpAndSettle();

    expect(cerrada, isTrue);
  });
}
