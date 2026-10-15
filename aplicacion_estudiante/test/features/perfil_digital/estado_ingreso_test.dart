import 'package:aplicacion_estudiante/features/codigo_qr/presentation/views/codigo_qr_page.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/data/mappers/perfil_digital_mapper.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/data/models/perfil_digital_dto.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/domain/entities/perfil_digital.dart';
import 'package:aplicacion_estudiante/features/perfil_digital/presentation/views/perfil_digital_page.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PerfilDigital _perfil({
  String verificacion = 'VERIFICADA',
  String usuario = 'ACTIVO',
  String acceso = 'AUTORIZADO',
}) => PerfilDigital(
  nombreCompleto: 'Ana Pérez',
  codigoInstitucional: '2026087688',
  correoInstitucional: 'ana@virtual.upt.pe',
  rol: 'ESTUDIANTE',
  escuela: 'Ingeniería de Sistemas',
  estadoVerificacion: verificacion,
  estadoUsuario: usuario,
  estadoAcceso: acceso,
);

Map<String, Object?> _json({Object? preparacion}) => {
  'nombre_completo': 'Ana Pérez',
  'codigo_institucional': '2026087688',
  'correo_institucional': 'ana@virtual.upt.pe',
  'roles': ['ESTUDIANTE'],
  'verificacion': {'estado': 'VERIFICADA'},
  'acceso': {'estado_usuario': 'INACTIVO', 'estado_autorizacion': 'AUTORIZADO'},
  'preparacion_codigo_qr': preparacion,
};

void main() {
  group('PerfilDigital.permiteIngreso', () {
    test('verificada, activa y autorizada puede ingresar', () {
      final p = _perfil();
      expect(p.permiteIngreso, isTrue);
      expect(p.motivoSinIngreso, isNull);
    });

    test('sin verificar no puede ingresar', () {
      final p = _perfil(verificacion: 'PENDIENTE');
      expect(p.permiteIngreso, isFalse);
      expect(p.motivoSinIngreso, contains('verificada'));
    });

    test('con la cuenta inactiva no puede ingresar', () {
      final p = _perfil(usuario: 'INACTIVO');
      expect(p.permiteIngreso, isFalse);
      expect(p.motivoSinIngreso, contains('activa'));
    });

    test('con el acceso no autorizado no puede ingresar', () {
      final p = _perfil(acceso: 'NO_AUTORIZADO');
      expect(p.permiteIngreso, isFalse);
      expect(p.motivoSinIngreso, contains('autorizado'));
    });
  });

  group('PerfilDigitalDto', () {
    test('lee estado de usuario y si puede pedir QR', () {
      final perfil = PerfilDigitalDto.fromJson(
        _json(preparacion: {'puede_solicitar': true}),
      ).toDomain();
      expect(perfil.estadoUsuario, 'INACTIVO');
      expect(perfil.puedeSolicitarCodigoQr, isTrue);
      expect(perfil.permiteIngreso, isFalse);
    });

    test('sin preparacion_codigo_qr no permite pedir QR', () {
      final perfil = PerfilDigitalDto.fromJson(_json()).toDomain();
      expect(perfil.puedeSolicitarCodigoQr, isFalse);
    });
  });

  testWidgets('la tarjeta dice si puede ingresar y por qué no', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              EstadoIngresoCard(perfil: _perfil()),
              EstadoIngresoCard(perfil: _perfil(acceso: 'NO_AUTORIZADO')),
            ],
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.canEnter), findsOneWidget);
    expect(find.text(AppStrings.cannotEnter), findsOneWidget);
    expect(find.textContaining('no está autorizado'), findsOneWidget);
  });

  testWidgets('la cuenta regresiva muestra los segundos que quedan', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CuentaRegresivaQr(segundosRestantes: 25, duracionSegundos: 30),
        ),
      ),
    );

    expect(find.text('25 ${AppStrings.secondsShort}'), findsOneWidget);
    final barra = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(barra.value, closeTo(25 / 30, 0.001));
  });
}
