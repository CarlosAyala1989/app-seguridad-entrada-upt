import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/aviso_privacidad.dart';

class AvisoPrivacidadPage extends StatelessWidget {
  const AvisoPrivacidadPage({super.key, required this.aviso});

  final AvisoPrivacidad aviso;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.privacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '${AppStrings.privacyVersion} ${aviso.version} · '
              '${AppStrings.privacySince} ${aviso.vigenteDesdeTexto}',
              style: textos.bodySmall,
            ),
            for (final seccion in aviso.secciones) ...[
              const SizedBox(height: 24),
              Text(seccion.titulo, style: textos.titleMedium),
              for (final parrafo in seccion.parrafos) ...[
                const SizedBox(height: 8),
                Text(parrafo, style: textos.bodyMedium),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
