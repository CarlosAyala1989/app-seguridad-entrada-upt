import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/usuario.dart';
import '../states/login_state.dart';
import '../viewmodels/login_view_model.dart';
import '../widgets/login_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.viewModel, this.onLoginExitoso, super.key});

  final LoginViewModel viewModel;
  final ValueChanged<Usuario>? onLoginExitoso;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _codigoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _captchaController = TextEditingController();

  String? _transaccionCaptchaActual;
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.cargarCaptcha();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _contrasenaController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _limpiarCredencialesSensibles() {
    _contrasenaController.clear();
    _captchaController.clear();
  }

  void _enviarFormulario() {
    final transaccionId = _transaccionCaptchaActual;
    if (transaccionId == null) {
      widget.viewModel.cargarCaptcha();
      return;
    }

    widget.viewModel.verificarIntranet(
      transaccionId: transaccionId,
      codigo: _codigoController.text,
      contrasena: _contrasenaController.text,
      captcha: _captchaController.text,
    );

    _limpiarCredencialesSensibles();
  }

  Widget _construirImagenCaptcha(String imagenBase64) {
    try {
      final bytes = base64Decode(imagenBase64);
      return Image.memory(
        bytes,
        height: 70,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) =>
            const Text('No se pudo mostrar el CAPTCHA. Solicita otro.'),
      );
    } catch (_) {
      return const Text('No se pudo mostrar el CAPTCHA. Solicita otro.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sin título: el encabezado con el escudo ya dice dónde estamos. La
      // barra queda para la flecha de "atrás" hacia la bienvenida.
      appBar: AppBar(),
      body: SafeArea(
        child: StreamBuilder<LoginState>(
          stream: widget.viewModel.estado,
          initialData: widget.viewModel.estadoActual,
          builder: (context, snapshot) {
            final state = snapshot.data ?? const LoginInitialState();

            // 1. Éxito: notifica a la pantalla principal y muestra confirmación
            if (state is LoginExitosoState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onLoginExitoso?.call(state.usuario);
              });
              return const _ConfirmacionExitosa();
            }

            // 2 y 3. Paso 2: Google preparado o esperando confirmación
            if (state is LoginGooglePreparadoState ||
                state is LoginEsperandoGoogleState) {
              return _construirPasoGoogle(context, state);
            }

            // 4. Paso 1: formulario de credenciales y CAPTCHA
            return _construirPasoIntranet(context, state);
          },
        ),
      ),
    );
  }

  Widget _contenedor({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _construirPasoIntranet(BuildContext context, LoginState state) {
    final textos = Theme.of(context).textTheme;
    final estaVerificando = state is LoginVerificandoIntranetState;
    final estaCargandoCaptcha = state is LoginCargandoCaptchaState;

    if (state is LoginCaptchaListoState) {
      _transaccionCaptchaActual = state.captcha.transaccionId;
    }

    return _contenedor(
      children: [
        const EncabezadoLogin(
          titulo: AppStrings.loginTitle,
          subtitulo: AppStrings.loginSubtitle,
        ),
        const SizedBox(height: 24),
        const IndicadorPasoLogin(
          paso: 1,
          descripcion: AppStrings.loginStep1,
        ),
        const SizedBox(height: 24),
        if (state is LoginErrorState) ...[
          MensajeErrorLogin(mensaje: state.mensaje),
          const SizedBox(height: 16),
        ],
        Text(AppStrings.loginCodeLabel, style: textos.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _codigoController,
          enabled: !estaVerificando,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Ej. 2022074266',
            prefixIcon: Icon(Icons.badge_outlined),
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.loginPasswordLabel, style: textos.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _contrasenaController,
          enabled: !estaVerificando,
          keyboardType: TextInputType.number,
          obscureText: _ocultarContrasena,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '1 a 6 dígitos numéricos',
            prefixIcon: const Icon(Icons.lock_outline),
            counterText: '',
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _ocultarContrasena = !_ocultarContrasena),
              icon: Icon(
                _ocultarContrasena
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: _ocultarContrasena
                  ? 'Mostrar contraseña'
                  : 'Ocultar contraseña',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TarjetaLogin(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.azulUpt,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.loginCaptchaTitle,
                      style: textos.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (estaCargandoCaptcha)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Cargando CAPTCHA...'),
                      ],
                    ),
                  ),
                )
              else if (state is LoginCaptchaListoState) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 78,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.superficie,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: _construirImagenCaptcha(
                          state.captcha.imagenBase64,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: estaVerificando
                          ? null
                          : () => widget.viewModel.cargarCaptcha(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Solicitar nuevo CAPTCHA',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _captchaController,
                enabled: !estaVerificando && !estaCargandoCaptcha,
                keyboardType: TextInputType.number,
                maxLength: 5,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Escribe el número de la imagen',
                  fillColor: AppColors.superficieBaja,
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: estaVerificando || estaCargandoCaptcha
              ? null
              : _enviarFormulario,
          icon: estaVerificando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward),
          label: Text(
            estaVerificando
                ? 'Verificando con la intranet...'
                : AppStrings.loginVerify,
          ),
        ),
        if (state is LoginErrorState && state.puedeReintentarCaptcha) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: estaVerificando
                ? null
                : () => widget.viewModel.cargarCaptcha(),
            icon: const Icon(Icons.refresh),
            label: const Text('Solicitar nuevo CAPTCHA'),
          ),
        ],
        const SizedBox(height: 24),
        const _PieSeguridad(),
      ],
    );
  }

  Widget _construirPasoGoogle(BuildContext context, LoginState state) {
    final textos = Theme.of(context).textTheme;
    final preparado = state is LoginGooglePreparadoState ? state : null;
    final esperando = state is LoginEsperandoGoogleState ? state : null;

    return _contenedor(
      children: [
        const EncabezadoLogin(
          titulo: AppStrings.loginStep2Title,
          subtitulo: AppStrings.loginStep2Subtitle,
        ),
        const SizedBox(height: 24),
        const IndicadorPasoLogin(
          paso: 2,
          descripcion: AppStrings.loginStep2,
        ),
        const SizedBox(height: 24),
        TarjetaLogin(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.verdeFondo,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.verdeAutorizado,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identidad de intranet verificada',
                      style: textos.labelLarge?.copyWith(
                        color: AppColors.verdeAutorizado,
                      ),
                    ),
                    if (preparado?.codigo != null) ...[
                      const SizedBox(height: 2),
                      Text(preparado!.codigo!, style: textos.titleLarge),
                    ],
                    if (preparado?.nombreApellidos != null)
                      Text(
                        preparado!.nombreApellidos!,
                        style: textos.bodyMedium?.copyWith(
                          color: AppColors.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (preparado != null) ...[
          Text(
            'Continúa con tu cuenta institucional de Google Workspace '
            '(@virtual.upt.pe) para finalizar.',
            style: textos.bodyMedium?.copyWith(
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => widget.viewModel.ejecutarContinuarGoogle(
              urlAutorizacion: preparado.urlAutorizacion,
              transaccionId: preparado.transaccionId,
              expiraEn: preparado.expiraEn,
            ),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Continuar con Google'),
          ),
        ],
        if (esperando != null) ...[
          TarjetaLogin(
            child: Column(
              children: [
                const LinearProgressIndicator(minHeight: 4),
                const SizedBox(height: 16),
                Text(
                  esperando.mensajeInformativo,
                  textAlign: TextAlign.center,
                  style: textos.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Completa la autenticación en el navegador y regresa a '
                  'esta pantalla.',
                  textAlign: TextAlign.center,
                  style: textos.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                widget.viewModel.abrirNavegadorGoogle(esperando.urlAutorizacion),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Reabrir ventana de Google'),
          ),
        ],
        const SizedBox(height: 24),
        const AvisoDispositivoLogin(),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => widget.viewModel.cargarCaptcha(),
          icon: const Icon(Icons.arrow_back),
          label: const Text(AppStrings.loginBackToStep1),
        ),
      ],
    );
  }
}

class _ConfirmacionExitosa extends StatelessWidget {
  const _ConfirmacionExitosa();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.verdeFondo,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.verdeAutorizado,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Inicio de sesión exitoso',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _PieSeguridad extends StatelessWidget {
  const _PieSeguridad();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: AppColors.verdeAutorizado,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            AppStrings.loginFooter,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textoSecundario),
          ),
        ),
      ],
    );
  }
}
