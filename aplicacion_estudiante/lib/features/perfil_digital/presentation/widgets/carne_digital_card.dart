import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/logo_upt.dart';
import '../../domain/entities/perfil_digital.dart';

/// Carné universitario digital: muestra la identidad del estudiante con el
/// aspecto de una credencial institucional.
///
/// Solo dibuja los datos que ya trae [perfil]; no consulta nada.
class CarneDigitalCard extends StatelessWidget {
  const CarneDigitalCard({required this.perfil, super.key});

  final PerfilDigital perfil;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final verificada = perfil.estadoVerificacion == 'VERIFICADA';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.azulUpt, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A001244),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Franja superior azul, como en un carné impreso.
          Container(height: 8, color: AppColors.azulUpt),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                const LogoUpt(alto: 40, conTarjeta: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.universityName.toUpperCase(),
                        style: textos.labelLarge?.copyWith(
                          color: AppColors.azulUpt,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppStrings.cardSubtitle.toUpperCase(),
                        style: textos.labelSmall?.copyWith(
                          color: AppColors.textoSecundario,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FotoCarne(perfil: perfil),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EtiquetaRol(rol: perfil.rol),
                      const SizedBox(height: 8),
                      Text(
                        perfil.nombreCompleto.toUpperCase(),
                        style: textos.titleMedium?.copyWith(
                          color: AppColors.azulProfundo,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DatoCarne(
                        etiqueta: AppStrings.code,
                        valor: perfil.codigoInstitucional,
                        destacado: true,
                      ),
                      _DatoCarne(
                        etiqueta: AppStrings.school,
                        valor: perfil.escuela,
                      ),
                      _DatoCarne(
                        etiqueta: AppStrings.email,
                        valor: perfil.correoInstitucional,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.superficieBaja,
            child: Row(
              children: [
                Icon(
                  verificada ? Icons.verified : Icons.pending_outlined,
                  size: 18,
                  color: verificada
                      ? AppColors.verdeAutorizado
                      : AppColors.dorado,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    verificada
                        ? AppStrings.identityVerified
                        : '${AppStrings.identity}: ${perfil.estadoVerificacion}',
                    style: textos.bodySmall?.copyWith(
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoCarne extends StatelessWidget {
  const _FotoCarne({required this.perfil});

  final PerfilDigital perfil;

  @override
  Widget build(BuildContext context) {
    final url = perfil.fotoUrl;
    final inicial = Center(
      child: Text(
        perfil.nombreCompleto.trim().isEmpty
            ? '?'
            : perfil.nombreCompleto.trim()[0].toUpperCase(),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );

    return Container(
      width: 92,
      height: 116,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? inicial
          : Image.network(
              url,
              fit: BoxFit.cover,
              semanticLabel: 'Foto de ${perfil.nombreCompleto}',
              errorBuilder: (_, _, _) => inicial,
            ),
    );
  }
}

class _EtiquetaRol extends StatelessWidget {
  const _EtiquetaRol({required this.rol});

  final String rol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.azulSuave),
      ),
      child: Text(
        rol.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.azulUpt,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DatoCarne extends StatelessWidget {
  const _DatoCarne({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
  });

  final String etiqueta;
  final String valor;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta.toUpperCase(),
            style: textos.labelSmall?.copyWith(
              color: AppColors.textoSecundario,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            valor,
            style: destacado
                ? textos.titleSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AppColors.azulProfundo,
                    letterSpacing: 1,
                  )
                : textos.bodyMedium,
          ),
        ],
      ),
    );
  }
}
