# Stack tecnológico oficial — IngresoUPT

## Decisión confirmada

| Capa | Tecnología | Responsabilidad |
|---|---|---|
| Aplicación móvil | **Flutter + Dart** | UI, navegación, login, cámara/QR, GPS, permisos, biometría, almacenamiento seguro local y consumo HTTP |
| Backend | **Node.js** | API REST, autenticación, lógica de negocio, QR/OTP, geocerca, autorización, sesiones y auditoría |
| Base de datos | **MySQL** | Usuarios, roles, estados, sesiones, tokens QR, zonas, reglas, validaciones, incidencias y alertas |

## Arquitectura

**Flutter → HTTPS/REST → Node.js → MySQL**

Flutter nunca se conecta directamente a MySQL. La aplicación móvil conoce únicamente la API REST de Node.js.

## Autenticación

1. El usuario ingresa su correo institucional en Flutter.
2. Flutter envía la solicitud por HTTPS a Node.js.
3. Node.js valida la identidad contra intranet/SSO o un simulador académico documentado mientras no exista integración institucional autorizada.
4. Node.js relaciona el resultado con el usuario almacenado en MySQL y emite la sesión de la app.
5. Flutter conserva únicamente el material de sesión necesario usando almacenamiento seguro.

La contraseña de intranet no se almacena en Flutter ni en MySQL en texto plano.

## QR + OTP/nonce + ubicación

Flutter obtiene latitud, longitud, precisión y marca de tiempo. Node.js valida sesión, estado y geocerca, genera OTP/nonce y un token opaco de corta vigencia. MySQL registra token, usuario, OTP/nonce, ubicación, emisión, expiración y estado (`unused`, `used`, `revoked`). Flutter representa únicamente el token como QR.

Al validar, una app Flutter con rol de seguridad escanea el token y lo envía a Node.js. Node.js consulta MySQL y comprueba expiración, OTP/nonce, no reutilización, revocación, política geográfica, reglas de acceso y estado del usuario.

## Geolocalización

Las coordenadas se obtienen desde el proveedor de ubicación del dispositivo en Flutter. Google Maps puede utilizarse para visualización, pero la validación de geocerca la realiza Node.js con las zonas/reglas almacenadas en MySQL.
