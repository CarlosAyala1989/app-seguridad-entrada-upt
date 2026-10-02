import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:aplicacion_estudiante/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flujo de autenticacion: verifica pantalla y pulsa reintentar', (tester) async {
    // 1. Inicia la aplicacion real
    app.main();
    await tester.pumpAndSettle();

    // 2. Espera a que termine la carga inicial
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 3. Evalua la pantalla segun el estado
    final botonReintentar = find.text('Reintentar');
    if (botonReintentar.evaluate().isNotEmpty) {
      // Si fallo el backend, pulsa Reintentar
      await tester.tap(botonReintentar);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    } else {
      // Si tiene datos cargados, verifica el encabezado
      expect(find.text('Identidad digital UPT'), findsOneWidget);
    }
  });
}