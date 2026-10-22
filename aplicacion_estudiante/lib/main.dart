import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'shared/l10n/app_strings.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const IngresoUptApp());
}

class IngresoUptApp extends StatelessWidget {
  const IngresoUptApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final appReal = home == null;
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: appReal ? AppDependencies.navigatorKey : null,
      // El bloqueo con biometría (US-22) cubre todas las pantallas.
      builder: appReal ? AppDependencies.envolverConBloqueo : null,
      home: home ?? AppDependencies.buildHome(),
    );
  }
}
