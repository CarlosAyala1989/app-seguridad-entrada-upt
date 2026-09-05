# Product Goal - IngresoUPT

Al termino del semestre, **IngresoUPT** permitira a estudiantes, docentes y trabajadores de la Universidad Privada de Tacna autenticarse con su correo institucional y la intranet/SSO, acreditar desde su telefono su identidad y estado de autorizacion mediante una credencial QR dinamica de corta vigencia, y permitir que el personal de seguridad valide el ingreso de forma rapida y trazable sin depender unicamente de la inspeccion visual del carne o DNI. El producto quedara preparado para su distribucion en Google Play y App Store segun los requisitos de publicacion del curso.

## Stack tecnologico confirmado

- **Aplicacion movil:** Flutter + Dart.
- **Backend:** Node.js mediante API REST.
- **Base de datos:** MySQL.
- **Arquitectura:** Flutter -> HTTPS/REST -> Node.js -> MySQL.

La aplicacion Flutter no se conectara directamente a MySQL. Toda autenticacion, autorizacion, generacion/validacion de QR, OTP/nonce, geocerca y persistencia sera coordinada por el backend Node.js.

## QR, OTP y ubicacion

El QR no expondra en texto legible los datos de identidad, OTP/nonce ni coordenadas. Flutter obtendra la ubicacion del dispositivo y solicitara la credencial a Node.js. Node.js generara un token opaco de corta vigencia y MySQL conservara los metadatos necesarios para validarlo y evitar reutilizaciones.

La planificacion del producto se ejecuta en siete sprints entre el **7 de septiembre y el 4 de diciembre de 2026**.
