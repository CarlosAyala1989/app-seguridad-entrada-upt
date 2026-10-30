import 'dart:convert';

import 'package:aplicacion_estudiante/features/historial/data/local/historial_sin_conexion.dart';
import 'package:aplicacion_estudiante/features/historial/domain/entities/registro_historial.dart';

// Simulaciones para pruebas: Base64 NO es cifrado y no se usa en producción.
final class ArchivoSimulado implements ArchivoHistorial {
  String? contenido;
  @override
  Future<String?> leer() async => contenido;
  @override
  Future<void> escribir(String valor) async => contenido = valor;
  @override
  Future<void> borrar() async => contenido = null;
}

final class CifradoSimulado implements CifradoHistorial {
  bool claveExiste = false;
  bool fallaDescifrado = false;
  @override
  Future<String> cifrar(String texto) async {
    claveExiste = true;
    return base64Encode(utf8.encode(texto));
  }

  @override
  Future<String> descifrar(String contenido) async {
    if (fallaDescifrado) throw const FormatException('Archivo alterado');
    return utf8.decode(base64Decode(contenido));
  }

  @override
  Future<void> borrarClave() async => claveExiste = false;
}

RegistroHistorial registro(int id, String nombre) => RegistroHistorial(
  id: id,
  resultado: ResultadoIngreso.autorizado,
  motivo: 'ACCESO_AUTORIZADO',
  registradoEn: DateTime.utc(2026, 10, 30),
  puntoAccesoNombre: nombre,
);
