# Publicación de la aplicación de estudiante en App Store

Requisitos revisados el 26/11/2026. La aplicación de estudiante, la API y el
portal público están preparados en el repositorio. **Todavía no enviar a revisión**:
falta desplegar el portal y la API, configurar dominios y callback Google,
verificar el servicio real, completar firma y probar en dispositivos Apple.

## Pendientes externos

| Pendiente | Resultado necesario |
| --- | --- |
| Privacidad | Desplegar `/privacidad` y verificar responsable, proveedores y tratamiento publicado; [texto y configuración](PRIVACIDAD_PARA_PUBLICAR.md). |
| Soporte | Desplegar `/soporte`, con el correo público indicado por el responsable. |
| Eliminación | Desplegar `/eliminar-cuenta` y configurar el nuevo callback Google. Probar una cuenta ficticia de principio a fin. |
| Servidor | Validar proveedores, retención y autorización institucional del dominio API actual, procedente del proyecto. |
| Apple Developer | Equipo autorizado, registro de la app, certificados y perfiles de firma. |
| Revisión | Cuenta de prueba accesible desde un dispositivo nuevo y posibilidad de revisar el QR fuera de Tacna. |

Las tres URL legales se dejaron **vacías por indicación del usuario**. La app
avisa al intentar abrirlas. Esto permite continuar el desarrollo, pero no satisface
los requisitos de publicación. El responsable indicó nombre y correo públicos y
un plazo de 30 días, incorporados en el portal y en el aviso de la app.

El cliente abre `/eliminar-cuenta` en el nuevo portal. La API ya implementa
verificación Google específica, confirmación y borrado transaccional real de
cuentas exclusivas de estudiante. No se borran cuentas compartidas con roles de
operador: separar esas funciones antes de ofrecerlas como cuentas de esta app.
Consulta [el despliegue del portal](../../../portal-privacidad-upt/README.md) y
[el contrato de la API](../../../api-backend-entrada-upt/docs/eliminacion_cuenta_privacidad.md).
Apple permite una página específica y exige eliminación también para cuentas
creadas automáticamente. Cerrar sesión o enviar un correo no sustituyen el borrado. [Eliminación de cuenta de Apple](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion).

## Configuración implementada

- iOS 13 mínimo; el SDK de compilación exigido es un requisito diferente.
- CocoaPods en Debug/Profile/Release, entitlements del llavero privado y
  `PrivacyInfo.xcprivacy` incluido en los recursos de Runner.
- Permiso de ubicación When In Use, explicación previa, AppleSettings sin
  actualizaciones de fondo y suspensión de renovaciones al ocultar la app. Una
  lectura pendiente no envía coordenadas si ya pasó a segundo plano.
- Tokens y secreto de QR accesibles con el teléfono desbloqueado, sin
  sincronización iCloud ni migración. Cerrar sesión borra tokens, usuario y QR
  locales; conserva la preferencia de bloqueo biométrico.
- Google abre Safari dentro de la app en iOS; se rechazan URL de autorización
  ajenas a `https://accounts.google.com` y se manejan fallos al abrir el navegador.
- La API en release requiere HTTPS y no sigue redirecciones con credenciales.
- Cuenta y ayuda accesible antes y después del login; controles en español de
  Perú, texto escalable y gestión de permisos. Sin permisos de cámara, micrófono,
  publicidad, push ni ubicación Always.

Bundle ID propuesto: `pe.edu.upt.identidad.estudiante`. **Confirmar autorización,
disponibilidad y registro** antes del primer envío. Si se cambia, actualizar
Runner y RunnerTests en todas las configuraciones. Elegir el equipo en Signing &
Capabilities y verificar el entitlement Keychain de la propia app.

## Compilar en Mac

Desde el 28/04/2026 se requiere Xcode 26 o posterior y SDK iOS 26 o posterior
para cargar apps de iOS. [Requisito oficial](https://developer.apple.com/news/upcoming-requirements/?id=04282026a).

Instalar Flutter compatible, Xcode y CocoaPods. La verificación local de Dart se
realizó en Linux con Flutter 3.38.1 / Dart 3.10.0 y el lockfile se resolvió para
ese SDK. Si se cambia Flutter en el Mac, revisar y regenerar el lockfile, repetir
pruebas y comprobar compatibilidad con el Xcode elegido. No se compiló ni firmó
un binario iOS en Linux.

```bash
cp config/app_store.example.json config/app_store.json
# Completar las tres URL legales y confirmar URL_API_UPT.
python3 scripts/verificar_app_store.py --config config/app_store.json
bash scripts/compilar_app_store.sh config/app_store.json
```

El JSON local se excluye de Git. Sus valores se incorporan al binario:
**no incluir secretos ni credenciales**. El script ejecuta análisis, pruebas,
compilación release y comprobación básica del archivo. No carga ni publica.
Admite argumentos de `flutter build ipa` después del JSON, por ejemplo
`--export-options-plist` para una configuración de firma propia.

Desde Linux se comprueba el código fuente, sin habilitar publicación:

```bash
python3 scripts/verificar_app_store.py --source-only
```

En Organizer ejecutar **Validate App** y generar el informe de privacidad del
archivo final. Comprobar los manifiestos de Flutter, flutter_secure_storage_darwin,
geolocator_apple, local_auth_darwin y url_launcher_ios. Sus versiones resueltas
incluyen manifiestos; verificar que lleguen al binario. No copiar motivos de
API a Runner sin comprobar que los use directamente.
[Manifiestos de privacidad](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files).

## App Store Connect

1. Registrar nombre, Bundle ID, descripción, categoría, territorios, derechos de
   contenido y contacto institucional. Completar URLs de privacidad y soporte.
2. Declarar privacidad según el inventario siguiente, el backend efectivo y el
   informe del archivo final. El manifiesto no completa este formulario por sí solo.
3. Responder el cuestionario vigente de edad con las funciones reales. No marcar
   categoría infantil solo por tratarse de una app educativa.
4. Preparar capturas reales de iPhone **e iPad**, ya que se admiten ambas familias,
   sin datos de estudiantes reales. Declarar accesibilidad solo tras verificarla.
5. Responder exportación de cifrado: usa HTTPS, Keychain y HMAC-SHA1 para OTP.
   No se estableció `ITSAppUsesNonExemptEncryption = false` sin completar el
   cuestionario aplicable. Conservar documentación o clave si Apple la requiere.
   [Exportación de cifrado](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance).
6. Completar [notas para App Review](NOTAS_APP_REVIEW.md), credenciales de prueba
   y recursos para revisar el QR fuera del campus. La geocerca actual puede
   impedir revisar esa función. Resolverlo con la institución; el modo debug
   de ubicación simulada no funciona en release y no es una solución de revisión.
7. Evaluar distribución pública o no listada según el público institucional.
   Apple contempla estudiantes universitarios entre los públicos de distribución
   no listada; sigue requiriendo revisión.
   [Distribución no listada](https://developer.apple.com/support/unlisted-app-distribution/).
8. Validar el archivo, cargarlo, probar TestFlight y enviar a revisión. Incrementar
   versión/build de `pubspec.yaml` en las nuevas cargas.

## Inventario de privacidad para confirmar

El manifiesto declara estos datos vinculados a la identidad, para **funcionalidad
de la app**, sin tracking. Adopta una declaración conservadora del servicio de
identidad. Confirmar la recopilación efectiva: mostrar un dato ya existente no
determina por sí solo si se recopila nuevamente desde la app. Ajustar tanto el
manifiesto como App Store Connect cuando se confirme el tratamiento.

| Categoría de Apple | Datos del sistema |
| --- | --- |
| Nombre | Identidad institucional validada. |
| Correo | Correo institucional verificado por Google. |
| ID de usuario | ID del servicio y código institucional. |
| ID de dispositivo | Identificador aleatorio vinculado al QR offline, no IDFA. |
| Ubicación precisa | Coordenadas, precisión y hora del QR en línea. |
| Fotos o vídeos | Fotografía institucional obtenida durante la verificación. |
| Otros datos | Rol, escuela, autorizaciones, ingresos, rechazos y avisos. |

No hay anuncios, compras, analítica ni tracking. Face ID/Touch ID no entregan
plantillas o imágenes a la app. Validar registros técnicos y proveedores del
servidor antes de finalizar las declaraciones; esta revisión del cliente no
certifica el backend. [Privacidad en App Store Connect](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/).

## Aceptación en dispositivos Apple

- Instalación y actualización: intranet, Google desde un dispositivo nuevo,
  cancelación, fallo de red, expiración, renovación y cierre de sesión.
- Enlaces antes y después de iniciar sesión, incluso si falla la carga del perfil.
- Eliminación real de una cuenta de prueba: confirmar borrado del servicio y
  datos asociados, revocación de sesiones/dispositivos y aviso al titular.
- Ubicación denegada, una sola vez, retirada y precisión reducida: el perfil,
  historial y avisos siguen disponibles; comprobar el mensaje si no basta la
  precisión del QR y las alternativas institucionales de ingreso.
- QR en línea: salir y regresar sin renovaciones de GPS en fondo. Volver a
  generar por acción del usuario. QR offline previamente vinculado sin GPS/red.
- Face ID/Touch ID ausentes, rechazo, bloqueo, código del teléfono y salida al
  login. iOS puede conservar Keychain tras desinstalar; cerrar sesión borra los
  datos de autenticación de esta app.
- iPhone pequeño, iPad, rotación, teclado, texto grande y VoiceOver; lectura real
  del QR por el sistema de acceso. El CAPTCHA actual requiere visión; evaluar
  con la institución una alternativa accesible del servicio antes de declarar
  compatibilidad completa con VoiceOver.
- Red IPv6/NAT64, Wi-Fi/datos, TLS, caída de servicio y ausencia de datos sensibles
  en logs. No desactivar ATS para resolver problemas de conexión.

App Review evalúa el servicio operativo, el binario firmado y los metadatos.
Estas comprobaciones no garantizan aprobación.
[Directrices de revisión](https://developer.apple.com/app-store/review/guidelines/).
