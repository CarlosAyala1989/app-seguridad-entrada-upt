# Sistema de Identidad Digital y Control de Acceso para la Universidad Privada de Tacna

## 1. Descripción general

El proyecto consiste en desarrollar un sistema de identidad digital universitaria y control de acceso para la Universidad Privada de Tacna (UPT).

La finalidad es reemplazar o complementar el proceso tradicional de ingreso, donde el personal de seguridad valida visualmente un carnet o documento, por un sistema digital que pueda comprobar en tiempo real que:

- La persona posee una cuenta institucional válida de la UPT.
- La cuenta pertenece a la organización institucional autorizada.
- El estudiante puede autenticarse correctamente en la intranet.
- El nombre obtenido de la cuenta institucional coincide con el nombre obtenido desde la intranet.
- El usuario se encuentra activo en el sistema.
- La credencial presentada fue generada recientemente.
- La credencial no ha expirado.
- La credencial no fue utilizada anteriormente.
- La credencial fue generada desde una ubicación válida.
- La persona que escanea tiene permisos para validar accesos.

El sistema utilizará una aplicación Flutter, un backend Node.js y una base de datos MySQL.

La arquitectura principal será:

```text
Flutter
   |
   | HTTPS
   v
Node.js
   |
   v
MySQL
```

La aplicación Flutter nunca se conectará directamente a MySQL.

Toda operación importante deberá pasar por el backend.

---

# 2. Tecnologías principales

## Aplicación móvil

Flutter.

Será utilizada para:

- Inicio de sesión.
- Identidad digital.
- Perfil del usuario.
- Obtención de ubicación.
- Solicitud del QR.
- Visualización del QR.
- Escaneo de QR para personal de seguridad.
- Visualización del resultado de acceso.
- Historial básico.
- Administración, si posteriormente se utiliza Flutter Web.

## Backend

Node.js.

Será responsable de:

- Autenticación.
- Validación de la cuenta institucional.
- Validación de la intranet.
- Gestión de sesiones.
- Gestión de usuarios.
- Gestión de roles.
- Generación de OTP.
- Generación de credenciales temporales.
- Cifrado o generación de tokens opacos.
- Validación de QR.
- Validación de ubicación.
- Control de reutilización.
- Registro de accesos.
- Auditoría.
- Comunicación con MySQL.

## Base de datos

MySQL.

Será responsable de almacenar información persistente como:

- Usuarios.
- Roles.
- Sesiones.
- Dispositivos.
- Credenciales temporales.
- Puntos de acceso.
- Registros de acceso.
- Configuración.
- Auditoría.

---

# 3. Actores del sistema

## 3.1 Estudiante

Podrá:

- Iniciar sesión con su cuenta institucional.
- Validar adicionalmente su identidad mediante la intranet.
- Consultar su perfil.
- Generar un QR temporal.
- Visualizar el estado de su credencial.
- Consultar, si se desea, su historial de accesos.

## 3.2 Docente

Tendrá un funcionamiento similar al estudiante, si posteriormente se habilita este tipo de usuario.

## 3.3 Trabajador

Tendrá un funcionamiento similar, con reglas de acceso diferentes si fueran necesarias.

## 3.4 Personal de seguridad

Podrá:

- Iniciar sesión.
- Acceder al escáner.
- Escanear credenciales.
- Consultar el resultado de la validación.
- Visualizar fotografía e información mínima necesaria del usuario.
- Registrar el ingreso.

## 3.5 Administrador

Podrá:

- Gestionar usuarios.
- Gestionar roles.
- Bloquear o habilitar usuarios.
- Gestionar puntos de acceso.
- Consultar accesos.
- Consultar intentos rechazados.
- Consultar auditoría.
- Modificar configuraciones permitidas.

---

# 4. Arquitectura general del sistema

```text
                    +--------------------------+
                    | Cuenta institucional UPT |
                    |     @virtual.upt.pe       |
                    +------------+-------------+
                                 |
                                 | autenticación institucional
                                 v
+-------------+            +-----+------+
|   Flutter   |----------->|  Node.js   |
| Estudiante  |   HTTPS    |  Backend   |
+------+------+            +-----+------+
       |                         |
       | GPS                     | validación adicional
       v                         v
+-------------+           +------+----------------+
| Ubicación   |           | Intranet UPT          |
| dispositivo |           | validación temporal   |
+-------------+           +------+----------------+
                                 |
                                 |
                                 v
                          +------+------+
                          |    MySQL    |
                          +-------------+
```

Para el personal de seguridad:

```text
+---------------------+
| Flutter Seguridad   |
| Escáner QR          |
+----------+----------+
           |
           | HTTPS
           v
+----------+----------+
| Node.js Backend     |
| Validación completa |
+----------+----------+
           |
           v
+----------+----------+
| MySQL               |
| Credenciales        |
| Accesos             |
| Usuarios            |
+---------------------+
```

---

# 5. Principio fundamental de identidad

El sistema no considerará que una persona pertenece a la UPT solamente porque escriba un correo terminado en `@virtual.upt.pe`.

La verificación deberá realizarse realmente contra la cuenta institucional.

Por ejemplo, no sería suficiente recibir:

```text
2022074266@virtual.upt.pe
```

y asumir que esa persona es estudiante.

Se necesita demostrar que el usuario realmente puede autenticarse con esa cuenta institucional.

Después se realizará una segunda comprobación utilizando la intranet.

Por lo tanto, el sistema tendrá dos niveles de verificación:

```text
NIVEL 1
Cuenta institucional @virtual.upt.pe

NIVEL 2
Intranet UPT
```

El usuario solamente será considerado verificado cuando ambos niveles sean correctos.

---

# 6. Verificación de la cuenta institucional

## 6.1 Primer paso de identidad

El estudiante iniciará sesión utilizando su cuenta institucional.

La cuenta deberá pertenecer obligatoriamente a la organización:

```text
virtual.upt.pe
```

Por ejemplo:

```text
codigo@virtual.upt.pe
```

El sistema no deberá confiar únicamente en que el texto del correo termine con ese dominio.

La opción correcta es utilizar el mecanismo de autenticación del proveedor institucional, por ejemplo OAuth, SSO o el mecanismo que utilice la UPT.

El flujo será:

```text
Usuario
   |
   v
Flutter
   |
   | iniciar sesión institucional
   v
Proveedor de identidad
   |
   | autenticación válida
   v
Flutter / Backend
   |
   v
Node.js
```

Node.js deberá comprobar:

- Que la autenticación fue realmente exitosa.
- Que la cuenta fue emitida por el proveedor institucional.
- Que pertenece a la organización autorizada.
- Que el dominio corresponde a `virtual.upt.pe`.
- Que el correo se encuentra verificado.
- Que la sesión institucional no fue falsificada.

Si el proveedor devuelve información del dominio u organización mediante un claim o atributo firmado, se debe validar ese dato.

No se deberá confiar únicamente en hacer algo parecido a:

```text
correo.endsWith("@virtual.upt.pe")
```

porque eso solo valida texto, no identidad.

---

# 7. Segundo paso: validación mediante intranet UPT

Después de verificar correctamente la cuenta institucional, el usuario deberá realizar una segunda validación.

Se solicitará:

- Código universitario.
- Contraseña de intranet.
- CAPTCHA, cuando la intranet lo requiera.

La contraseña se utilizará únicamente durante esa operación.

No se almacenará.

No se guardará en MySQL.

No se guardará en logs.

No se guardará en archivos.

No se guardará como parte de la sesión.

No se guardará en Flutter después de completar la validación.

No se guardará en Node.js una vez terminada la solicitud.

El objetivo no será consultar notas ni información académica innecesaria.

El objetivo será obtener únicamente información suficiente para comprobar:

1. Que las credenciales no son inválidas.
2. Que la sesión de intranet se creó correctamente.
3. Que la intranet reconoce al usuario.
4. Que se puede obtener el nombre del estudiante.
5. Que el nombre coincide con el nombre de la cuenta institucional.

---

# 8. Flujo completo de verificación del estudiante

El flujo será el siguiente:

```text
PASO 1

Usuario abre Flutter.

        |
        v

Inicia sesión con cuenta institucional.

        |
        v

Proveedor institucional autentica.

        |
        v

Node.js recibe identidad verificada.

        |
        v

Node.js comprueba organización virtual.upt.pe.

        |
        v

Cuenta institucional válida.
```

Después:

```text
PASO 2

Flutter solicita validación de intranet.

        |
        v

Usuario ingresa:
- código
- contraseña
- captcha, si corresponde

        |
        v

Información enviada mediante HTTPS.

        |
        v

Node.js abre una sesión temporal contra la intranet.

        |
        v

Intranet responde.
```

Si la intranet devuelve credenciales inválidas:

```text
VERIFICACIÓN RECHAZADA
```

Si permite iniciar sesión:

```text
Node.js obtiene el nombre mostrado por la intranet.

        |
        v

Node.js compara:

Nombre cuenta institucional

VS

Nombre intranet.
```

Si los nombres corresponden:

```text
IDENTIDAD VERIFICADA
```

Si los nombres no corresponden:

```text
IDENTIDAD NO VERIFICADA
```

---

# 9. Comparación del nombre

No se recomienda comparar los nombres como cadenas exactas sin normalización.

Por ejemplo, una fuente podría devolver:

```text
CARLOS ALBERTO AYALA RAMOS
```

y otra:

```text
Carlos Alberto Ayala Ramos
```

Ambos deberían considerarse iguales.

Antes de comparar se deberá normalizar:

- Mayúsculas y minúsculas.
- Espacios adicionales.
- Caracteres especiales cuando corresponda.
- Formato de nombres.
- Orden conocido de nombres y apellidos, si ambas fuentes utilizan formatos diferentes.

La comparación debe ser suficientemente estricta para evitar que dos personas diferentes sean consideradas la misma.

No se deberá utilizar únicamente una coincidencia parcial débil.

---

# 10. Qué información se guardará después de verificar la intranet

Se podrá guardar el resultado de la verificación, por ejemplo:

```text
identity_verified = true
identity_verified_at = fecha
institutional_email = ...
institutional_code = ...
institutional_name = ...
intranet_name = ...
verification_method = institutional_account + intranet
```

No se guardará:

```text
intranet_password
captcha
cookies de intranet
session temporal de intranet
```

Las cookies y la sesión creada para validar la intranet deberán destruirse cuando termine la operación.

---

# 11. Integración con la intranet

La integración deberá estar aislada dentro del backend.

Conceptualmente:

```text
Node.js
   |
   v
InstitutionalIdentityService
   |
   +---- Cuenta institucional
   |
   +---- IntranetVerificationService
```

Esto permitirá que la aplicación Flutter no conozca cómo funciona internamente la intranet.

Flutter únicamente enviará la información necesaria al backend mediante HTTPS.

El backend será responsable de realizar la validación.

---

# 12. Adaptador de intranet

Se recomienda crear conceptualmente un módulo independiente:

```text
IntranetVerificationService
```

Su responsabilidad será únicamente:

- Crear una sesión temporal con la intranet.
- Enviar las credenciales.
- Resolver o permitir resolver el CAPTCHA.
- Detectar si las credenciales son inválidas.
- Detectar si el login fue exitoso.
- Obtener el nombre del usuario autenticado.
- Devolver un resultado limpio al resto del backend.
- Cerrar inmediatamente la sesión.

Ejemplo conceptual de respuesta interna:

```text
{
    authenticated: true,
    studentCode: "...",
    studentName: "..."
}
```

Nunca deberá devolver:

```text
password
cookies
captcha
```

---

# 13. Relación con el prototipo actual de intranet

Actualmente existe un prototipo que utiliza automatización de navegador para:

- Abrir la intranet UPT.
- Mostrar el CAPTCHA.
- Introducir código.
- Introducir contraseña mediante el teclado virtual.
- Introducir CAPTCHA.
- Iniciar sesión.
- Navegar dentro de la sesión autenticada.

Ese prototipo demuestra que técnicamente es posible comprobar si las credenciales permiten iniciar sesión.

Sin embargo, para este proyecto no se necesita descargar notas.

El módulo nuevo deberá limitarse a:

```text
LOGIN
   |
   v
¿Credenciales válidas?
   |
   v
Obtener nombre
   |
   v
Cerrar sesión
```

El prototipo actual no realiza todavía la comparación del nombre de la cuenta institucional con el nombre de intranet.

Esa comparación formará parte del nuevo diseño.

---

# 14. Consideración importante sobre la integración con intranet

La automatización mediante navegador o scraping debe considerarse una solución de integración mientras no exista una API oficial.

La arquitectura debe permitir reemplazar posteriormente ese método por:

- API oficial.
- SSO.
- OAuth.
- LDAP.
- Servicio institucional.
- Endpoint proporcionado por la UPT.

Por eso Flutter nunca deberá depender directamente del scraping.

La dependencia debe estar solamente dentro del backend.

---

# 15. Estado de verificación de identidad

El usuario podrá tener diferentes estados.

Por ejemplo:

```text
PENDING
INSTITUTIONAL_ACCOUNT_VERIFIED
INTRANET_VERIFIED
VERIFIED
REJECTED
BLOCKED
```

Un usuario solamente podrá generar credenciales de acceso si se encuentra en:

```text
VERIFIED
```

---

# 16. Sesiones de la aplicación

Después de verificar al usuario, el backend creará una sesión propia.

La sesión de nuestra aplicación será independiente de la sesión temporal de la intranet.

Conceptualmente:

```text
Cuenta institucional
        +
Validación intranet
        |
        v
Identidad verificada
        |
        v
Sesión propia del sistema
```

La sesión podrá utilizar:

- Access token.
- Refresh token.
- Identificador de sesión.
- Expiración.
- Dispositivo asociado.

Flutter almacenará los tokens utilizando almacenamiento seguro.

---

# 17. Perfil digital

Después de iniciar sesión, Flutter solicitará el perfil al backend.

```text
Flutter
   |
   | GET perfil
   v
Node.js
   |
   v
MySQL
```

El perfil puede mostrar:

- Fotografía.
- Nombre completo.
- Código universitario.
- Correo institucional.
- Escuela profesional.
- Tipo de usuario.
- Estado de verificación.
- Estado de acceso.

---

# 18. Generación del QR

El usuario deberá solicitar explícitamente una credencial.

Flujo:

```text
Flutter
   |
   | solicita ubicación
   v
GPS
   |
   v
Flutter
   |
   | sesión + coordenadas
   v
Node.js
```

Node.js comprobará:

- Sesión válida.
- Usuario existente.
- Identidad verificada.
- Usuario activo.
- Permiso de acceso.
- Ubicación permitida.
- Dispositivo permitido, si se aplica.
- Reglas de seguridad.

Después generará:

- OTP.
- Nonce.
- Fecha de emisión.
- Fecha de expiración.
- Credencial temporal.
- Identificador interno.

---

# 19. Qué contendrá el QR

El QR no deberá contener datos personales legibles.

No deberá existir algo como:

```text
Nombre: Carlos Ayala
Código: 2022074266
Correo: ...
Ubicación: ...
```

El QR deberá contener una credencial temporal opaca o cifrada.

Conceptualmente:

```text
QR
   |
   v
TOKEN TEMPORAL NO LEGIBLE
```

Los datos reales permanecerán en el backend y en MySQL.

---

# 20. OTP

Cada credencial tendrá un valor de un solo uso.

El OTP no necesita ser mostrado al usuario.

Será utilizado internamente por el backend.

Cada QR deberá tener su propio OTP.

Ejemplo:

```text
QR 1 -> OTP A
QR 2 -> OTP B
QR 3 -> OTP C
```

Nunca deberán reutilizarse.

---

# 21. Nonce

Además del OTP se generará un nonce aleatorio.

Su objetivo será garantizar que dos credenciales generadas incluso muy cerca en el tiempo sean diferentes.

El nonce deberá ser criptográficamente aleatorio.

---

# 22. Expiración del QR

La credencial será temporal.

Un valor razonable para el MVP puede ser aproximadamente:

```text
30 a 60 segundos
```

La duración real deberá configurarse en el backend.

No deberá quedar fija dentro de Flutter.

---

# 23. Ubicación

Flutter obtendrá:

- Latitud.
- Longitud.
- Precisión.
- Momento de obtención.

La ubicación será enviada al backend.

Node.js decidirá si el usuario está dentro de una zona autorizada.

---

# 24. Puntos de acceso

MySQL almacenará puntos de acceso.

Ejemplo:

```text
Puerta principal
Puerta secundaria
Acceso vehicular
```

Cada punto podrá contener:

```text
id
nombre
latitud
longitud
radio_permitido
estado
```

---

# 25. Geofencing

Node.js calculará la distancia entre el usuario y uno o más puntos permitidos.

Ejemplo:

```text
Radio permitido: 150 metros.
Distancia usuario: 70 metros.

Resultado:
PERMITIDO
```

Otro ejemplo:

```text
Radio permitido: 150 metros.
Distancia usuario: 8 kilómetros.

Resultado:
NO PERMITIDO
```

---

# 26. Flujo completo de generación de credencial

```text
1. Usuario abre Flutter.

2. Flutter comprueba sesión.

3. Usuario solicita QR.

4. Flutter solicita GPS.

5. Flutter obtiene coordenadas.

6. Flutter envía solicitud a Node.js.

7. Node.js valida sesión.

8. Node.js valida usuario.

9. Node.js comprueba identity_verified.

10. Node.js valida estado.

11. Node.js valida ubicación.

12. Node.js genera OTP.

13. Node.js genera nonce.

14. Node.js establece issued_at.

15. Node.js establece expires_at.

16. Node.js genera credencial protegida.

17. Node.js registra credencial en MySQL.

18. Node.js devuelve token a Flutter.

19. Flutter genera representación QR.

20. Flutter muestra cuenta regresiva.
```

---

# 27. Personal de seguridad

El personal de seguridad tendrá un rol especial:

```text
SECURITY
```

Solamente ese rol podrá utilizar el endpoint de validación de QR.

Aunque alguien modificara Flutter para mostrar la pantalla del escáner, el backend seguirá rechazando la operación si su rol no posee el permiso correspondiente.

---

# 28. Escaneo del QR

```text
QR
 |
 v
Cámara
 |
 v
Flutter Seguridad
 |
 | token
 v
Node.js
```

El backend será quien determine si el acceso es válido.

---

# 29. Validaciones realizadas al escanear

Node.js deberá comprobar:

- Token auténtico.
- Credencial existente.
- Credencial no manipulada.
- Credencial no expirada.
- OTP válido.
- Nonce válido.
- Credencial no utilizada.
- Usuario existente.
- Usuario verificado.
- Usuario activo.
- Sesión válida.
- Punto de acceso activo.
- Guardia autenticado.
- Guardia con rol SECURITY.
- Reglas de ubicación.

---

# 30. Resultado mostrado al guardia

Si el acceso es autorizado se podrá mostrar:

```text
ACCESO AUTORIZADO

Fotografía
Nombre
Código
Tipo de usuario
Escuela
Estado
Hora
```

El guardia deberá comparar físicamente la fotografía con la persona.

Esto agrega una segunda verificación humana al control digital.

---

# 31. QR utilizado

Cuando un QR se utilice correctamente:

```text
PENDING
   |
   v
USED
```

Se registrará:

- Fecha de uso.
- Punto de acceso.
- Usuario de seguridad.
- Resultado.
- Ubicación de escaneo, si se utiliza.

---

# 32. Prevención de reutilización

Si alguien toma una captura del QR y lo intenta reutilizar:

```text
Node.js
   |
   v
status = USED
   |
   v
ACCESO DENEGADO
```

El intento podrá registrarse como:

```text
REPLAY_DETECTED
```

---

# 33. Concurrencia

La validación y utilización deberán realizarse mediante una transacción.

Esto evita que dos escáneres puedan aceptar simultáneamente el mismo QR.

Conceptualmente:

```text
BEGIN TRANSACTION

Comprobar credencial.

Bloquear registro.

Validar estado.

Marcar USED.

Registrar acceso.

COMMIT
```

Solo una solicitud deberá obtener autorización.

---

# 34. Base de datos MySQL

## Tabla users

Podrá contener:

```text
id
institutional_code
institutional_email
institutional_name
intranet_name
first_name
last_name
photo_url
user_type
status
identity_verified
identity_verified_at
created_at
updated_at
```

---

# 35. Tabla roles

Ejemplos:

```text
STUDENT
TEACHER
WORKER
SECURITY
ADMIN
```

---

# 36. Tabla user_roles

Relacionará usuarios con roles.

No se deberá determinar un rol solamente mediante el correo.

---

# 37. Tabla academic_profiles

Podrá contener:

```text
user_id
school
faculty
academic_status
academic_period
```

---

# 38. Tabla devices

Podrá contener:

```text
id
user_id
device_identifier
platform
status
last_seen_at
created_at
```

---

# 39. Tabla sessions

Podrá contener:

```text
id
user_id
device_id
created_at
expires_at
revoked_at
status
```

No almacenará la contraseña de intranet.

---

# 40. Tabla access_points

Podrá contener:

```text
id
name
description
latitude
longitude
allowed_radius
status
```

---

# 41. Tabla access_credentials

Podrá contener:

```text
id
user_id
session_id
device_id
otp_hash
nonce
issued_at
expires_at
latitude
longitude
status
used_at
access_point_id
```

No es necesario guardar el OTP en texto plano.

---

# 42. Tabla access_logs

Podrá contener:

```text
id
user_id
credential_id
access_point_id
security_user_id
result
reason
created_at
latitude
longitude
```

---

# 43. Tabla audit_logs

Registrará acciones administrativas y sensibles.

Ejemplos:

```text
Usuario verificado.
Usuario bloqueado.
Usuario desbloqueado.
Rol modificado.
Punto de acceso creado.
Punto de acceso modificado.
Configuración modificada.
```

---

# 44. Tabla system_settings

Permitirá configurar:

```text
qr_duration_seconds
allowed_location_radius
max_login_attempts
session_duration
identity_reverification_period
```

Así se evita poner configuraciones críticas directamente en Flutter.

---

# 45. Backend Node.js

El backend podrá dividirse conceptualmente en módulos.

```text
Auth
Users
InstitutionalIdentity
IntranetVerification
Sessions
Roles
Devices
Geolocation
AccessCredentials
QRValidation
AccessPoints
AccessLogs
Administration
Audit
Settings
```

---

# 46. Módulo Auth

Responsabilidades:

- Inicio de sesión.
- Logout.
- Renovación de sesión.
- Validación de tokens.
- Gestión de sesiones.

---

# 47. Módulo InstitutionalIdentity

Responsabilidades:

- Validar autenticación institucional.
- Comprobar organización `virtual.upt.pe`.
- Obtener correo.
- Obtener nombre.
- Obtener identificador institucional cuando esté disponible.

---

# 48. Módulo IntranetVerification

Responsabilidades:

- Recibir temporalmente código y contraseña.
- Crear sesión contra la intranet.
- Resolver flujo de CAPTCHA.
- Detectar credenciales inválidas.
- Detectar autenticación correcta.
- Obtener nombre.
- Cerrar sesión.
- Eliminar credenciales temporales de memoria.
- Devolver únicamente el resultado necesario.

---

# 49. Módulo IdentityMatching

Responsabilidades:

- Recibir nombre institucional.
- Recibir nombre de intranet.
- Normalizar ambos.
- Compararlos.
- Decidir si corresponden a la misma persona.
- Registrar el resultado.

---

# 50. Módulo Geolocation

Responsabilidades:

- Recibir coordenadas.
- Calcular distancia.
- Buscar punto de acceso cercano.
- Validar radio permitido.
- Rechazar ubicaciones no válidas.

---

# 51. Módulo AccessCredentials

Responsabilidades:

- Generar OTP.
- Generar nonce.
- Generar credencial.
- Registrar credencial.
- Establecer expiración.
- Revocar credenciales.

---

# 52. Módulo QRValidation

Responsabilidades:

- Interpretar token.
- Verificar autenticidad.
- Validar expiración.
- Validar OTP.
- Validar estado.
- Prevenir replay.
- Validar usuario.
- Registrar acceso.

---

# 53. Módulo Audit

Responsabilidades:

- Registrar operaciones sensibles.
- Mantener trazabilidad.
- Facilitar revisión administrativa.

---

# 54. Flutter

Flutter deberá separar:

```text
Presentación
Estado
Servicios
Modelos
API
Almacenamiento seguro
```

Las reglas críticas no deberán encontrarse exclusivamente en Flutter.

---

# 55. Pantallas del estudiante

Como mínimo:

```text
Splash
Login institucional
Validación intranet
Inicio
Perfil digital
Solicitar acceso
QR activo
Estado del QR
Configuración
Cerrar sesión
```

---

# 56. Pantalla de validación de intranet

Esta pantalla deberá solicitar únicamente lo necesario.

Por ejemplo:

```text
Código universitario
Contraseña
CAPTCHA
```

La interfaz deberá indicar claramente que:

```text
La contraseña se utiliza únicamente para comprobar el acceso a la intranet y no será almacenada.
```

Después de la validación, los campos sensibles deberán limpiarse.

---

# 57. Pantallas de seguridad

```text
Login
Panel de seguridad
Escáner QR
Validando
Acceso autorizado
Acceso rechazado
Historial reciente
```

---

# 58. Pantallas administrativas

```text
Dashboard
Usuarios
Roles
Puntos de acceso
Accesos
Intentos rechazados
Auditoría
Configuración
```

---

# 59. Comunicación Flutter - Node.js

Siempre mediante HTTPS.

```text
Flutter
   |
   | HTTPS
   v
Node.js
```

Nunca:

```text
Flutter
   |
   v
MySQL
```

---

# 60. Comunicación Node.js - MySQL

Solamente Node.js conocerá:

- Host.
- Puerto.
- Usuario.
- Contraseña.
- Base de datos.

Estas credenciales estarán en variables de entorno.

No deberán subirse a GitHub.

---

# 61. Comunicación Node.js - Intranet

```text
Node.js
   |
   v
IntranetVerificationService
   |
   v
Intranet UPT
```

El servicio deberá tener tiempo de vida limitado.

La sesión de intranet no deberá reutilizarse como sesión de nuestra aplicación.

---

# 62. Flujo completo de primer registro

```text
1. Usuario instala la aplicación.

2. Abre Flutter.

3. Selecciona iniciar sesión.

4. Se autentica con cuenta institucional.

5. Backend comprueba organización virtual.upt.pe.

6. Se obtiene correo institucional.

7. Se obtiene nombre institucional.

8. Usuario pasa a validación de intranet.

9. Ingresa código.

10. Ingresa contraseña.

11. Resuelve CAPTCHA, si corresponde.

12. Backend intenta iniciar sesión en intranet.

13. Si las credenciales son inválidas:
    verificación rechazada.

14. Si las credenciales son válidas:
    backend obtiene nombre.

15. Backend compara nombre institucional e intranet.

16. Si coinciden:
    identity_verified = true.

17. Se crea o actualiza usuario.

18. Se crea sesión propia.

19. Flutter recibe sesión.

20. Usuario accede al sistema.
```

---

# 63. Flujo de inicio de sesión posterior

No necesariamente se deberá solicitar intranet en cada apertura de la aplicación.

Se podrá definir una política de reverificación.

Ejemplo:

- Primera activación: obligatoria.
- Después de cerrar sesión completamente: según política.
- Después de cambiar contraseña institucional: reverificar.
- Después de determinado número de días: reverificar.
- Si existe actividad sospechosa: reverificar.
- Si el administrador lo solicita: reverificar.

Esto deberá ser configurable.

---

# 64. Flujo completo de ingreso a la universidad

```text
Usuario autenticado
        |
        v
Flutter
        |
        | solicitar QR
        v
Obtener GPS
        |
        v
Node.js
        |
        +--> sesión válida
        |
        +--> identidad verificada
        |
        +--> usuario activo
        |
        +--> ubicación válida
        |
        v
Generar OTP
        |
        v
Generar nonce
        |
        v
Generar credencial
        |
        v
Guardar en MySQL
        |
        v
Devolver token
        |
        v
Flutter muestra QR
```

Después:

```text
Guardia escanea
        |
        v
Flutter Seguridad
        |
        v
Node.js
        |
        +--> token válido
        +--> no expirado
        +--> no utilizado
        +--> usuario activo
        +--> usuario verificado
        +--> guardia autorizado
        |
        v
Registrar acceso
        |
        v
Marcar credencial USED
        |
        v
Mostrar identidad + fotografía
```

---

# 65. Seguridad

El sistema deberá implementar como mínimo:

- HTTPS.
- Tokens de sesión.
- Refresh tokens.
- Expiración.
- Almacenamiento seguro en Flutter.
- Roles.
- Permisos.
- Rate limiting.
- Protección contra fuerza bruta.
- Validación de entradas.
- Credenciales QR temporales.
- OTP.
- Nonce.
- Prevención de replay.
- Geolocalización.
- Auditoría.
- Variables de entorno.
- Revocación de sesiones.
- Control de dispositivos.
- Registro de intentos sospechosos.

---

# 66. Seguridad específica de la contraseña de intranet

La contraseña deberá tener una política especialmente estricta.

No guardar en MySQL.

No guardar en Redis, si posteriormente se utiliza.

No guardar en logs.

No enviar a servicios de analítica.

No incluir en excepciones.

No guardar en archivos temporales.

No incluir en auditoría.

No incluir en trazas.

No incluir en respuestas del backend.

No mantenerla más tiempo del necesario en memoria.

Después de terminar la validación, deberá descartarse.

---

# 67. Privacidad

El QR no deberá contener en texto legible:

- Nombre.
- Código universitario.
- Correo.
- DNI.
- Escuela.
- Fotografía.
- Ubicación.

El escáner solamente recibirá esos datos después de validar correctamente la credencial.

---

# 68. Manejo de errores

El sistema deberá controlar:

- Sin Internet.
- Cuenta institucional inválida.
- Cuenta fuera de `virtual.upt.pe`.
- Intranet no disponible.
- Credenciales de intranet inválidas.
- CAPTCHA incorrecto.
- Nombre no coincidente.
- Usuario bloqueado.
- GPS desactivado.
- Permiso de ubicación rechazado.
- Ubicación fuera del perímetro.
- QR expirado.
- QR utilizado.
- QR manipulado.
- Sesión expirada.
- Servidor no disponible.

---

# 69. Respuestas de verificación de identidad

Algunos resultados posibles:

```text
INSTITUTIONAL_ACCOUNT_INVALID
ORGANIZATION_NOT_ALLOWED
INTRANET_INVALID_CREDENTIALS
INTRANET_UNAVAILABLE
CAPTCHA_INVALID
IDENTITY_NAME_MISMATCH
IDENTITY_VERIFIED
```

El frontend podrá transformar estas respuestas en mensajes entendibles para el usuario.

---

# 70. Pruebas obligatorias

Se deberán probar como mínimo:

## Identidad

- Cuenta institucional válida.
- Cuenta institucional inválida.
- Correo de otra organización.
- Intranet válida.
- Contraseña incorrecta.
- Código incorrecto.
- CAPTCHA incorrecto.
- Nombre coincidente.
- Nombre no coincidente.
- Intranet caída.
- Tiempo de espera agotado.

## QR

- QR válido.
- QR vencido.
- QR reutilizado.
- QR manipulado.
- QR de usuario bloqueado.
- QR generado fuera de zona.

## Seguridad

- Estudiante intentando usar escáner.
- Guardia sin sesión.
- Sesión expirada.
- Dos escaneos simultáneos.
- Usuario bloqueado después de generar QR.

---

# 71. Lo que no se debe hacer

No conectar Flutter directamente a MySQL.

No almacenar la contraseña de intranet.

No almacenar el CAPTCHA.

No confiar únicamente en que el correo termine en `@virtual.upt.pe`.

No poner información personal dentro del QR.

No utilizar QR permanente.

No permitir reutilización.

No confiar solamente en GPS.

No decidir permisos solamente desde Flutter.

No poner claves privadas dentro de la app.

No registrar información sensible en logs.

No utilizar el scraper de notas completo cuando solamente se necesita validar identidad.

---

# 72. MVP

El MVP deberá incluir:

- Flutter.
- Node.js.
- MySQL.
- Login institucional.
- Restricción a organización `virtual.upt.pe`.
- Validación adicional con intranet.
- Comparación de nombres.
- Sesiones.
- Roles.
- Perfil.
- Ubicación.
- Puntos de acceso.
- QR dinámico.
- OTP.
- Nonce.
- Expiración.
- Escáner.
- Validación backend.
- Prevención de reutilización.
- Historial.
- Auditoría básica.
- Panel administrativo básico.

---

# 73. Funciones para una segunda etapa

Podrán agregarse posteriormente:

- Notificaciones push.
- NFC.
- Bluetooth.
- Integración con torniquetes.
- Biometría.
- Device attestation.
- Apple Wallet.
- Google Wallet.
- Reconocimiento facial.
- Analítica avanzada.
- Alertas automáticas.
- API institucional oficial.
- Integración SSO completa.

---

# 74. Orden recomendado de implementación

```text
1. Arquitectura.

2. Modelo de datos.

3. Backend Node.js base.

4. MySQL.

5. Flutter base.

6. Login institucional.

7. Restricción virtual.upt.pe.

8. Servicio de validación intranet.

9. Extracción del nombre.

10. Comparación de identidad.

11. Sesiones.

12. Roles.

13. Perfil.

14. Ubicación.

15. Puntos de acceso.

16. Generación OTP.

17. Nonce.

18. Credencial temporal.

19. QR.

20. Escáner.

21. Validación.

22. Prevención replay.

23. Historial.

24. Administración.

25. Auditoría.

26. Pruebas.

27. Documentación.
```

---

# 75. Plan de Sprints

## Sprint 1
### 7 de septiembre - 20 de septiembre

Fundamentos.

- Arquitectura.
- Modelo MySQL.
- Estructura Flutter.
- Estructura Node.js.
- Comunicación Flutter - Backend.
- Usuarios.
- Roles.
- Configuración de ambientes.

## Sprint 2
### 21 de septiembre - 4 de octubre

Identidad.

- Login institucional.
- Restricción `virtual.upt.pe`.
- Sesiones.
- Servicio de intranet.
- Flujo de CAPTCHA.
- Detección de credenciales inválidas.
- Obtención de nombre.
- Comparación de nombres.
- Estado `identity_verified`.

## Sprint 3
### 5 de octubre - 18 de octubre

Credenciales de acceso.

- GPS.
- Puntos de acceso.
- Geofencing.
- OTP.
- Nonce.
- Expiración.
- Credenciales protegidas.
- Generación QR.

## Sprint 4
### 19 de octubre - 1 de noviembre

Personal de seguridad.

- Escáner.
- Validación backend.
- Fotografía.
- Resultado de acceso.
- Prevención de reutilización.
- Registro de acceso.
- Concurrencia.

## Sprint 5
### 2 de noviembre - 15 de noviembre

Administración.

- Gestión de usuarios.
- Roles.
- Bloqueos.
- Puntos de acceso.
- Historial.
- Auditoría.
- Configuración.

## Sprint 6
### 16 de noviembre - 29 de noviembre

Integración.

- Seguridad.
- Pruebas.
- Casos negativos.
- Concurrencia.
- GPS.
- Sesiones.
- Corrección de errores.
- UX.
- Optimización.

## Sprint final
### 30 de noviembre - primera semana de diciembre

- Estabilización.
- Documentación.
- Evidencias.
- Pruebas finales.
- Presentación.
- Demostración.
- Correcciones finales.

---

# 76. Distribución del equipo

Equipo:

- Carlos Ayala Ramos.
- María del Rosario Delgado.
- Jefferson Rosas Chambilla.

Distribución principal sugerida:

## Carlos

- Backend.
- Autenticación.
- Integración institucional.
- Seguridad.
- Sesiones.
- Servicio de intranet.

## Rosario

- Flutter estudiante.
- Login.
- Perfil.
- Ubicación.
- Generación QR.
- Experiencia de usuario.

## Jefferson

- MySQL.
- Modelo de datos.
- Escáner.
- Registro de accesos.
- Administración.
- Soporte backend.

La integración deberá revisarse entre todos porque los módulos dependen entre sí.

---

# 77. Arquitectura final resumida

```text
ESTUDIANTE
    |
    v
FLUTTER
    |
    +-----------------------------+
    |                             |
    | Login institucional         | Validación intranet
    v                             v
Cuenta @virtual.upt.pe       Intranet UPT
    |                             |
    +-------------+---------------+
                  |
                  v
              NODE.JS
                  |
          Comparar identidad
                  |
                  v
          identity_verified
                  |
                  v
                MYSQL
```

Generación:

```text
FLUTTER
   |
   v
GPS
   |
   v
NODE.JS
   |
   +--> sesión
   +--> identidad verificada
   +--> estado
   +--> ubicación
   |
   v
OTP + NONCE
   |
   v
CREDENCIAL TEMPORAL
   |
   v
MYSQL
   |
   v
FLUTTER
   |
   v
QR
```

Validación:

```text
QR
 |
 v
FLUTTER SEGURIDAD
 |
 v
NODE.JS
 |
 +--> autenticidad
 +--> expiración
 +--> OTP
 +--> nonce
 +--> usuario
 +--> verificación
 +--> ubicación
 +--> uso anterior
 +--> rol del guardia
 |
 v
MYSQL
 |
 v
REGISTRAR ACCESO
 |
 v
MARCAR USED
 |
 v
ACCESO AUTORIZADO / DENEGADO
```

---

# 78. Idea central

El proyecto no debe entenderse simplemente como una aplicación que genera códigos QR.

El proyecto es un sistema de identidad digital, autorización y trazabilidad.

La confianza se construirá mediante varias capas:

```text
Cuenta institucional real
+
Organización virtual.upt.pe
+
Validación de intranet
+
Coincidencia de identidad
+
Sesión segura
+
Ubicación
+
Credencial temporal
+
OTP
+
Nonce
+
Expiración
+
Prevención de reutilización
+
Verificación de fotografía
+
Auditoría
```

El QR será únicamente el medio utilizado para presentar temporalmente esa identidad.

---

# 79. Resultado esperado de la demostración

La demostración final debería permitir realizar este flujo completo:

```text
1. Estudiante abre Flutter.

2. Inicia sesión con su cuenta institucional.

3. El sistema comprueba que pertenece a virtual.upt.pe.

4. Se obtiene el nombre institucional.

5. El estudiante realiza validación adicional mediante intranet.

6. Ingresa código, contraseña y CAPTCHA.

7. El backend comprueba que las credenciales no sean inválidas.

8. El backend obtiene el nombre desde intranet.

9. El backend compara ambos nombres.

10. La identidad queda verificada.

11. El estudiante solicita acceso.

12. Flutter obtiene GPS.

13. Node.js valida ubicación.

14. Node.js genera OTP.

15. Node.js genera nonce.

16. Node.js crea credencial temporal.

17. Flutter muestra QR.

18. Guardia escanea QR.

19. Backend valida la credencial.

20. Se muestra fotografía e identidad.

21. Guardia confirma visualmente a la persona.

22. Se registra acceso.

23. El QR queda marcado como utilizado.

24. Se intenta utilizar nuevamente.

25. Backend rechaza el segundo intento.

26. Administrador consulta el historial.

27. Se observa el acceso válido y el intento rechazado.
```

Con este flujo se demuestra que el sistema implementa una identidad universitaria real y no solamente una tarjeta digital.

---

# 80. Conclusión

La arquitectura definitiva será:

```text
Flutter + Node.js + MySQL
```

con dos fuentes de validación de identidad:

```text
Cuenta institucional @virtual.upt.pe
+
Intranet UPT
```

La cuenta institucional demostrará que el usuario posee una identidad perteneciente a la organización autorizada.

La intranet actuará como una segunda comprobación de pertenencia e identidad.

El sistema únicamente necesitará conocer si el login de intranet fue válido y cuál es el nombre asociado.

La contraseña de intranet nunca será almacenada.

Una vez verificado el usuario, todo el control de acceso se realizará mediante nuestro propio backend, nuestras propias sesiones y credenciales QR temporales.

De esta manera la solución mantiene separadas:

- La autenticación institucional.
- La comprobación adicional de intranet.
- La identidad interna del sistema.
- El control de acceso.
- La auditoría.

Esto permite desarrollar un sistema más seguro, mantenible y preparado para reemplazar en el futuro la automatización de intranet por una integración oficial de la Universidad Privada de Tacna.
