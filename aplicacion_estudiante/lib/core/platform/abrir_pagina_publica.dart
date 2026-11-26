import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal_config.dart';

/// Safari dentro de la app en iOS; conserva el navegador habitual en las
/// demás plataformas. Devuelve false si no se pudo abrir la página.
Future<bool> abrirPaginaPublica(Uri uri) async {
  if (LegalConfig.uriPublica(uri.toString()) == null) return false;
  try {
    return await launchUrl(
      uri,
      mode: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
          ? LaunchMode.inAppBrowserView
          : LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    return false;
  }
}
