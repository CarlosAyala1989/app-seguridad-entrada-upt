import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';

/// Explica para qué se usa la ubicación antes de que el sistema pida el
/// permiso. Devuelve `true` si la persona decide continuar.
///
/// Con [onVerAvisoPrivacidad] se muestra además «Más información», que abre
/// el aviso de privacidad (US-24) sin cerrar el diálogo.
Future<bool> confirmarUsoUbicacion(
  BuildContext context, {
  VoidCallback? onVerAvisoPrivacidad,
}) async {
  final continuar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl + 8),
      ),
      icon: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors.superficie,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_on_outlined,
          size: 32,
          color: AppColors.azulUpt,
        ),
      ),
      title: const Text(AppStrings.locationWhyTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AppStrings.locationWhyBody),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.superficieBaja,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 18, color: AppColors.azulUpt),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.locationLawNote,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (onVerAvisoPrivacidad != null)
          TextButton(
            onPressed: onVerAvisoPrivacidad,
            child: const Text(AppStrings.moreInfo),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.notNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.continueLabel),
        ),
      ],
    ),
  );
  return continuar ?? false;
}
