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
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home ?? AppDependencies.buildHome(),
    );
  }
}
