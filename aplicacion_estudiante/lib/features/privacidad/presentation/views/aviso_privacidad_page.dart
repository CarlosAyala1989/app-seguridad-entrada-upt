import 'package:flutter/material.dart';

import '../../../../core/config/legal_config.dart';
import '../../../../core/platform/abrir_pagina_publica.dart';
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
            TextButton.icon(
              onPressed: () async {
                final uri = LegalConfig.uriPublica(
                  const LegalConfig().privacidad,
                );
                final abierta = uri != null && await abrirPaginaPublica(uri);
                if (!abierta && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.pageOpenError)),
                  );
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text(AppStrings.publicPrivacyPolicy),
            ),
            Text(
              '${AppStrings.privacyVersion} ${aviso.version} · '
              '${AppStrings.privacySince} ${aviso.vigenteDesdeTexto}',
              style: textos.bodySmall,
            ),
            for (final seccion in aviso.secciones) ...[
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(seccion.titulo, style: textos.titleMedium),
              ),
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
