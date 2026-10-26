import 'package:flutter/material.dart';

/// Colores institucionales de la UPT (guía de estilo de Google Stitch).
///
/// Se definen una sola vez aquí para que todas las pantallas usen los mismos
/// valores y el diseño se pueda cambiar desde un solo archivo.
final class AppColors {
  const AppColors._();

  // Azul marino institucional
  static const azulUpt = Color(0xFF16285C);
  static const azulProfundo = Color(0xFF001244);
  static const azulSuave = Color(0xFF8091CB);

  // Fondos y superficies
  static const fondo = Color(0xFFF8F9FF);
  static const superficieBaja = Color(0xFFEFF4FF);
  static const superficie = Color(0xFFE6EEFF);

  // Textos y bordes
  static const texto = Color(0xFF121C2A);
  static const textoSecundario = Color(0xFF45464F);
  static const borde = Color(0xFF757680);
  static const bordeSuave = Color(0xFFC5C6D1);

  // Acento dorado del escudo (detalles, no botones principales)
  static const dorado = Color(0xFF904D00);
  static const doradoClaro = Color(0xFFFFDCC3);

  // Estados de acceso
  static const verdeAutorizado = Color(0xFF1B7A3A);
  static const verdeFondo = Color(0xFFE3F6E8);
  static const rojoError = Color(0xFFBA1A1A);
  static const rojoFondo = Color(0xFFFFDAD6);
  static const rojoTexto = Color(0xFF93000A);
}

/// Radios de las esquinas (sm 4, md 8, lg 12, xl 16).
final class AppRadius {
  const AppRadius._();

  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

final class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.azulUpt,
    ).copyWith(
      primary: AppColors.azulUpt,
      onPrimary: Colors.white,
      primaryContainer: AppColors.superficie,
      onPrimaryContainer: AppColors.azulProfundo,
      secondary: AppColors.dorado,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.doradoClaro,
      surface: Colors.white,
      onSurface: AppColors.texto,
      onSurfaceVariant: AppColors.textoSecundario,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.superficieBaja,
      surfaceContainer: AppColors.superficieBaja,
      surfaceContainerHigh: AppColors.superficie,
      outline: AppColors.borde,
      outlineVariant: AppColors.bordeSuave,
      error: AppColors.rojoError,
      errorContainer: AppColors.rojoFondo,
      onErrorContainer: AppColors.rojoTexto,
    );

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final texto = base.textTheme.apply(
      bodyColor: AppColors.texto,
      displayColor: AppColors.texto,
    );

    final bordeRedondeado = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
    const tamanoBoton = Size.fromHeight(52);
    const textoBoton = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fondo,
      textTheme: texto.copyWith(
        headlineLarge: texto.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.azulUpt,
        ),
        headlineMedium: texto.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.azulUpt,
        ),
        titleLarge: texto.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: texto.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: texto.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.azulUpt,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.azulUpt,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.bordeSuave),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.azulUpt,
          foregroundColor: Colors.white,
          minimumSize: tamanoBoton,
          shape: bordeRedondeado,
          textStyle: textoBoton,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.azulUpt,
          backgroundColor: Colors.white,
          minimumSize: tamanoBoton,
          shape: bordeRedondeado,
          side: const BorderSide(color: AppColors.bordeSuave),
          textStyle: textoBoton,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.azulUpt,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        prefixIconColor: AppColors.textoSecundario,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.bordeSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.bordeSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.azulUpt, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.bordeSuave,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.azulProfundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.azulUpt,
        linearTrackColor: AppColors.superficie,
      ),
    );
  }
}
