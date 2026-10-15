/// Posición del dispositivo en el momento de pedir una credencial.
final class UbicacionDispositivo {
  const UbicacionDispositivo({
    required this.latitud,
    required this.longitud,
    required this.precisionMetros,
    required this.obtenidaEn,
  });

  final double latitud;
  final double longitud;

  /// Radio de error informado por el sistema operativo.
  final double precisionMetros;
  final DateTime obtenidaEn;

  bool get coordenadasValidas =>
      latitud >= -90 && latitud <= 90 && longitud >= -180 && longitud <= 180;

  /// `true` si se obtuvo hace como máximo [antiguedadMaxima].
  bool esReciente(DateTime ahora, Duration antiguedadMaxima) =>
      ahora.difference(obtenidaEn) <= antiguedadMaxima;
}
