import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Escudo de la UPT dentro de una tarjeta blanca.
///
/// Si la imagen no se pudiera cargar se muestra un ícono, así la pantalla
/// nunca queda rota.
class LogoUpt extends StatelessWidget {
  const LogoUpt({this.alto = 120, this.conTarjeta = true, super.key});

  static const ruta = 'assets/images/logo_upt.png';

  final double alto;
  final bool conTarjeta;

  @override
  Widget build(BuildContext context) {
    final imagen = Image.asset(
      ruta,
      height: alto,
      fit: BoxFit.contain,
      semanticLabel: 'Escudo de la Universidad Privada de Tacna',
      errorBuilder: (_, _, _) => Icon(
        Icons.account_balance,
        size: alto * 0.6,
        color: AppColors.azulUpt,
      ),
    );

    if (!conTarjeta) return imagen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl + 8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14001244),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: imagen,
    );
  }
}
