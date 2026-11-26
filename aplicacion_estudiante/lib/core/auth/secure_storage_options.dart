import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Las credenciales y el secreto del QR pertenecen a este teléfono y solo
/// se leen desbloqueado. No se sincronizan por iCloud ni migran a otro equipo.
const almacenamientoSeguro = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
  ),
);
