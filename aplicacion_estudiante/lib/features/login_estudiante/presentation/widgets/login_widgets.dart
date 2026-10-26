import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/logo_upt.dart';

/// Encabezado del login: escudo, universidad, título y subtítulo.
class EncabezadoLogin extends StatelessWidget {
  const EncabezadoLogin({
    required this.titulo,
    required this.subtitulo,
    super.key,
  });

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      children: [
        const LogoUpt(alto: 88, conTarjeta: false),
        const SizedBox(height: 16),
        Text(
          AppStrings.universityName.toUpperCase(),
          textAlign: TextAlign.center,
          style: textos.labelMedium?.copyWith(
            color: AppColors.textoSecundario,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(titulo, textAlign: TextAlign.center, style: textos.headlineMedium),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: textos.bodyLarge?.copyWith(color: AppColors.textoSecundario),
        ),
      ],
    );
  }
}

/// Barra "Paso X de 2" que muestra en qué parte del login está el estudiante.
class IndicadorPasoLogin extends StatelessWidget {
  const IndicadorPasoLogin({
    required this.paso,
    required this.descripcion,
    super.key,
  });

  static const totalPasos = 2;

  final int paso;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final progreso = paso / totalPasos;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paso $paso de $totalPasos: $descripcion',
                  style: textos.labelLarge?.copyWith(
                    color: AppColors.azulProfundo,
                  ),
                ),
              ),
              Text(
                '${(progreso * 100).round()} %',
                style: textos.labelLarge?.copyWith(
                  color: AppColors.azulProfundo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 6,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta blanca con borde suave usada para agrupar partes del formulario.
class TarjetaLogin extends StatelessWidget {
  const TarjetaLogin({required this.child, this.color, super.key});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: child,
    );
  }
}

/// Mensaje de error del login con estilo institucional.
class MensajeErrorLogin extends StatelessWidget {
  const MensajeErrorLogin({required this.mensaje, super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rojoFondo,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.rojoError),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: AppColors.rojoTexto),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso de que el dispositivo quedará vinculado (paso 2).
class AvisoDispositivoLogin extends StatelessWidget {
  const AvisoDispositivoLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return TarjetaLogin(
      color: AppColors.superficieBaja,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.dorado),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.loginDeviceNotice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
