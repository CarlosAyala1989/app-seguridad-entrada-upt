import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/repositories/perfil_digital_repository.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/usecases/obtener_perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/viewmodels/perfil_digital_view_model.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/views/perfil_digital_page.dart';

// Se mockea la interfaz abstracta del repositorio, la cual sí permite 'implements'
class _MockPerfilRepository extends Mock implements PerfilDigitalRepository {}

void main() {
  late _MockPerfilRepository mockRepo;
  late ObtenerPerfilDigital useCase;

  setUp(() {
    mockRepo = _MockPerfilRepository();
    useCase = ObtenerPerfilDigital(mockRepo);
  });

  testWidgets('Muestra mensaje de error y botón Reintentar cuando falla la sesión', (WidgetTester tester) async {
    // 1. Simular falla de autenticación en el repositorio
    when(() => mockRepo.obtenerPerfilActual())
        .thenThrow(const UnauthorizedFailure('Sesión no autorizada'));

    final viewModel = PerfilDigitalViewModel(obtenerPerfil: useCase);

    // 2. Renderizar la página
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilDigitalPage(viewModel: viewModel),
      ),
    );

    // 3. Procesar el microtask inicial y la emisión del Stream
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 4. Verificaciones en la UI:
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    viewModel.dispose();
  });
}