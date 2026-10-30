import 'package:aplicacion_estudiante/features/historial/data/local/historial_sin_conexion.dart';
import 'package:flutter_test/flutter_test.dart';

import 'historial_simulados.dart';

void main() {
  late ArchivoSimulado archivo;
  late CifradoSimulado cifrado;
  late HistorialSinConexion historial;
  setUp(() {
    archivo = ArchivoSimulado();
    cifrado = CifradoSimulado();
    historial = HistorialSinConexion(archivo, cifrado);
  });

  test('4a: el archivo no contiene Cliente Prueba en texto claro', () async {
    await historial.guardar([registro(1, 'Cliente Prueba')]);
    expect(archivo.contenido, isNot(contains('Cliente Prueba')));
  });

  test('4b: tres registros se recuperan con todos sus campos', () async {
    final originales = [
      registro(1, 'Puerta 1'),
      registro(2, 'Puerta 2'),
      registro(3, 'Puerta 3'),
    ];
    await historial.guardar(originales);
    final leidos = (await historial.leer()).registros;
    expect(leidos.length, originales.length);
    for (var i = 0; i < originales.length; i++) {
      expect(leidos[i].id, originales[i].id);
      expect(leidos[i].resultado, originales[i].resultado);
      expect(leidos[i].motivo, originales[i].motivo);
      expect(leidos[i].registradoEn, originales[i].registradoEn);
      expect(leidos[i].puntoAccesoNombre, originales[i].puntoAccesoNombre);
    }
  });

  test('4c: sin archivo devuelve lista vacía sin error', () async {
    final resultado = await historial.leer();
    expect(resultado.registros, isEmpty);
    expect(resultado.mensaje, isNull);
  });
}
