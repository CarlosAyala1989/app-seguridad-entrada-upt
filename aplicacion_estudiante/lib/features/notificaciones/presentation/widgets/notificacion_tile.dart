import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
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
      // Las alertas de posible uso sospechoso (US-21) se distinguen a simple
      // vista de las denegaciones normales.
      color: n.esAlerta ? esquema.errorContainer : null,
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
          '${n.esAlerta ? '${AppStrings.securityAlert} · ' : ''}'
          '${n.puntoAccesoNombre} · ${fechaHoraLocal(n.registradoEn)}',
        ),
        trailing: n.leida
            ? null
            : Icon(Icons.circle, size: 10, color: esquema.primary),
      ),
    );
  }
}
