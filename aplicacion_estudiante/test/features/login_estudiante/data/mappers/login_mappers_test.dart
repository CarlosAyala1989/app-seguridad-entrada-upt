import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/mappers/login_mappers.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/models/flujo_login_dto.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/models/sesion_estudiante_dto.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/flujo_login.dart';

void main() {
  group('Login Mappers & DTOs', () {
    test(
      'SesionEstudianteDto se mapea correctamente a dominio con rol permitido',
      () {
        final json = {
          'tipo_token': 'Bearer',
          'token_acceso': 'acceso_123',
          'token_renovacion': 'renovacion_456',
          'token_acceso_expira_en': '2026-09-18T12:00:00.000Z',
          'token_renovacion_expira_en': '2026-09-25T12:00:00.000Z',
          'usuario': {
            'id': 10,
            'codigo_institucional': '2022074266',
            'correo_institucional': 'ca2022074266@virtual.upt.pe',
            'nombres': 'CARLOS DANIEL',
            'apellidos': 'AYALA RAMOS',
            'roles': ['ESTUDIANTE'],
          },
        };

        final dto = SesionEstudianteDto.fromJson(json);
        final entidad = dto.toDomain();

        expect(entidad.tipoToken, 'Bearer');
        expect(entidad.tokenAcceso, 'acceso_123');
        expect(entidad.usuario.codigoInstitucional, '2022074266');
        expect(entidad.usuario.roles, contains('ESTUDIANTE'));
        expect(entidad.tieneRolPermitido, isTrue);
      },
    );

    test('VerificacionIntranetDto lee la escuela profesional', () {
      final entidad = VerificacionIntranetDto.fromJson({
        'codigo': '2022074266',
        'nombre_apellidos': 'AYALA RAMOS, CARLOS DANIEL',
        'escuela_profesional': 'Ingeniería de Sistemas',
        'verificacion_intranet_id': '8bcdbcea-0682-4c77-a828-21855d6bcdfa',
        'verificacion_expira_en': '2026-10-26T19:10:00.000Z',
      }).toDomain();

      expect(entidad.escuelaProfesional, 'Ingeniería de Sistemas');
      expect(entidad.nombreApellidos, 'AYALA RAMOS, CARLOS DANIEL');
    });

    test('VerificacionIntranetDto acepta escuela null o ausente', () {
      final base = {
        'codigo': '2022074266',
        'nombre_apellidos': 'AYALA RAMOS, CARLOS DANIEL',
        'verificacion_intranet_id': '8bcdbcea-0682-4c77-a828-21855d6bcdfa',
        'verificacion_expira_en': '2026-10-26T19:10:00.000Z',
      };

      final conNull = VerificacionIntranetDto.fromJson({
        ...base,
        'escuela_profesional': null,
      }).toDomain();
      final sinCampo = VerificacionIntranetDto.fromJson(base).toDomain();

      expect(conNull.escuelaProfesional, isNull);
      expect(sinCampo.escuelaProfesional, isNull);
    });

    test('CaptchaIntranetDto parsea transaccion y fecha ISO 8601', () {
      final json = {
        'transaccion_id': '0664b410-145e-4ef3-8d98-1055d8d57ee9',
        'imagen_base64':
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        'tipo_imagen': 'image/png',
        'expira_en': '2026-09-18T15:00:00.000Z',
      };

      final dto = CaptchaIntranetDto.fromJson(json);
      final entidad = dto.toDomain();

      expect(entidad.transaccionId, '0664b410-145e-4ef3-8d98-1055d8d57ee9');
      expect(entidad.tipoImagen, 'image/png');
      expect(entidad.expiraEn.isUtc, isTrue);
    });

    test('AutorizacionGoogleDto parsea url_autorizacion a Uri nativo', () {
      final json = {
        'transaccion_id': 'b46b2f2d-89e2-437b-aa27-10cb3b8f493c',
        'url_autorizacion':
            'https://accounts.google.com/o/oauth2/v2/auth?state=123',
        'expira_en': '2026-09-18T15:10:00.000Z',
      };

      final dto = AutorizacionGoogleDto.fromJson(json);
      final entidad = dto.toDomain();

      expect(entidad.urlAutorizacion, isA<Uri>());
      expect(entidad.urlAutorizacion.host, 'accounts.google.com');
    });

    test('EstadoGoogleDto mapea cadenas de estado a enums', () {
      final jsonCompleta = {'estado': 'COMPLETA'};
      final jsonPendiente = {'estado': 'PENDIENTE'};

      expect(
        EstadoGoogleDto.fromJson(jsonCompleta).toDomain().estado,
        EstadoGoogle.completa,
      );
      expect(
        EstadoGoogleDto.fromJson(jsonPendiente).toDomain().estado,
        EstadoGoogle.pendiente,
      );
    });
  });
}
