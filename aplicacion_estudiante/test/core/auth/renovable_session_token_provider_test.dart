import 'package:aplicacion_estudiante/core/auth/secure_session_storage.dart';
import 'package:aplicacion_estudiante/core/auth/session_token_provider.dart';
import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 10, 15, 12);

  SessionTokensData tokens({
    required Duration accesoVence,
    Duration renovacionVence = const Duration(days: 7),
  }) => SessionTokensData(
    tokenAcceso: 'acceso-viejo',
    tokenRenovacion: 'renovacion',
    tokenAccesoExpiraEn: ahora.add(accesoVence),
    tokenRenovacionExpiraEn: ahora.add(renovacionVence),
  );

  late int renovaciones;
  late bool limpiado;

  RenovableSessionTokenProvider proveedor(
    SessionTokensData? guardados, {
    Future<String> Function(String)? renovar,
  }) {
    renovaciones = 0;
    limpiado = false;
    return RenovableSessionTokenProvider(
      leerTokens: () async => guardados,
      limpiar: () async => limpiado = true,
      renovar:
          renovar ??
          (_) async {
            renovaciones++;
            return 'acceso-nuevo';
          },
      ahora: () => ahora,
    );
  }

  test('sin sesión guardada devuelve null', () async {
    expect(await proveedor(null).readAccessToken(), isNull);
  });

  test('con token vigente lo devuelve sin renovar', () async {
    final p = proveedor(tokens(accesoVence: const Duration(minutes: 10)));
    expect(await p.readAccessToken(), 'acceso-viejo');
    expect(renovaciones, 0);
  });

  test('renueva cuando el token está a punto de caducar', () async {
    final p = proveedor(tokens(accesoVence: const Duration(seconds: 10)));
    expect(await p.readAccessToken(), 'acceso-nuevo');
    expect(renovaciones, 1);
  });

  test('peticiones simultáneas comparten una sola renovación', () async {
    final p = proveedor(tokens(accesoVence: Duration.zero));
    final resultados = await Future.wait([
      p.readAccessToken(),
      p.readAccessToken(),
    ]);
    expect(resultados, ['acceso-nuevo', 'acceso-nuevo']);
    expect(renovaciones, 1);
  });

  test('si la renovación falla borra la sesión y devuelve null', () async {
    final p = proveedor(
      tokens(accesoVence: Duration.zero),
      renovar: (_) async => throw Exception('401'),
    );
    expect(await p.readAccessToken(), isNull);
    expect(limpiado, isTrue);
  });

  test('sin internet conserva la sesión y avisa del problema de red', () async {
    final p = proveedor(
      tokens(accesoVence: Duration.zero),
      renovar: (_) async => throw const NetworkFailure(),
    );
    await expectLater(p.readAccessToken(), throwsA(isA<NetworkFailure>()));
    expect(limpiado, isFalse);
  });

  test('con el token de renovación vencido borra la sesión', () async {
    final p = proveedor(
      tokens(
        accesoVence: Duration.zero,
        renovacionVence: const Duration(seconds: -1),
      ),
    );
    expect(await p.readAccessToken(), isNull);
    expect(limpiado, isTrue);
    expect(renovaciones, 0);
  });
}
