import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/usuario.dart';
import '../states/login_state.dart';
import '../viewmodels/login_view_model.dart';

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
      appBar: AppBar(
        title: const Text('Acceso Institucional UPT'),
        centerTitle: true,
      ),
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
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Inicio de sesión exitoso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 2. Google preparado: botón explícito para abrir la pestaña OAuth
            if (state is LoginGooglePreparadoState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.green,
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Identidad de intranet verificada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Continúa con tu cuenta institucional de Google Workspace (@virtual.upt.pe) para finalizar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            widget.viewModel.ejecutarContinuarGoogle(
                              urlAutorizacion: state.urlAutorizacion,
                              transaccionId: state.transaccionId,
                              expiraEn: state.expiraEn,
                            ),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Continuar con Google'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 3. Esperando Google: polling activo con opción de reabrir enlace
            if (state is LoginEsperandoGoogleState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        state.mensajeInformativo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Completa la autenticación en el navegador y regresa a esta pantalla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => widget.viewModel.abrirNavegadorGoogle(
                          state.urlAutorizacion,
                        ),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Reabrir ventana de Google'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final estaVerificando = state is LoginVerificandoIntranetState;
            final estaCargandoCaptcha = state is LoginCargandoCaptchaState;

            if (state is LoginCaptchaListoState) {
              _transaccionCaptchaActual = state.captcha.transaccionId;
            }

            // 4. Formulario de credenciales y CAPTCHA
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state is LoginErrorState) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.mensaje,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Ingreso de Estudiantes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingrese sus credenciales de intranet para validar su identidad.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codigoController,
                    enabled: !estaVerificando,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Código institucional',
                      hintText: 'Ej. 2022074266',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contrasenaController,
                    enabled: !estaVerificando,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Contraseña de intranet',
                      hintText: '1 a 6 dígitos numéricos',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            color: Colors.grey.shade100,
                            padding: const EdgeInsets.all(4),
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
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _captchaController,
                    enabled: !estaVerificando && !estaCargandoCaptcha,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Código CAPTCHA',
                      hintText: 'Dígitos de la imagen',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                      counterText: '',
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
                          : 'Verificar datos de Intranet',
                    ),
                  ),
                  if (state is LoginErrorState &&
                      state.puedeReintentarCaptcha) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: estaVerificando
                          ? null
                          : () => widget.viewModel.cargarCaptcha(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Solicitar nuevo CAPTCHA'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
