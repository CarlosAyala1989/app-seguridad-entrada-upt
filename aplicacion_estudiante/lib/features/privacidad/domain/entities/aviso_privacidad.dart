/// Un apartado del aviso: un título y sus párrafos.
final class SeccionAviso {
  const SeccionAviso({required this.titulo, required this.parrafos});

  final String titulo;
  final List<String> parrafos;
}

/// Aviso de privacidad vigente de la app (US-24).
final class AvisoPrivacidad {
  const AvisoPrivacidad({
    required this.version,
    required this.vigenteDesde,
    required this.secciones,
  });

  final String version;
  final DateTime vigenteDesde;
  final List<SeccionAviso> secciones;

  /// `true` si el aviso explica el uso de la ubicación, que es lo que exige
  /// US-24 de forma explícita.
  bool get explicaUbicacion => secciones.any(
    (s) => '${s.titulo} ${s.parrafos.join(' ')}'.toLowerCase().contains(
      'ubicación',
    ),
  );

  /// Fecha en formato dd/mm/aaaa para mostrar junto a la versión.
  String get vigenteDesdeTexto {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(vigenteDesde.day)}/${dos(vigenteDesde.month)}/'
        '${vigenteDesde.year}';
  }
}
