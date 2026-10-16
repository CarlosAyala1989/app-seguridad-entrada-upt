import '../domain/entities/aviso_privacidad.dart';

/// Texto del aviso que se muestra en la app. Al cambiarlo, sube la versión.
///
/// Describe solo lo que la app y la API hacen hoy; si el equipo cambia qué
/// datos se guardan o cuánto tiempo, este texto debe actualizarse.
final avisoPrivacidadVigente = AvisoPrivacidad(
  version: '1.0',
  vigenteDesde: DateTime(2026, 10, 19),
  secciones: const [
    SeccionAviso(
      titulo: 'Quién trata tus datos',
      parrafos: [
        'La Universidad Privada de Tacna (UPT), a través de la aplicación '
            'Identidad Digital UPT, que sirve para acreditar tu identidad y '
            'tu autorización de ingreso al campus.',
      ],
    ),
    SeccionAviso(
      titulo: 'Qué datos usa la aplicación',
      parrafos: [
        'Identidad institucional: nombre, código, correo @virtual.upt.pe, '
            'fotografía, rol, escuela y el estado de tu verificación y de tu '
            'acceso.',
        'Inicio de sesión: tu código y contraseña de la intranet se usan solo '
            'para comprobar que eres miembro de la UPT. La aplicación no '
            'guarda tu contraseña.',
        'Sesión: los datos de tu sesión se guardan en el almacenamiento '
            'seguro de tu teléfono y se borran al cerrar sesión.',
        'Ubicación: latitud, longitud, precisión y hora, únicamente cuando '
            'pides un código QR.',
      ],
    ),
    SeccionAviso(
      titulo: 'Cómo se usa tu ubicación',
      parrafos: [
        'Se obtiene solo cuando pulsas «Generar código QR» con la aplicación '
            'abierta. Nunca se usa en segundo plano.',
        'Se envía al servidor de la UPT para comprobar que estás en una zona '
            'permitida del campus. El servidor la registra junto al código '
            'emitido para dejar constancia de esa comprobación.',
        'No va dentro del código QR: el código es un identificador opaco que '
            'no contiene tu nombre, correo ni coordenadas.',
        'Puedes negar el permiso. Sin él no podrás generar el código QR, pero '
            'podrás seguir viendo tu identidad digital y tu estado de ingreso.',
      ],
    ),
    SeccionAviso(
      titulo: 'Para qué se usan tus datos',
      parrafos: [
        'Para verificar que eres miembro de la UPT, mostrar tu identidad '
            'digital, emitir tu código QR temporal y validar tu ingreso en '
            'los puntos de acceso.',
        'La aplicación no usa servicios de publicidad ni de analítica.',
      ],
    ),
    SeccionAviso(
      titulo: 'Tus derechos',
      parrafos: [
        'Conforme a la Ley N.° 29733, Ley de Protección de Datos Personales, '
            'puedes solicitar a la UPT el acceso, la rectificación, la '
            'cancelación o la oposición al tratamiento de tus datos.',
        'Para hacerlo o para cualquier consulta, acude a la oficina de '
            'soporte de la universidad.',
      ],
    ),
  ],
);
