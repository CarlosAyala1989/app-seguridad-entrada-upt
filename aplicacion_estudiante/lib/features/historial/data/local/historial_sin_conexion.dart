import 'dart:convert';

import '../../domain/entities/registro_historial.dart';

/// Contratos para conectar el archivo privado y el cifrado de la plataforma.
abstract interface class ArchivoHistorial {
  Future<String?> leer();
  Future<void> escribir(String contenido);
  Future<void> borrar();
}

abstract interface class CifradoHistorial {
  Future<String> cifrar(String texto);
  Future<String> descifrar(String contenido);
  Future<void> borrarClave();
}

final class LecturaHistorial {
  const LecturaHistorial(this.registros, {this.mensaje});
  final List<RegistroHistorial> registros;
  final String? mensaje;
}

/// Serializa los registros de acceso; el archivo y el cifrado se inyectan.
final class HistorialSinConexion {
  const HistorialSinConexion(this.archivo, this.cifrado);
  final ArchivoHistorial archivo;
  final CifradoHistorial cifrado;

  Future<void> guardar(List<RegistroHistorial> registros) async {
    final texto = jsonEncode([
      for (final r in registros)
        {
          'id': r.id,
          'resultado': r.resultado.name,
          'motivo': r.motivo,
          'registradoEn': r.registradoEn.toIso8601String(),
          'puntoAccesoNombre': r.puntoAccesoNombre,
        },
    ]);
    await archivo.escribir(await cifrado.cifrar(texto));
  }

  Future<LecturaHistorial> leer() async {
    try {
      final contenido = await archivo.leer();
      if (contenido == null) return const LecturaHistorial([]);
      final lista = jsonDecode(await cifrado.descifrar(contenido)) as List;
      return LecturaHistorial([
        for (final item in lista)
          RegistroHistorial(
            id: item['id'] as int,
            resultado: ResultadoIngreso.values.byName(
              item['resultado'] as String,
            ),
            motivo: item['motivo'] as String,
            registradoEn: DateTime.parse(item['registradoEn'] as String),
            puntoAccesoNombre: item['puntoAccesoNombre'] as String,
          ),
      ]);
    } catch (_) {
      return const LecturaHistorial(
        [],
        mensaje: 'Datos locales no disponibles, conéctese para actualizar',
      );
    }
  }

  Future<void> borrar() async {
    try {
      await archivo.borrar();
    } finally {
      await cifrado.borrarClave();
    }
  }
}
