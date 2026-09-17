import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/views/perfil_digital_page.dart';

class _MockPerfilRepository extends Mock implements PerfilDigitalRepository {}

void main() {
  late _MockPerfilRepository mockRepo;
  late ObtenerPerfilDigital useCase;

  setUp(() {
    mockRepo = _MockPerfilRepository();
    useCase = ObtenerPerfilDigital(mockRepo);
  });

  testWidgets('Muestra mensaje de error y boton Reintentar cuando falla la sesion', (WidgetTester tester) async {
    when(() => mockRepo.obtenerPerfilActual())
        .thenThrow(const UnauthorizedFailure('Sesion no autorizada'));

    final viewModel = PerfilDigitalViewModel(obtenerPerfil: useCase);

    await tester.pumpWidget(
      MaterialApp(
        home: PerfilDigitalPage(viewModel: viewModel),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    viewModel.dispose();
  });
}
