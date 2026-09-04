# Decisión técnica — QR, OTP/nonce y ubicación

## Autenticación
1. El usuario ingresa su correo institucional desde Flutter.
2. Node.js valida la identidad mediante intranet/SSO o el mecanismo institucional disponible.
3. La app no almacena la contraseña de intranet.
4. MySQL mantiene la asociación con el registro universitario y metadatos de sesión.

## Ubicación
- Flutter obtiene latitud, longitud, precisión y marca de tiempo desde el dispositivo.
- Google Maps puede utilizarse solo para visualización.
- Node.js compara la ubicación con la geocerca/zona permitida almacenada en MySQL.

## QR seguro
La opción del prototipo es un **token opaco aleatorio, de corta vigencia y de un solo uso**. El QR contiene únicamente algo equivalente a:

`upt://access/<TOKEN_OPACO>`

MySQL asocia internamente el token con usuario, OTP/nonce, latitud, longitud, precisión, emisión, expiración y estado de consumo.

No se utiliza un JWT solo firmado para ocultar datos, porque un payload firmado puede seguir siendo legible. Si en una versión futura se necesitan datos dentro del QR, deberá evaluarse cifrado autenticado.

## Validación
Node.js verifica existencia del token, expiración, OTP/nonce, no reutilización, revocación, geocerca, reglas de acceso y estado del usuario; MySQL registra el intento y Flutter muestra únicamente el resultado mínimo necesario.
