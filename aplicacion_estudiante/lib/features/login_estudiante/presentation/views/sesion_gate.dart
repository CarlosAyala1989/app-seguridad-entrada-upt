import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/logo_upt.dart';
import '../../domain/entities/usuario.dart';

/// Primera pantalla de la app: intenta restaurar la sesión guardada y decide
/// si mostrar el login o entrar directamente a la identidad digital.
class SesionGate extends StatefulWidget {
  const SesionGate({
    required this.restaurarSesion,
    required this.construirLogin,
    required this.construirInicio,
    super.key,
  });

  /// Devuelve el usuario si la sesión guardada sigue siendo válida
  /// (renovándola si hace falta) o `null` si hay que iniciar sesión.
  final Future<Usuario?> Function() restaurarSesion;
  final WidgetBuilder construirLogin;
  final WidgetBuilder construirInicio;

  @override
  State<SesionGate> createState() => _SesionGateState();
}

class _SesionGateState extends State<SesionGate> {
  late final Future<Usuario?> _restauracion = _restaurarSinFallar();

  /// Se construye una sola vez: si la pantalla se redibuja (p. ej. al
  /// cambiar el tamaño de la ventana) no se crea otra página con otro
  /// ViewModel.
  Widget? _destino;

  Future<Usuario?> _restaurarSinFallar() async {
    try {
      return await widget.restaurarSesion();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: _restauracion,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _PantallaPreparacion();
        }
        return _destino ??= snapshot.data == null
            ? widget.construirLogin(context)
            : widget.construirInicio(context);
      },
    );
  }
}

class _PantallaPreparacion extends StatelessWidget {
  const _PantallaPreparacion();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoUpt(alto: 110),
            const SizedBox(height: 32),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(minHeight: 4),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.preparingSession,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
