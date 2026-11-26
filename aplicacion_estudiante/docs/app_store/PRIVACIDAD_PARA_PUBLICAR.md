# Política de privacidad para publicar

La política completa está publicada en
[ingreso-upt.fottuto.men/privacidad](https://ingreso-upt.fottuto.men/privacidad) desde el
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

Las tres páginas públicas responden HTTP 200 por HTTPS. Antes de enviar la app,
completar las variables de la API y el callback Google, identificar correctamente
el alojamiento y comprobar el proceso real con una cuenta de prueba. El inicio
de eliminación devuelve actualmente HTTP 503 (`RESTRICCIONES_NO_CONFIGURADAS`).
Configurar por separado en Dokploy/proveedor el
máximo de 30 días para respaldos, binlogs y logs; el código no administra esos
servicios externos. Confirmar autorización de la UPT para las credenciales y marca.

Las URL finales están incorporadas en la app y en `config/app_store.json`.
Usar las mismas en App Store Connect: `/privacidad` para la política y
`/soporte` para soporte, bajo `https://ingreso-upt.fottuto.men`.
