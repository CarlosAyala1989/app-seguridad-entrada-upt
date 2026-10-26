import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pantalla de "no hay datos" o "algo falló" con el mismo estilo en toda la
/// app: ícono en un círculo, un texto y un botón para volver a intentar.
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({
    required this.icono,
    required this.texto,
    required this.textoBoton,
    required this.onPulsar,
    this.esError = false,
    super.key,
  });

  final IconData icono;
  final String texto;
  final String textoBoton;
  final Future<void> Function() onPulsar;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: esError ? AppColors.rojoFondo : AppColors.superficie,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 44,
                  color: esError ? AppColors.rojoError : AppColors.azulUpt,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => onPulsar(),
                icon: const Icon(Icons.refresh),
                label: Text(textoBoton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
