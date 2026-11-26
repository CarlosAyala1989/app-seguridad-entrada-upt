# Plantilla para App Review

Completar antes de copiar en App Store Connect. No guardar contraseñas en Git.

Identidad UPT Estudiante permite consultar la identidad institucional, presentar
un QR temporal de ingreso, consultar historial y recibir avisos de acceso al
campus de la Universidad Privada de Tacna. No hay compras, anuncios, contenido
público generado por usuarios ni tracking publicitario.

Requiere credenciales académicas preexistentes y Google Workspace institucional
@virtual.upt.pe. Primero verifica la intranet y después el correo. Registra la
identidad digital del servicio, sin crear una cuenta académica de Google.

La excepción para cuentas educativas existentes de la directriz 4.8 fundamenta
mantener la autenticación institucional sin añadir otro proveedor. Confirmar
que corresponde al servicio ofrecido antes de enviar las notas.
[Directriz 4.8](https://developer.apple.com/app-store/review/guidelines/#login-services).

## Acceso del revisor

- Código y contraseña de intranet: [COMPLETAR SOLO EN APP STORE CONNECT].
- Cuenta Google institucional y pasos para autorizar desde un dispositivo nuevo:
  [COMPLETAR SOLO EN APP STORE CONNECT].
- Contacto disponible durante la revisión: [COMPLETAR].
- Pasos para probar generación y validación del QR fuera del campus: [COMPLETAR].
- QR de ejemplo y recursos del lector/punto de control, si se necesitan:
  [ADJUNTAR SIN DATOS PERSONALES REALES].

No hay bypass de credenciales ni geocerca en release. Toda configuración de
pruebas del servicio debe ser explícita, segura y explicada al revisor. Resolver
con la institución la revisión desde fuera del campus antes del envío.

## Permisos y eliminación

La ubicación se solicita para generar y renovar el QR en línea con su pantalla
abierta y la app en primer plano. Negarla permite consultar identidad, historial
y avisos. Un QR offline previamente preparado se calcula sin GPS.

El bloqueo biométrico es opcional y usa LocalAuthentication. La app solo recibe
el resultado del sistema; permite código del teléfono y cerrar sesión para volver
a autenticarse con las credenciales institucionales.

El aviso y la política están disponibles antes y después de iniciar sesión.
Cuenta y ayuda → Eliminar mi cuenta abre la página específica de eliminación:
[COMPLETAR URL Y VERIFICAR EL PROCESO REAL].

La eliminación de cuentas exclusivas de estudiante requiere verificar el Google
Workspace ya vinculado y confirmar expresamente el borrado. Se aplica a la base
operativa en ese momento y muestra un comprobante; los registros temporales y
respaldos tienen un plazo máximo de 30 días. Responsable: Carlos Daniel Ayala
Ramos, ca2022074266@virtual.upt.pe. Verificar en el despliegue final la política
de respaldos. Cerrar sesión no sustituye la eliminación de la cuenta.

La política también informa que una restricción institucional de ingreso se
conserva por separado, con referencia HMAC sin datos legibles de identidad, por
máximo 30 días. Esto no impide eliminar la cuenta; impide que un registro
automático posterior restablezca el ingreso durante la restricción.
