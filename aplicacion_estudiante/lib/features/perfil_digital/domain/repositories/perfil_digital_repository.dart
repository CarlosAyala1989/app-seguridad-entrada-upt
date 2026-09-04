import '../entities/perfil_digital.dart';

abstract interface class PerfilDigitalRepository {
  Future<PerfilDigital?> obtenerPerfilActual();
}
