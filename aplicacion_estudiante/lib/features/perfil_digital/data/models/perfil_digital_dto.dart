import '../../../../core/error/failure.dart';

final class PerfilDigitalDto {
  const PerfilDigitalDto({
    required this.fullName,
    required this.institutionalCode,
    required this.institutionalEmail,
    required this.role,
    required this.school,
    required this.verificationStatus,
    required this.accessStatus,
    this.photoUrl,
  });

  factory PerfilDigitalDto.fromJson(Map<String, Object?> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw DataFailure('El campo "$key" no es válido.');
      }
      return value;
    }

    final photo = json['photoUrl'];
    if (photo != null && photo is! String) {
      throw const DataFailure('El campo "photoUrl" no es válido.');
    }

    return PerfilDigitalDto(
      fullName: requiredString('fullName'),
      institutionalCode: requiredString('institutionalCode'),
      institutionalEmail: requiredString('institutionalEmail'),
      role: requiredString('role'),
      school: requiredString('school'),
      verificationStatus: requiredString('verificationStatus'),
      accessStatus: requiredString('accessStatus'),
      photoUrl: photo as String?,
    );
  }

  final String fullName;
  final String institutionalCode;
  final String institutionalEmail;
  final String role;
  final String school;
  final String verificationStatus;
  final String accessStatus;
  final String? photoUrl;
}
