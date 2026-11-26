# Portal de privacidad de Identidad UPT Estudiante

Un sitio con diseño compartido y rutas `/privacidad`, `/soporte` y
`/eliminar-cuenta`. No usa JavaScript, analítica ni publicidad en el navegador.
Responsable publicado: **Carlos Daniel Ayala Ramos**.
Contacto: **ca2022074266@virtual.upt.pe**. Conservación de registros: **30 días**.

## Dokploy: crear otra Application

| Campo | Valor |
| --- | --- |
| Repository | El mismo repositorio del proyecto |
| Branch | La rama que despliegas, por ejemplo `main` |
| Build Path | `/portal-privacidad-upt` |
| Build Type | `Dockerfile` |
| Docker File | `Dockerfile` |
| Docker Context | El directorio de build, si aparece ese campo |
| Trigger Type | `On Push` |
| Watch Paths | `portal-privacidad-upt/**`, o vacío |
| Puerto del dominio | `3000` |

Asigna **un dominio** al portal y activa HTTPS. Todas las páginas compartirán ese
dominio; no necesitan aplicaciones separadas ni una base de datos propia.
En **Environment**, completa el ejemplo siguiente; `.env.example` sirve de guía:

```dotenv
NODE_ENV=production
PORT=3000
SITIO_PUBLICO_URL=https://TU_DOMINIO_DEL_PORTAL
API_BASE_URL=https://TU_DOMINIO_API/api
RESPONSABLE_NOMBRE=Carlos Daniel Ayala Ramos
SOPORTE_CORREO=ca2022074266@virtual.upt.pe
ALOJAMIENTO_DESCRIPCION=Infraestructura administrada por el responsable del servicio mediante Dokploy.
```

`SITIO_PUBLICO_URL` es solo el origen, sin rutas. Se requiere HTTPS público en
producción. `API_BASE_URL` puede usar HTTP únicamente para una dirección privada
de la API en una red Docker compartida; para direcciones públicas utiliza HTTPS.
El portal no recibe credenciales SQL ni el secreto de Google. Las llamadas a la
API salen del servidor: no hay que ampliar CORS.

Las páginas devuelven `Cache-Control: no-store, no-transform` para evitar que
Cloudflare convierta el correo de soporte en un enlace que dependa de un script
bloqueado por la política CSP. Después de desplegar, verificar que el correo y
los enlaces `mailto:` se vean sin JavaScript.
[Comportamiento documentado por Cloudflare](https://developers.cloudflare.com/waf/tools/scrape-shield/email-address-obfuscation/).

Se ejecuta como usuario `node`, sin volúmenes, y tiene healthcheck `GET /salud`.
Sin las dos URL configuradas no arranca en producción para evitar enlaces
incorrectos. [Configuración Dockerfile de Dokploy](https://docs.dokploy.com/docs/core/applications/build-type).

## Actualizar la API y Google

Conserva el Build Path `/api-backend-entrada-upt`, Dockerfile y variables actuales.
Añade en **Environment de la API**:

```dotenv
SITIO_PUBLICO_URL=https://TU_DOMINIO_DEL_PORTAL
GOOGLE_ELIMINACION_REDIRECT_URI=https://TU_DOMINIO_API/api/cuenta/eliminacion/google/callback
CLAVE_RESTRICCIONES_IDENTIDAD=PEGA_AQUI_LA_CLAVE_GENERADA
```

En el cliente OAuth web de Google Cloud registra **otra URI de redirección
autorizada**, exactamente el valor de `GOOGLE_ELIMINACION_REDIRECT_URI`. Se usan
las credenciales OAuth existentes; **no sustituyas el callback del login**.

Genera una clave independiente de 32 bytes para `CLAVE_RESTRICCIONES_IDENTIDAD`:

```bash
node -e "console.log(require('node:crypto').randomBytes(32).toString('base64url'))"
```

Pega el resultado solo en Environment de la API; no en el portal, la app o Git.
Consérvala entre despliegues y réplicas. Protege la referencia de restricciones de
identidades eliminadas. No la cambies mientras existan restricciones vigentes:
una clave distinta impide el registro automático, para evitar eludir esas restricciones.

Si existe un único proxy Traefik confiable y no hay acceso público directo al
puerto de la API, `TRUST_PROXY_HOPS=1` permite distinguir las IP para el límite de
solicitudes. Es opcional y no se habilita por defecto.

Despliega primero la API, luego el portal. La API aplica automáticamente la
migración aditiva `015_eliminacion_cuenta.sql` y la
`016_restricciones_identidad_eliminada.sql`. Estas migraciones no borran cuentas:
cada eliminación requiere Google y confirmación del titular. **La tarea de
conservación sí retira registros de estudiantes de más de 30 días**, al arrancar
y cada 15 minutos. Prueba la actualización en una copia aislada antes de desplegar.

## Flujo de eliminación

1. La persona abre `/eliminar-cuenta` y verifica la cuenta Google institucional
   previamente vinculada en la app. No se crean cuentas nuevas ni sesiones de la app.
2. Se guarda un verificador aleatorio en una cookie HttpOnly/Secure/SameSite=Lax
   de 10 minutos. La API conserva su hash y la transacción OAuth en SQL, de modo
   que el flujo no depende de una sola réplica.
3. Google regresa a la API; se verifican firma, audiencia, caducidad, dominio,
   nonce, state y PKCE. El `sub` identifica la cuenta ya vinculada.
4. El portal muestra la cuenta, exige marcar la confirmación y escribir `ELIMINAR`.
5. La API borra en una transacción cuenta, perfil, sesiones, dispositivos y
   secretos, QR, historial, avisos, bloqueos y auditorías asociadas. Un fallo
   revierte todo; repetir la confirmación no vuelve a ejecutar el borrado.
6. Se muestra un comprobante breve sin identidad. Cerrar sesión en la app retira
   las copias locales del teléfono. La matrícula, intranet y Google no se eliminan.

Por decisión del responsable, si el ingreso estaba restringido se mantiene
solo una huella HMAC del código institucional y su caducidad, durante un máximo
de 30 días o hasta un vencimiento anterior. No contiene datos legibles de
identidad, pero se considera seudonimizada y se informa en la política. Un nuevo
registro automático no crea una cuenta ni restaura el ingreso durante ese plazo;
las cuentas normales no generan esa restricción. La institución conserva sus
procedimientos administrativos para resolver autorizaciones.

No se reciben IDs de usuario elegidos por el navegador ni se ponen contraseñas,
tokens o verificadores en las URLs. Los formularios exigen el origen correcto.
Solo hay una cookie esencial; no se conservan tokens del proveedor.
El flujo sirve a cuentas **exclusivas de estudiante**. No destruye identidades
compartidas con roles de seguridad/administración; el responsable debe separar
esas funciones antes de ofrecerlas como cuentas de esta app a App Review.
[Eliminación de cuenta de Apple](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion).

## Respaldos y operación

La API depura su base operativa. No puede configurar respaldos, binlogs ni logs
externos de Dokploy o del proveedor sin acceso a esos servicios. Configura allí
la **retención máxima de 30 días**, acceso restringido y registro sin cuerpos,
cookies o parámetros OAuth antes de publicar la política.

No restaures un respaldo antiguo directamente a producción: usa un entorno
aislado, aplica las eliminaciones posteriores registradas por el responsable,
ejecuta la depuración y verifica que no reaparezcan cuentas borradas. El código
no conserva una copia de identidades eliminadas para gestionar esos respaldos.

Actualiza `ALOJAMIENTO_DESCRIPCION` con el proveedor o país si corresponde y
confirma la autorización institucional para usar sus credenciales y marca.
El portal identifica al responsable indicado; no acredita representación de la UPT.

## Pruebas y enlaces finales

```bash
npm run dev
npm test
npm run check
docker build -t portal-privacidad-upt .
```

El modo local sin variables apunta a `127.0.0.1:3199` como API de pruebas.
Las páginas públicas funcionan sin API; la eliminación necesita la API y Google
configurados. Para cargar un `.env` local: `node --env-file=.env src/server.js`.
No se incluye simulación de borrado en producción.

Después del despliegue, abre directamente las tres rutas por HTTPS, prueba
Google y la eliminación con una cuenta ficticia, verifica cancelación/expiración
y comprueba que sus tokens y QR ya no funcionen. Las páginas públicas deben
seguir disponibles aunque la API esté caída.

Cuando exista el dominio final, los valores de la app serán:

```text
URL_PRIVACIDAD_UPT=https://TU_DOMINIO_DEL_PORTAL/privacidad
URL_SOPORTE_UPT=https://TU_DOMINIO_DEL_PORTAL/soporte
URL_ELIMINAR_CUENTA_UPT=https://TU_DOMINIO_DEL_PORTAL/eliminar-cuenta
```

Se mantienen en blanco en la configuración de la app hasta recibir esos enlaces.
Más detalles de API: [eliminación y privacidad](../api-backend-entrada-upt/docs/eliminacion_cuenta_privacidad.md).
