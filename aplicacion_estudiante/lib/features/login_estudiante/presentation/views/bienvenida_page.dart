import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/logo_upt.dart';

/// Pantalla de bienvenida: lo primero que ve un estudiante sin sesión.
///
/// No conoce el login ni el aviso de privacidad; solo avisa cuando el usuario
/// elige una opción (la navegación la decide quien la construye).
class BienvenidaPage extends StatelessWidget {
  const BienvenidaPage({
    required this.onIniciarSesion,
    this.onVerAvisoPrivacidad,
    super.key,
  });

  final VoidCallback onIniciarSesion;
  final VoidCallback? onVerAvisoPrivacidad;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _InsigniaOficial()),
                  const SizedBox(height: 28),
                  const Center(child: LogoUpt(alto: 140)),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: textos.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.universityName,
                    textAlign: TextAlign.center,
                    style: textos.titleMedium?.copyWith(
                      color: AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.dorado,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.welcomeBody,
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge?.copyWith(
                      color: AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: onIniciarSesion,
                    icon: const Icon(Icons.login),
                    label: const Text(AppStrings.welcomeLogin),
                  ),
                  if (onVerAvisoPrivacidad != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onVerAvisoPrivacidad,
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: const Text(AppStrings.welcomePrivacy),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const _PieInstitucional(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InsigniaOficial extends StatelessWidget {
  const _InsigniaOficial();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 16, color: AppColors.azulUpt),
          const SizedBox(width: 6),
          Text(
            AppStrings.welcomeBadge.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.azulUpt,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieInstitucional extends StatelessWidget {
  const _PieInstitucional();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficieBaja,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textoSecundario,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppStrings.welcomeFooter,
                  textAlign: TextAlign.center,
                  style: textos.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.welcomeCampus,
            style: textos.labelSmall?.copyWith(color: AppColors.borde),
          ),
        ],
      ),
    );
  }
}
