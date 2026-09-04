# Product Goal — IngresoUPT

Al término del semestre, **IngresoUPT** permitirá a estudiantes, docentes y trabajadores de la Universidad Privada de Tacna autenticarse con su correo institucional y la intranet/SSO, acreditar desde su teléfono su identidad y estado de autorización mediante una credencial QR dinámica de corta vigencia, y permitir que el personal de seguridad valide el ingreso de forma rápida y trazable sin depender únicamente de la inspección visual del carné o DNI.

## Stack tecnológico confirmado

- **Aplicación móvil:** Flutter + Dart.
- **Backend:** Node.js mediante API REST.
- **Base de datos:** MySQL.
- **Arquitectura:** Flutter → HTTPS/REST → Node.js → MySQL.

La aplicación Flutter no se conectará directamente a MySQL. Toda autenticación, autorización, generación/validación de QR, OTP/nonce, geocerca y persistencia será coordinada por el backend Node.js.

## QR, OTP y ubicación

El QR no expondrá en texto legible los datos de identidad, OTP/nonce ni coordenadas. Flutter obtendrá la ubicación del dispositivo y solicitará la credencial a Node.js. Node.js generará un token opaco de corta vigencia y MySQL conservará los metadatos necesarios para validarlo y evitar reutilizaciones.

La planificación del producto se ejecuta en siete sprints entre el **7 de septiembre y el 4 de diciembre de 2026**.
