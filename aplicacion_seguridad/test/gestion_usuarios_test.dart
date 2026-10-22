import 'package:aplicacion_seguridad/features/administracion/presentation/screens/gestion_usuarios_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gestión de Usuarios y Creación de Guardias / Administradores', () {
    testWidgets('1. Renderiza la lista inicial de personal con filtros',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GestionUsuariosScreen()),
      );

      expect(find.text('Gestión de Personal y Usuarios'), findsOneWidget);
      expect(find.text('Nuevo Usuario'), findsOneWidget);
      expect(find.text('Carlos Alberto Ayala Ramos'), findsOneWidget);
      expect(find.text('ADMINISTRADOR'), findsOneWidget);
      expect(find.text('GUARDIA'), findsWidgets);
    });

    testWidgets('2. Presionar Nuevo Usuario abre formulario modal de registro',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GestionUsuariosScreen()),
      );

      await tester.tap(find.text('Nuevo Usuario'));
      await tester.pumpAndSettle();

      expect(find.text('Registrar Nuevo Usuario'), findsOneWidget);
      expect(find.text('Guardia de Seguridad'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget);
      expect(find.text('Crear y Habilitar Usuario'), findsOneWidget);
    });

    testWidgets('3. Guardar con campos vacíos activa validaciones en formulario',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GestionUsuariosScreen()),
      );

      await tester.tap(find.text('Nuevo Usuario'));
      await tester.pumpAndSettle();

      final btnFinder = find.text('Crear y Habilitar Usuario');
      await tester.ensureVisible(btnFinder);
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();

      expect(find.text('Obligatorio'), findsWidgets);
      expect(find.text('Ingresa un usuario'), findsOneWidget);
    });
  });
}
