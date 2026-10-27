import 'package:aplicacion_estudiante/core/auth/secure_session_storage.dart';
import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/sesion_estudiante.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/usuario.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/failures/login_failure.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/repositories/login_estudiante_repository.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/cerrar_sesion_use_case.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/usecases/restaurar_o_renovar_sesion_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements LoginEstudianteRepository {}

const _usuario = Usuario(
  id: 1,
  codigoInstitucional: '2026087688',
  correoInstitucional: 'estudiante@virtual.upt.pe',
  nombres: 'Ana',
  apellidos: 'Pérez',
  roles: ['ESTUDIANTE'],
);

SesionEstudiante _sesionRenovada() => SesionEstudiante(
  tipoToken: 'Bearer',
  tokenAcceso: 'acceso-nuevo',
  tokenRenovacion: 'renovacion-nueva',
  tokenAccesoExpiraEn: DateTime.now().add(const Duration(minutes: 15)),
  tokenRenovacionExpiraEn: DateTime.now().add(const Duration(days: 7)),
  usuario: _usuario,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepository repository;
  const storage = SecureSessionStorage();

  /// Guarda en el almacenamiento simulado una sesión con las expiraciones dadas.
  Future<void> guardarSesion({
    required Duration accesoVence,
    Duration renovacionVence = const Duration(days: 7),
  }) => storage.guardarTokens(
    tokenAcceso: 'acceso',
    tokenRenovacion: 'renovacion',
    tokenAccesoExpiraEn: DateTime.now().add(accesoVence),
    tokenRenovacionExpiraEn: DateTime.now().add(renovacionVence),
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    repository = _MockRepository();
  });

  group('RestaurarORenovarSesionUseCase', () {
    late RestaurarORenovarSesionUseCase restaurar;

    setUp(() {
      restaurar = RestaurarORenovarSesionUseCase(
        repository: repository,
        sessionStorage: storage,
      );
    });

    test('sin sesión guardada devuelve null', () async {
      expect(await restaurar(), isNull);
      verifyZeroInteractions(repository);
    });

    test('con el token de renovación vencido borra la sesión', () async {
      await guardarSesion(
        accesoVence: const Duration(minutes: -10),
        renovacionVence: const Duration(minutes: -1),
      );

      expect(await restaurar(), isNull);
      expect(await storage.leerTokens(), isNull);
      verifyZeroInteractions(repository);
    });

    test('con el token de acceso vencido renueva la sesión', () async {
      await guardarSesion(accesoVence: const Duration(minutes: -1));
      when(
        () => repository.renovarSesion('renovacion'),
      ).thenAnswer((_) async => _sesionRenovada());

      expect(await restaurar(), _usuario);
      verify(() => repository.renovarSesion('renovacion')).called(1);
    });

    test('si la renovación falla borra la sesión', () async {
      await guardarSesion(accesoVence: const Duration(minutes: -1));
      when(
        () => repository.renovarSesion(any()),
      ).thenThrow(const CredencialesInvalidasFailure());

      expect(await restaurar(), isNull);
      expect(await storage.leerTokens(), isNull);
    });

    test('con el token vigente consulta la sesión en la API', () async {
      await guardarSesion(accesoVence: const Duration(minutes: 10));
      when(
        () => repository.consultarSesion('acceso'),
      ).thenAnswer((_) async => _usuario);

      expect(await restaurar(), _usuario);
      verifyNever(() => repository.renovarSesion(any()));
    });

    test('si la consulta falla intenta renovar', () async {
      await guardarSesion(accesoVence: const Duration(minutes: 10));
      when(
        () => repository.consultarSesion(any()),
      ).thenThrow(const LoginGenericoFailure());
      when(
        () => repository.renovarSesion('renovacion'),
      ).thenAnswer((_) async => _sesionRenovada());

      expect(await restaurar(), _usuario);
    });

    test('si la consulta y la renovación fallan borra la sesión', () async {
      await guardarSesion(accesoVence: const Duration(minutes: 10));
      when(
        () => repository.consultarSesion(any()),
      ).thenThrow(const LoginGenericoFailure());
      when(
        () => repository.renovarSesion(any()),
      ).thenThrow(const LoginGenericoFailure());

      expect(await restaurar(), isNull);
      expect(await storage.leerTokens(), isNull);
    });

    test(
      'sin internet entra con la cuenta guardada y no borra la sesión',
      () async {
        await guardarSesion(accesoVence: const Duration(minutes: 10));
        when(
          () => repository.consultarSesion(any()),
        ).thenThrow(const NetworkFailure());
        when(
          () => repository.usuarioGuardado(),
        ).thenAnswer((_) async => _usuario);

        expect(await restaurar(), _usuario);
        expect(await storage.leerTokens(), isNotNull);
        // Sin red no tiene sentido intentar renovar.
        verifyNever(() => repository.renovarSesion(any()));
      },
    );

    test(
      'sin internet y con el acceso vencido tampoco borra la sesión',
      () async {
        await guardarSesion(accesoVence: const Duration(minutes: -1));
        when(
          () => repository.renovarSesion(any()),
        ).thenThrow(const NetworkFailure());
        when(() => repository.usuarioGuardado()).thenAnswer((_) async => null);

        expect(await restaurar(), isNull);
        expect(await storage.leerTokens(), isNotNull);
      },
    );
  });

  group('CerrarSesionUseCase', () {
    late CerrarSesionUseCase cerrar;

    setUp(() {
      cerrar = CerrarSesionUseCase(
        repository: repository,
        sessionStorage: storage,
      );
    });

    test('con sesión guardada la revoca en la API con su token', () async {
      await guardarSesion(accesoVence: const Duration(minutes: 10));
      when(() => repository.cerrarSesion(any())).thenAnswer((_) async {});

      await cerrar();

      verify(() => repository.cerrarSesion('acceso')).called(1);
    });

    test('sin sesión guardada solo limpia el almacenamiento', () async {
      await cerrar();

      verifyZeroInteractions(repository);
      expect(await storage.leerTokens(), isNull);
    });

    test('también borra la vinculación del QR sin conexión', () async {
      var borrada = false;
      final cerrarTodo = CerrarSesionUseCase(
        repository: repository,
        sessionStorage: storage,
        borrarDatosOffline: () async => borrada = true,
      );
      await guardarSesion(accesoVence: const Duration(minutes: 10));
      when(() => repository.cerrarSesion(any())).thenAnswer((_) async {});

      await cerrarTodo();

      expect(borrada, isTrue);
    });
  });
}
