import '../../domain/entities/perfil_digital.dart';
import '../models/perfil_digital_dto.dart';

extension PerfilDigitalMapper on PerfilDigitalDto {
  PerfilDigital toDomain() => PerfilDigital(
        nombreCompleto: fullName,
        codigoInstitucional: institutionalCode,
        correoInstitucional: institutionalEmail,
        rol: role,
        escuela: school,
        estadoVerificacion: verificationStatus,
        estadoAcceso: accessStatus,
        fotoUrl: photoUrl,
      );
}
