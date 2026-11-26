import '../domain/entities/aviso_privacidad.dart';

/// Texto del aviso que se muestra en la app. Al cambiarlo, sube la versión.
///
/// Describe solo lo que la app y la API hacen hoy; si el equipo cambia qué
/// datos se guardan o cuánto tiempo, este texto debe actualizarse.
final avisoPrivacidadVigente = AvisoPrivacidad(
  version: '1.2',
  vigenteDesde: DateTime(2026, 11, 26),
  secciones: const [
    SeccionAviso(
      titulo: 'Quién trata tus datos',
      parrafos: [
        'Carlos Daniel Ayala Ramos es el responsable de este servicio de '
            'identidad digital para estudiantes de la Universidad Privada de '
            'Tacna (UPT). La app acredita tu identidad y autorización de ingreso '
            'al campus. Las cuentas académicas y de Google son servicios '
            'institucionales independientes.',
        'Contacto de soporte y privacidad: ca2022074266@virtual.upt.pe.',
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
        'QR sin conexión: un identificador aleatorio de esta instalación '
            'vincula el teléfono con tu cuenta. El secreto para generar los '
            'códigos se guarda en el almacenamiento seguro del teléfono.',
        'Ingresos y avisos: resultado, fecha y hora, punto de acceso y '
            'alertas de seguridad asociados con tu identidad digital.',
      ],
    ),
    SeccionAviso(
      titulo: 'Cómo se usa tu ubicación',
      parrafos: [
        'Se obtiene cuando pulsas «Generar código QR» y en las renovaciones '
            'del código mientras esa pantalla permanece abierta y la app '
            'está en primer plano. Las renovaciones se detienen al salir de '
            'la app. No se solicita ubicación en segundo plano.',
        'Se envía al servicio de identidad para comprobar que estás en una zona '
            'permitida del campus. El servidor la registra junto al código '
            'emitido para dejar constancia de esa comprobación.',
        'No va dentro del código QR: el código es un identificador opaco que '
            'no contiene tu nombre, correo ni coordenadas.',
        'Puedes negar el permiso. Sin él no podrás generar el código QR, pero '
            'podrás seguir viendo tu identidad digital, historial y avisos. '
            'Un QR sin conexión previamente preparado no usa el GPS.',
        'Puedes retirar el permiso desde «Cuenta y ayuda» → «Gestionar '
            'permisos del teléfono», o desde los ajustes del sistema.',
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
      titulo: 'Autenticación y servicios que intervienen',
      parrafos: [
        'El servicio de identidad valida tus credenciales con la intranet '
            'académica de la UPT. Google verifica la cuenta institucional '
            '@virtual.upt.pe y facilita los datos de identidad autorizados '
            'para completar la verificación.',
        'El servicio de identidad y los puntos de control procesan los datos '
            'necesarios para validar el ingreso. En «Política de privacidad '
            'en línea» puedes consultar quién administra el servicio, sus '
            'proveedores y los canales de atención.',
        'No se venden datos ni se vincula tu actividad con otras aplicaciones '
            'para publicidad. No se utiliza un identificador publicitario.',
      ],
    ),
    SeccionAviso(
      titulo: 'Biometría opcional',
      parrafos: [
        'Si activas el bloqueo, Face ID, Touch ID o el código del teléfono '
            'comprueban tu identidad mediante el sistema operativo. La app '
            'solo recibe el resultado de esa comprobación; no accede a tu '
            'rostro ni a tus huellas y no los envía al servidor.',
        'Puedes desactivar este bloqueo desde tu identidad digital. También '
            'puedes cerrar sesión desde la pantalla de bloqueo y volver a '
            'autenticarte con tus credenciales institucionales.',
      ],
    ),
    SeccionAviso(
      titulo: 'Conservación y eliminación',
      parrafos: [
        'Al cerrar sesión se borran del teléfono los tokens, la copia local '
            'de tu usuario y la vinculación del QR sin conexión. En iOS, '
            'estos datos se guardan en el llavero del dispositivo sin '
            'sincronización con iCloud ni migración a otro teléfono.',
        'Cerrar sesión o desinstalar la app no elimina tu cuenta ni el '
            'historial conservado por el servicio. Para iniciar la '
            'eliminación de la cuenta y sus datos, entra a «Cuenta y ayuda» '
            '→ «Eliminar mi cuenta».',
        'Los registros de acceso, avisos, ubicaciones de emisión de QR, '
            'intentos de autenticación y auditorías vinculados a estudiantes '
            'se depuran al superar los 30 días. La identidad y las '
            'vinculaciones necesarias para mantener tu cuenta se conservan '
            'mientras exista. Las verificaciones de eliminación caducan '
            'en 10 minutos.',
        'Al confirmar la eliminación se borran la cuenta y sus datos '
            'asociados de la base operativa. Los respaldos externos, si se '
            'mantienen, tienen un plazo máximo de 30 días y no deben '
            'reactivar cuentas eliminadas. Consulta el procedimiento en la '
            'política de privacidad en línea. El '
            'borrado de esta cuenta no equivale a solicitar la baja de tu '
            'matrícula ni de tu cuenta académica.',
        'Si existe una restricción institucional de ingreso, se conserva '
            'separada durante un máximo de 30 días, o hasta su vencimiento '
            'anterior. Solo se guarda una referencia del código protegida con '
            'una clave del servidor y su fecha de vencimiento, sin nombre, '
            'correo ni fotografía, para impedir que un nuevo registro '
            'restaure automáticamente el ingreso. Puedes consultar esta '
            'restricción mediante el contacto de privacidad.',
      ],
    ),
    SeccionAviso(
      titulo: 'Tus derechos',
      parrafos: [
        'Conforme a la Ley N.° 29733, Ley de Protección de Datos Personales, '
            'puedes solicitar a la UPT el acceso, la rectificación, la '
            'cancelación o la oposición al tratamiento de tus datos.',
        'Puedes escribir a ca2022074266@virtual.upt.pe y consultar la política publicada y el canal de soporte desde '
            '«Cuenta y ayuda», disponible antes y después de iniciar sesión. '
            'También puedes acudir a la oficina de soporte de la universidad.',
      ],
    ),
  ],
);
