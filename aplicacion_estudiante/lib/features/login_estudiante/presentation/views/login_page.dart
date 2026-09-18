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
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Completa la autenticación institucional en la ventana abierta de Google.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => widget.viewModel.abrirNavegadorGoogle(
                          state.urlAutorizacion,
                        ),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Reabrir navegador'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is LoginCargandoCaptchaState ||
                state is LoginVerificandoIntranetState) {
              final mensaje = state is LoginCargandoCaptchaState
                  ? 'Obteniendo CAPTCHA institucional...'
                  : 'Verificando datos con la intranet...';
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(mensaje),
                  ],
                ),
              );
            }

            if (state is LoginCaptchaListoState) {
              _transaccionCaptchaActual = state.captcha.transaccionId;
            }

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
                    'Ingrese sus credenciales de intranet para continuar con Google Workspace.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codigoController,
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
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Contraseña de intranet',
                      hintText: '1 a 6 dígitos',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state is LoginCaptchaListoState) ...[
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.grey.shade200,
                            width: 150,
                            height: 50,
                            child: Builder(
                              builder: (context) {
                                try {
                                  final bytes = base64Decode(
                                    state.captcha.imagenBase64,
                                  );
                                  return Image.memory(
                                    bytes,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  );
                                } catch (_) {
                                  return const Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: () => widget.viewModel.cargarCaptcha(),
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Recargar CAPTCHA',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _captchaController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Código CAPTCHA',
                      hintText: 'Ingrese los números de la imagen',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _enviarFormulario,
                    icon: const Icon(Icons.login),
                    label: const Text('Verificar y Continuar con Google'),
                  ),
                  if (state is LoginErrorState &&
                      state.puedeReintentarCaptcha) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => widget.viewModel.cargarCaptcha(),
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
