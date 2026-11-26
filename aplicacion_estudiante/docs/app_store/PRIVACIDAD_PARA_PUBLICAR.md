# Política de privacidad para publicar

La política completa se sirve en `/privacidad` desde el nuevo
[portal de privacidad](../../../portal-privacidad-upt/README.md).
Su texto vive en `portal-privacidad-upt/src/paginas.js`; el aviso de la app es la
versión 1.2, del 26/11/2026.

Datos indicados por el usuario:

- Responsable: Carlos Daniel Ayala Ramos.
- Contacto: ca2022074266@virtual.upt.pe.
- Conservación de registros y respaldos: 30 días.

La API depura registros de estudiantes de más de 30 días y permite eliminar
la cuenta y sus datos de la base operativa mediante verificación y confirmación.
La identidad básica y vinculaciones activas se mantienen mientras exista la
cuenta. No se elimina la matrícula ni la cuenta académica externa. Si había una
restricción de ingreso, se conserva por separado una referencia HMAC del código
y su caducidad, por máximo 30 días o hasta su vencimiento anterior, según la
regla indicada por el responsable. Se informa como dato seudonimizado, no anónimo.

Antes de publicar, desplegar el portal con HTTPS, configurar su URL y el callback
Google en la API, identificar correctamente el alojamiento y comprobar el proceso
real con una cuenta de prueba. Configurar por separado en Dokploy/proveedor el
máximo de 30 días para respaldos, binlogs y logs; el código no administra esos
servicios externos. Confirmar autorización de la UPT para las credenciales y marca.

Las URL finales siguen vacías hasta que el usuario facilite el dominio. Una vez
verificadas, incorporar las mismas en la configuración de la app y App Store Connect.
