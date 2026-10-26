import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta de un evento de acceso (historial o aviso).
///
/// Arriba un ícono de estado, una etiqueta pequeña, el título y la fecha;
/// opcionalmente un recuadro con el motivo y una línea de pie con un punto de
/// color. La usan el historial (US-14) y la bandeja de avisos (US-20/21) para
/// que se vean iguales.
class TarjetaEvento extends StatelessWidget {
  const TarjetaEvento({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    this.etiqueta,
    this.detalle,
    this.pie,
    this.negrita = false,
    this.destacada = false,
    this.marcaNoLeido = false,
    this.onTap,
    super.key,
  });

  final IconData icono;

  /// Color del estado (verde autorizado, rojo denegado).
  final Color color;
  final String titulo;
  final String subtitulo;
  final String? etiqueta;
  final String? detalle;
  final String? pie;
  final bool negrita;

  /// Fondo rojo claro para lo que requiere atención (alertas).
  final bool destacada;
  final bool marcaNoLeido;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: destacada ? AppColors.rojoFondo : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: destacada ? AppColors.rojoError : AppColors.bordeSuave,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icono, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (etiqueta != null)
                            Text(
                              etiqueta!,
                              style: textos.labelSmall?.copyWith(
                                color: destacada
                                    ? AppColors.rojoTexto
                                    : AppColors.textoSecundario,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          Text(
                            titulo,
                            style: textos.titleSmall?.copyWith(
                              fontWeight: negrita
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitulo,
                            style: textos.bodySmall?.copyWith(
                              color: AppColors.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (marcaNoLeido)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4, left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.azulUpt,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (detalle != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: destacada ? Colors.white : AppColors.superficieBaja,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(detalle!, style: textos.bodySmall),
                  ),
                ],
                if (pie != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        pie!,
                        style: textos.labelMedium?.copyWith(color: color),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
