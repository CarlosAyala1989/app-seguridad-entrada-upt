import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';

/// Explica para qué se usa la ubicación antes de que el sistema pida el
/// permiso. Devuelve `true` si la persona decide continuar.
Future<bool> confirmarUsoUbicacion(BuildContext context) async {
  final continuar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.location_on_outlined),
      title: const Text(AppStrings.locationWhyTitle),
      content: const Text(AppStrings.locationWhyBody),
      actions: [
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
