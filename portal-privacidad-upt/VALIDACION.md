# Comprobaciones realizadas el 26/11/2026

| Comprobación | Resultado |
| --- | --- |
| Suite completa de API en MariaDB 11.8.9 aislada | 154 pruebas aprobadas, sin omisiones. |
| Eliminación y conservación en MySQL 8.4.11 aislado | 11 pruebas aprobadas. |
| Portal: rutas, cookies, CSRF, confirmación, fallo de API y redirección | 6 pruebas aprobadas. |
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
y `/eliminar-cuenta` respondieron HTTP 200 por HTTPS. El inicio de eliminación
devolvió HTTP 503 y la API indicó `RESTRICCIONES_NO_CONFIGURADAS`: completar
`CLAVE_RESTRICCIONES_IDENTIDAD`, confirmar las variables de Google y repetir
el flujo real antes de publicar la app. No se inició sesión en Google ni se
eliminó ninguna cuenta durante esta comprobación.

También se observó que Cloudflare ocultaba el correo mediante un script
incompatible con la CSP del portal. Se añade `Cache-Control: no-transform`;
comprobar de nuevo el correo público tras desplegar esa corrección.
