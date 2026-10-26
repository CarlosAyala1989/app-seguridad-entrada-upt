import 'package:flutter/material.dart';

import '../../domain/entities/notificacion.dart';

/// dd/mm/aaaa hh:mm en la hora del teléfono (la API envía UTC).
String fechaHoraLocal(DateTime fecha) {
  final l = fecha.toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(l.day)}/${dos(l.month)}/${l.year} '
      '${dos(l.hour)}:${dos(l.minute)}';
}

/// Fila de la bandeja. Los avisos sin leer van en negrita y con un punto.
class NotificacionTile extends StatelessWidget {
  const NotificacionTile({
    super.key,
    required this.notificacion,
    required this.onTap,
  });

  final Notificacion notificacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final n = notificacion;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          n.esAlerta ? Icons.gpp_maybe : Icons.block,
          color: esquema.error,
        ),
        title: Text(
          n.titulo,
          style: TextStyle(
            fontWeight: n.leida ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${n.puntoAccesoNombre} · ${fechaHoraLocal(n.registradoEn)}',
        ),
        trailing: n.leida
            ? null
            : Icon(Icons.circle, size: 10, color: esquema.primary),
      ),
    );
  }
}
