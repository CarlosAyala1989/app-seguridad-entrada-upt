import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
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
        final textos = Theme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.rojoFondo,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.rojoError),
          ),
          child: Row(
            children: [
              const Icon(Icons.gpp_maybe, color: AppColors.rojoError),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alertas == 1
                          ? AppStrings.alertsBannerOne
                          : '${AppStrings.alertsBannerManyPrefix} $alertas '
                                '${AppStrings.alertsBannerManySuffix}',
                      style: textos.titleSmall?.copyWith(
                        color: AppColors.rojoTexto,
                      ),
                    ),
                    Text(
                      AppStrings.alertsBannerHelp,
                      style: textos.bodySmall?.copyWith(
                        color: AppColors.rojoTexto,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.rojoError,
                ),
                onPressed: () async {
                  await onRevisar();
                  await controller.actualizar();
                },
                child: const Text(AppStrings.review),
              ),
            ],
          ),
        );
      },
    );
  }
}
