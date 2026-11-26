# Comprobaciones realizadas el 26/11/2026

| Comprobación | Resultado |
| --- | --- |
| Suite completa de API en MariaDB 11.8.9 aislada | 154 pruebas aprobadas, sin omisiones. |
| Eliminación y conservación en MySQL 8.4.11 aislado | 11 pruebas aprobadas. |
| Portal: rutas, Referrer-Policy, cookies, CSRF, confirmación, fallo de API y redirección | 6 pruebas aprobadas. |
| Aplicación de estudiante: privacidad y cuenta/ayuda | 12 pruebas aprobadas. |
| Análisis Flutter y comprobación de configuración iOS fuente | Sin incidencias. |
| Sintaxis de los módulos nuevos y repositorio de registro modificado | Correcta. |
| Dockerfile del portal | Imagen construida y proceso saludable. |
| Rutas del contenedor | `/privacidad`, `/soporte`, `/eliminar-cuenta`: HTTP 200. |

Las bases de pruebas son contenedores locales separados, con datos ficticios.
No se aplicaron migraciones ni eliminaciones a producción. Las pruebas cubren
rollback, invalidación de sesión y QR por retirada de registros, separación de
otros usuarios, reintentos, nonce/PKCE, expiración, persistencia entre instancias,
retención y restricción institucional seudonimizada.

La validación Google de las pruebas utiliza un proveedor simulado dentro del
proceso de pruebas; la imagen del portal no incluye ese proveedor ni un modo
de borrado ficticio. Hay que comprobar el Google real después de registrar los
dominios y el callback en Google Cloud y Dokploy.

No se realizó revisión visual interactiva: el navegador de la sesión no estaba
disponible. Antes de publicar, comprobar las páginas en Safari/iPhone, móvil y
escritorio, completar el flujo real con una cuenta de prueba, configurar los
respaldos/logs externos con máximo 30 días y seguir la guía de App Store.

Las URL finales de la app usan `https://ingreso-upt.fottuto.men`. En la
comprobación del despliegue del 26/11/2026, `/salud`, `/privacidad`, `/soporte`
y `/eliminar-cuenta` respondieron HTTP 200 por HTTPS. Tras completar la
configuración del despliegue, la API respondió HTTP 201 al iniciar la
eliminación y el portal HTTP 303 hacia Google, con el callback de eliminación,
PKCE, nonce y cookie segura. No se inició sesión en Google ni se eliminó
ninguna cuenta durante esta comprobación. Falta completar el flujo real con
una cuenta de prueba antes de publicar la app.

También se observó que Cloudflare ocultaba el correo mediante un script
incompatible con la CSP del portal. Se añadió `Cache-Control: no-transform`
y se comprobó el correo público y su enlace `mailto:` en el despliegue.

La captura del navegador mostró un HTTP 403 al pulsar el formulario. La
política `no-referrer` puede convertir su encabezado `Origin` en `null`, aunque
el formulario pertenezca al portal. La prueba HTTP anterior enviaba `Origin`
explícitamente y no detectaba ese caso. Se cambia la política a `same-origin`,
sin aceptar orígenes nulos ni retirar la protección CSRF. La prueba de regresión
falla con la cabecera anterior y pasa con la corregida; también comprueba que
se rechacen orígenes ajenos, ausentes, nulos y solicitudes `cross-site`.
Recargar la página antes de repetir el proceso para recibir la nueva política.
