import 'package:aplicacion_estudiante/features/perfil_digital/domain/entities/perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/widgets/carne_digital_card.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:aplicacion_estudiante/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PerfilDigital _perfil({String verificacion = 'VERIFICADA'}) => PerfilDigital(
  nombreCompleto: 'Ana Pérez',
  codigoInstitucional: '2026087688',
  correoInstitucional: 'ana@virtual.upt.pe',
  rol: 'Estudiante',
  escuela: 'Ingeniería de Sistemas',
  estadoVerificacion: verificacion,
  estadoAcceso: 'AUTORIZADO',
);

Future<void> _mostrar(WidgetTester tester, PerfilDigital perfil) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(child: CarneDigitalCard(perfil: perfil)),
      ),
    ),
  );
}

void main() {
  testWidgets('muestra los datos del estudiante como un carné', (tester) async {
    await _mostrar(tester, _perfil());

    expect(find.text('ANA PÉREZ'), findsOneWidget);
    expect(find.text('2026087688'), findsOneWidget);
    expect(find.text('ESTUDIANTE'), findsOneWidget);
    expect(find.text('Ingeniería de Sistemas'), findsOneWidget);
    expect(find.text('ana@virtual.upt.pe'), findsOneWidget);
    // Sin foto se muestra la inicial del nombre.
    expect(find.text('A'), findsOneWidget);
    expect(find.text(AppStrings.identityVerified), findsOneWidget);
  });

  testWidgets('si la identidad no está verificada lo indica', (tester) async {
    await _mostrar(tester, _perfil(verificacion: 'PENDIENTE'));

    expect(find.text(AppStrings.identityVerified), findsNothing);
    expect(find.text('${AppStrings.identity}: PENDIENTE'), findsOneWidget);
  });
}
