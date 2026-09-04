import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/views/perfil_digital_page.dart';
import 'package:aplicacion_estudiante/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el estado vacío y una acción sugerida', (tester) async {
    final viewModel = PerfilDigitalViewModel(
      obtenerPerfil: const ObtenerPerfilDigital(_EmptyPerfilRepository()),
    );

    await tester.pumpWidget(
      IngresoUptApp(home: PerfilDigitalPage(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('La identidad digital todavía no está disponible.'),
      findsOneWidget,
    );
    expect(find.text('Volver a consultar'), findsOneWidget);
  });
}

final class _EmptyPerfilRepository implements PerfilDigitalRepository {
  const _EmptyPerfilRepository();

  @override
  Future<Never?> obtenerPerfilActual() async => null;
}
