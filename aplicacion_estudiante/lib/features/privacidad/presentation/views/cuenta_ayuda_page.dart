import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/config/legal_config.dart';
import '../../../../core/platform/abrir_pagina_publica.dart';
import '../../../../shared/l10n/app_strings.dart';

class CuentaAyudaPage extends StatefulWidget {
  const CuentaAyudaPage({
    super.key,
    required this.onVerAvisoPrivacidad,
    this.config = const LegalConfig(),
    this.abrirPagina = abrirPaginaPublica,
    this.abrirAjustes = Geolocator.openAppSettings,
  });

  final VoidCallback onVerAvisoPrivacidad;
  final LegalConfig config;
  final Future<bool> Function(Uri) abrirPagina;
  final Future<bool> Function() abrirAjustes;

  @override
  State<CuentaAyudaPage> createState() => _CuentaAyudaPageState();
}

class _CuentaAyudaPageState extends State<CuentaAyudaPage> {
  bool _abriendo = false;

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _abrir(String url) async {
    if (_abriendo) return;
    final uri = LegalConfig.uriPublica(url);
    if (uri == null) {
      _avisar(AppStrings.pageUnavailable);
      return;
    }
    setState(() => _abriendo = true);
    try {
      if (!await widget.abrirPagina(uri)) _avisar(AppStrings.pageOpenError);
    } catch (_) {
      _avisar(AppStrings.pageOpenError);
    } finally {
      if (mounted) setState(() => _abriendo = false);
    }
  }

  Future<void> _eliminarCuenta() async {
    if (_abriendo) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteAccount),
        content: const SingleChildScrollView(
          child: Text(AppStrings.deleteAccountExplanation),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.continueLabel),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await _abrir(widget.config.eliminarCuenta);
    }
  }

  Future<void> _ajustes() async {
    try {
      if (!await widget.abrirAjustes()) _avisar(AppStrings.settingsOpenError);
    } catch (_) {
      _avisar(AppStrings.settingsOpenError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.accountHelpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(AppStrings.institutionalAccountNotice),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text(AppStrings.privacyTitle),
              onTap: widget.onVerAvisoPrivacidad,
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text(AppStrings.publicPrivacyPolicy),
              enabled: !_abriendo,
              onTap: () => _abrir(widget.config.privacidad),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text(AppStrings.supportTitle),
              enabled: !_abriendo,
              onTap: () => _abrir(widget.config.soporte),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(AppStrings.permissionSettings),
              subtitle: const Text(AppStrings.permissionSettingsHelp),
              onTap: _ajustes,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text(AppStrings.deleteAccount),
              subtitle: const Text(AppStrings.deleteAccountHelp),
              enabled: !_abriendo,
              onTap: _eliminarCuenta,
            ),
          ],
        ),
      ),
    );
  }
}
