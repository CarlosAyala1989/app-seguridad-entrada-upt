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

  test('5a: fallo de descifrado devuelve lista vacía y mensaje', () async {
    await historial.guardar([registro(1, 'Puerta 1')]);
    cifrado.fallaDescifrado = true;
    final resultado = await historial.leer();
    expect(resultado.registros, isEmpty);
    expect(
      resultado.mensaje,
      'Datos locales no disponibles, conéctese para actualizar',
    );
  });

  test('5b: borrar elimina el archivo y la clave', () async {
    await historial.guardar([registro(1, 'Puerta 1')]);
    expect(archivo.contenido, isNotNull);
    expect(cifrado.claveExiste, isTrue);
    await historial.borrar();
    expect(archivo.contenido, isNull);
    expect(cifrado.claveExiste, isFalse);
    expect((await historial.leer()).registros, isEmpty);
  });
}
