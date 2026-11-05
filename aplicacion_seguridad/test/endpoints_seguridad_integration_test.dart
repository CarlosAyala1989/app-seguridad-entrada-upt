import 'package:flutter_test/flutter_test.dart';
import 'package:aplicacion_seguridad/core/config/api_config.dart';
import 'package:aplicacion_seguridad/core/utils/uuid_generator.dart';
import 'package:aplicacion_seguridad/features/validacion/data/models/resultado_validacion_model.dart';
import 'package:aplicacion_seguridad/features/incidencias/data/models/incidencia_model.dart';
import 'package:aplicacion_seguridad/features/turnos/data/models/turno_model.dart';
import 'package:aplicacion_seguridad/features/busqueda/data/models/usuario_busqueda_model.dart';
import 'package:aplicacion_seguridad/features/historial/data/models/registro_historial_model.dart';
import 'package:aplicacion_seguridad/features/administracion/data/models/bloqueo_model.dart';
import 'package:aplicacion_seguridad/features/administracion/data/models/regla_acceso_model.dart';

void main() {
  group('Endpoints de Seguridad (27 Octubre 2026) - Modelos y Contratos', () {
    test('Issue #16 & RFC 4122: UuidGenerator genera UUID v4 válido para clave_idempotencia', () {
      final uuid1 = UuidGenerator.v4();
      final uuid2 = UuidGenerator.v4();

      final regexV4 = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

      expect(regexV4.hasMatch(uuid1), isTrue, reason: 'UUID 1 debe cumplir formato RFC 4122 v4');
      expect(regexV4.hasMatch(uuid2), isTrue, reason: 'UUID 2 debe cumplir formato RFC 4122 v4');
      expect(uuid1, isNot(equals(uuid2)), reason: 'Dos UUIDs consecutivos deben ser distintos');
    });

    test('Issue #9 & #24: ResultadoValidacionModel parsea registro_id, turno_id y valida autorización defensiva', () {
      final jsonAutorizado = {
        'resultado': 'AUTORIZADO',
        'motivo': null,
        'mensaje': 'Acceso autorizado al campus.',
        'registro_id': 1420,
        'turno_id': 45,
        'puede_confirmar': true,
        'accion_sugerida': 'PERMITIR_PASO',
        'identidad': {
          'id': 101,
          'nombre_completo': 'Juan Pérez Ramos',
          'codigo': '2023-119001',
          'correo': 'jperez@upt.pe',
          'roles': ['ESTUDIANTE'],
          'foto_url': 'https://api-moviles.fottuto.men/storage/fotos/101.jpg',
        },
      };

      final modelo = ResultadoValidacionModel.fromJson(jsonAutorizado);

      expect(modelo.esAutorizado, isTrue);
      expect(modelo.registroId, equals(1420));
      expect(modelo.turnoId, equals(45));
      expect(modelo.puedeConfirmar, isTrue);
      expect(modelo.puedeConfirmarAcceso, isTrue);
      expect(modelo.accionSugerida, equals('PERMITIR_PASO'));
      expect(modelo.identidad?.nombreCompleto, equals('Juan Pérez Ramos'));
    });

    test('Issue #9 & #24: Validación defensiva rechaza acceso si puede_confirmar es false aun con AUTORIZADO', () {
      final jsonTrampa = {
        'resultado': 'AUTORIZADO',
        'mensaje': 'Autorizado pero turno o punto no coincide',
        'registro_id': 1421,
        'puede_confirmar': false, // Servidor prohíbe confirmar
        'identidad': {
          'id': 102,
          'nombre_completo': 'Carlos Gómez',
          'codigo': '2023-119002',
          'correo': 'cgomez@upt.pe',
          'roles': ['ESTUDIANTE'],
        },
      };

      final modelo = ResultadoValidacionModel.fromJson(jsonTrampa);

      expect(modelo.resultado, equals('AUTORIZADO'));
      expect(modelo.puedeConfirmar, isFalse);
      // La regla defensiva del cliente no debe permitir confirmar el acceso:
      expect(modelo.puedeConfirmarAcceso, isFalse);
    });

    test('Issue #10 & #15: Denegación con registro_id permite reporte de incidencias y omite datos de identidad', () {
      final jsonDenegado = {
        'resultado': 'DENEGADO',
        'motivo': 'BLOQUEO_ADMINISTRATIVO',
        'mensaje': 'Acceso denegado por sanción vigente.',
        'registro_id': 1425,
        'puede_confirmar': false,
        'accion_sugerida': 'RETENER_CREDENCIAL',
        // Backend no expone identidad en denegación por privacidad
        'identidad': null,
      };

      final modelo = ResultadoValidacionModel.fromJson(jsonDenegado);

      expect(modelo.esAutorizado, isFalse);
      expect(modelo.motivo, equals('BLOQUEO_ADMINISTRATIVO'));
      expect(modelo.registroId, equals(1425));
      expect(modelo.accionSugerida, equals('RETENER_CREDENCIAL'));
      expect(modelo.identidad, isNull);
    });

    test('Issue #16: IncidenciaModel serializa y deserializa con tipos válidos y clave de idempotencia', () {
      final uuid = UuidGenerator.v4();
      final incidencia = IncidenciaModel(
        id: 12,
        registroAccesoId: 1425,
        tipo: 'SUPLANTACION',
        observacion: 'La foto mostrada en el carnet físico no coincide con la persona.',
        claveIdempotencia: uuid,
        creadoEn: DateTime.parse('2026-10-30T10:15:00Z'),
      );

      final json = incidencia.toJson();

      expect(json['tipo'], equals('SUPLANTACION'));
      expect(json['observacion'], contains('foto mostrada'));
      expect(json['clave_idempotencia'], equals(uuid));

      final deserializado = IncidenciaModel.fromJson(json);
      expect(deserializado.id, equals(12));
      expect(deserializado.registroAccesoId, equals(1425));
      expect(deserializado.tipo, equals('SUPLANTACION'));
      expect(deserializado.claveIdempotencia, equals(uuid));
    });

    test('Issue #18: TurnoModel maneja estado activo/cerrado correctamente', () {
      final jsonAbierto = {
        'id': 50,
        'usuario_seguridad_id': 7,
        'punto_acceso_id': 1,
        'iniciado_en': '2026-10-30T07:00:00Z',
        'cerrado_en': null,
      };

      final turnoAbierto = TurnoModel.fromJson(jsonAbierto);
      expect(turnoAbierto.id, equals(50));
      expect(turnoAbierto.estaAbierto, isTrue);

      final jsonCerrado = {
        'id': 50,
        'usuario_seguridad_id': 7,
        'punto_acceso_id': 1,
        'iniciado_en': '2026-10-30T07:00:00Z',
        'cerrado_en': '2026-10-30T15:00:00Z',
      };

      final turnoCerrado = TurnoModel.fromJson(jsonCerrado);
      expect(turnoCerrado.estaAbierto, isFalse);
    });

    test('Issue #14: UsuarioBusquedaModel enmascara datos y fija permiteIngreso en false', () {
      final jsonBusqueda = {
        'id': 200,
        'codigo': '2021-118022',
        'nombre_completo': 'María Elena Flores',
        'correo': 'mflores@upt.pe',
        'roles': ['ESTUDIANTE'],
        'estado_autorizacion': 'AUTORIZADO',
        'identidad_verificada': true,
        'bloqueo_vigente': false,
        'permite_ingreso': false, // Siempre false por contrato de búsqueda
      };

      final modelo = UsuarioBusquedaModel.fromJson(jsonBusqueda);

      expect(modelo.id, equals(200));
      expect(modelo.permiteIngreso, isFalse, reason: 'Búsqueda manual nunca autoriza ingreso directamente');
      expect(modelo.identidadVerificada, isTrue);
      expect(modelo.bloqueoVigente, isFalse);
      expect(modelo.esHabilitado, isTrue);
    });

    test('Issue #18: RegistroHistorialModel parsea código enmascarado y turno_id', () {
      final jsonHistorial = {
        'id': 991,
        'codigo_enmascarado': '******0001',
        'resultado': 'AUTORIZADO',
        'motivo_denegacion': null,
        'punto_acceso_id': 1,
        'turno_id': 45,
        'creado_en': '2026-10-30T11:20:00Z',
      };

      final registro = RegistroHistorialModel.fromJson(jsonHistorial);

      expect(registro.id, equals('991'));
      expect(registro.idNumerico, equals(991));
      expect(registro.codigoEnmascarado, equals('******0001'));
      expect(registro.esAutorizado, isTrue);
      expect(registro.turnoId, equals(45));
    });

    test('Issue #20: BloqueoModel gestiona creación y estado vigente', () {
      final jsonBloqueo = {
        'id': 15,
        'usuario_id': 200,
        'motivo': 'Sanción disciplinaria 48 horas',
        'bloqueado_por': 1,
        'creado_en': '2026-10-30T08:00:00Z',
        'rehabilitado_en': null,
        'rehabilitado_por': null,
      };

      final bloqueo = BloqueoModel.fromJson(jsonBloqueo);

      expect(bloqueo.id, equals(15));
      expect(bloqueo.esVigente, isTrue);
      expect(bloqueo.rehabilitadoEn, isNull);
    });

    test('Issue #22: ReglaAccesoModel serializa y deserializa reglas horarias y por rol', () {
      final jsonRegla = {
        'id': 3,
        'rol': 'ESTUDIANTE',
        'estado_usuario': 'ACTIVO',
        'accion': 'PERMITIR',
        'dias_semana': [1, 2, 3, 4, 5],
        'hora_inicio': '06:30:00',
        'hora_fin': '22:30:00',
        'activo': true,
      };

      final regla = ReglaAccesoModel.fromJson(jsonRegla);

      expect(regla.id, equals(3));
      expect(regla.rol, equals('ESTUDIANTE'));
      expect(regla.accion, equals('PERMITIR'));
      expect(regla.diasSemana, equals([1, 2, 3, 4, 5]));
      expect(regla.horaInicio, equals('06:30:00'));
      expect(regla.activo, isTrue);

      final jsonGenerado = regla.toJson();
      expect(jsonGenerado['rol'], equals('ESTUDIANTE'));
      expect(jsonGenerado['hora_fin'], equals('22:30:00'));
    });

    test('ApiConfig: Rutas y URLs de endpoints de seguridad están correctamente estructuradas', () {
      expect(ApiConfig.validarQrPath, equals('/ingresos/validar'));
      expect(ApiConfig.busquedaManualSeguridadPath, equals('/seguridad/identidades/buscar'));
      expect(ApiConfig.turnosSeguridadPath, equals('/seguridad/turnos'));
      expect(ApiConfig.turnoActualSeguridadPath, equals('/seguridad/turnos/actual'));
      expect(ApiConfig.cerrarTurnoPath(50), equals('/seguridad/turnos/50/cerrar'));
      expect(ApiConfig.registrarIncidenciaPath(1425), equals('/ingresos/1425/incidencias'));
      expect(ApiConfig.bloqueosUsuarioAdminPath(200), equals('/administracion/usuarios/200/bloqueos'));
      expect(ApiConfig.rehabilitarBloqueoAdminPath(200, 15), equals('/administracion/usuarios/200/bloqueos/15/rehabilitar'));
      expect(ApiConfig.reglasAccesoAdminPath, equals('/administracion/reglas-acceso'));
    });
  });
}
