import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../controllers/resumen_notificaciones_controller.dart';

/// Aviso destacado en la identidad mientras haya alertas de posible uso
/// sospechoso sin leer (US-21). Desaparece al leerlas.
class AlertaSeguridadBanner extends StatelessWidget {
  const AlertaSeguridadBanner({
    super.key,
    required this.controller,
    required this.onRevisar,
  });

  final ResumenNotificacionesController controller;
  final Future<void> Function() onRevisar;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final alertas = controller.resumen.alertasNoLeidas;
        if (alertas == 0) return const SizedBox.shrink();
        final esquema = Theme.of(context).colorScheme;
        return Card(
          color: esquema.errorContainer,
          child: ListTile(
            leading: Icon(Icons.gpp_maybe, color: esquema.onErrorContainer),
            title: Text(
              alertas == 1
                  ? AppStrings.alertsBannerOne
                  : '${AppStrings.alertsBannerManyPrefix} $alertas '
                        '${AppStrings.alertsBannerManySuffix}',
              style: TextStyle(color: esquema.onErrorContainer),
            ),
            subtitle: Text(
              AppStrings.alertsBannerHelp,
              style: TextStyle(color: esquema.onErrorContainer),
            ),
            trailing: TextButton(
              onPressed: () async {
                await onRevisar();
                await controller.actualizar();
              },
              child: const Text(AppStrings.review),
            ),
          ),
        );
      },
    );
  }
}
