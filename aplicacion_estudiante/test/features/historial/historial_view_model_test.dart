import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/historial/domain/entities/registro_historial.dart';
import 'package:aplicacion_estudiante/features/historial/domain/repositories/historial_repository.dart';
import 'package:aplicacion_estudiante/features/historial/domain/usecases/obtener_historial_use_case.dart';
import 'package:aplicacion_estudiante/features/historial/presentation/states/historial_state.dart';
import 'package:aplicacion_estudiante/features/historial/presentation/viewmodels/historial_view_model.dart';
import 'package:aplicacion_estudiante/features/historial/presentation/views/historial_page.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RegistroHistorial _r(int id, {bool ok = true}) => RegistroHistorial(
  id: id,
  resultado: ok ? ResultadoIngreso.autorizado : ResultadoIngreso.denegado,
  motivo: ok ? 'ACCESO_AUTORIZADO' : 'CREDENCIAL_EXPIRADA',
  registradoEn: DateTime.utc(2026, 10, 18, 15, id % 60),
  puntoAccesoNombre: 'Puerta principal',
);

final class _Repo implements HistorialRepository {
  final paginas = <int, PaginaHistorial>{};
  final pedidas = <(int, ResultadoIngreso?)>[];
  Failure? falla;

  @override
  Future<PaginaHistorial> obtenerPagina({
    required int pagina,
    required int limite,
    ResultadoIngreso? resultado,
  }) async {
    pedidas.add((pagina, resultado));
    final f = falla;
    if (f != null) throw f;
    return paginas[pagina] ??
        PaginaHistorial(
          registros: const [],
          pagina: pagina,
          totalPaginas: 0,
          total: 0,
        );
  }
}

void main() {
  late _Repo repo;
  late HistorialViewModel vm;

  setUp(() {
    repo = _Repo();
    vm = HistorialViewModel(obtenerHistorial: ObtenerHistorialUseCase(repo));
  });

  tearDown(() => vm.dispose());

  test('sin registros muestra el estado vacío', () async {
    await vm.cargar();
    expect(vm.currentState, isA<HistorialVacio>());
  });

  test('carga la primera página y añade la siguiente sin repetir', () async {
    repo.paginas[1] = PaginaHistorial(
      registros: [_r(3), _r(2)],
      pagina: 1,
      totalPaginas: 2,
      total: 3,
    );
    // Llegó un acceso nuevo entre peticiones: el 2 se repite en la página 2.
    repo.paginas[2] = PaginaHistorial(
      registros: [_r(2), _r(1)],
      pagina: 2,
      totalPaginas: 2,
      total: 3,
    );

    await vm.cargar();
    expect((vm.currentState as HistorialDatos).hayMas, isTrue);

    await vm.cargarMas();
    final datos = vm.currentState as HistorialDatos;
    expect(datos.registros.map((r) => r.id), [3, 2, 1]);
    expect(datos.hayMas, isFalse);
  });

  test('cambiar el filtro vuelve a la página 1 con ese resultado', () async {
    await vm.cambiarFiltro(ResultadoIngreso.denegado);
    expect(repo.pedidas.last, (1, ResultadoIngreso.denegado));
    expect(vm.filtro, ResultadoIngreso.denegado);
  });

  test('un error de la API se muestra con su mensaje', () async {
    repo.falla = const ServerFailure('Tu cuenta no está habilitada.');
    await vm.cargar();
    expect(
      (vm.currentState as HistorialError).message,
      'Tu cuenta no está habilitada.',
    );
  });

  test('si falla "cargar más" conserva la lista y avisa', () async {
    repo.paginas[1] = PaginaHistorial(
      registros: [_r(2)],
      pagina: 1,
      totalPaginas: 2,
      total: 2,
    );
    await vm.cargar();
    repo.falla = const NetworkFailure();

    await vm.cargarMas();

    final datos = vm.currentState as HistorialDatos;
    expect(datos.registros, hasLength(1));
    expect(datos.mensaje, isNotNull);
  });

  testWidgets('un rechazo muestra el motivo en lenguaje claro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RegistroTile(registro: _r(5, ok: false))),
      ),
    );
    expect(find.text(AppStrings.historyDenied), findsOneWidget);
    expect(find.textContaining('El código QR estaba vencido'), findsOneWidget);
  });

  test('la fecha se muestra en la hora local del teléfono', () {
    final utc = DateTime.utc(2026, 10, 18, 15);
    final local = utc.toLocal();
    expect(
      RegistroTile.fechaLocal(utc),
      endsWith(
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}',
      ),
    );
  });
}
