import 'package:aplicacion_estudiante/features/biometria/domain/failures/biometria_failure.dart';
import 'package:aplicacion_estudiante/features/biometria/domain/repositories/autenticador_local.dart';
import 'package:aplicacion_estudiante/features/biometria/domain/repositories/preferencia_biometria_repository.dart';
import 'package:aplicacion_estudiante/features/biometria/domain/usecases/bloqueo_biometrico_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Autenticador implements AutenticadorLocal {
  bool disponible = true;
  bool respuesta = true;
  final motivos = <String>[];

  @override
  Future<bool> estaDisponible() async => disponible;

  @override
  Future<bool> autenticar(String motivo) async {
    motivos.add(motivo);
    return respuesta;
  }
}

final class _Preferencias implements PreferenciaBiometriaRepository {
  bool activada = false;

  @override
  Future<bool> estaActivada() async => activada;

  @override
  Future<void> guardar({required bool activada}) async {
    this.activada = activada;
  }
}

void main() {
  late _Autenticador autenticador;
  late _Preferencias preferencias;
  late bool haySesion;
  late BloqueoBiometricoUseCase bloqueo;

  setUp(() {
    autenticador = _Autenticador();
    preferencias = _Preferencias();
    haySesion = true;
    bloqueo = BloqueoBiometricoUseCase(
      autenticador: autenticador,
      preferencias: preferencias,
      haySesion: () async => haySesion,
    );
  });

  group('debeBloquear', () {
    test('no bloquea si la persona no lo activó', () async {
      expect(await bloqueo.debeBloquear(), isFalse);
    });

    test('bloquea si está activado, hay sesión y hay biometría', () async {
      preferencias.activada = true;
      expect(await bloqueo.debeBloquear(), isTrue);
    });

    test('sin sesión no hay nada que proteger', () async {
      preferencias.activada = true;
      haySesion = false;
      expect(await bloqueo.debeBloquear(), isFalse);
    });

    test('si el teléfono ya no tiene biometría no bloquea', () async {
      preferencias.activada = true;
      autenticador.disponible = false;
      expect(await bloqueo.debeBloquear(), isFalse);
    });
  });

  group('activar', () {
    test('pide la huella una vez y guarda la preferencia', () async {
      expect(await bloqueo.activar(), isTrue);
      expect(await bloqueo.estaActivada(), isTrue);
      expect(autenticador.motivos, [BloqueoBiometricoUseCase.motivoActivacion]);
    });

    test('si la persona cancela no se activa', () async {
      autenticador.respuesta = false;
      expect(await bloqueo.activar(), isFalse);
      expect(preferencias.activada, isFalse);
    });

    test('sin biometría lanza BiometriaNoDisponibleFailure', () async {
      autenticador.disponible = false;
      await expectLater(
        bloqueo.activar(),
        throwsA(isA<BiometriaNoDisponibleFailure>()),
      );
      expect(const BiometriaNoDisponibleFailure().message, isNotEmpty);
    });
  });

  test('desactivar guarda la preferencia en falso', () async {
    preferencias.activada = true;
    await bloqueo.desactivar();
    expect(preferencias.activada, isFalse);
  });

  test('desbloquear usa el motivo de desbloqueo', () async {
    expect(await bloqueo.desbloquear(), isTrue);
    expect(await bloqueo.estaDisponible(), isTrue);
    expect(autenticador.motivos, [BloqueoBiometricoUseCase.motivoDesbloqueo]);
  });
}
