# Definition of Done — IngresoUPT

Una historia pasa a **Listo** cuando:

1. El código compila/ejecuta en el entorno objetivo.
2. El análisis estático no presenta errores bloqueantes.
3. Las pruebas relacionadas pasan.
4. Existe Pull Request.
5. Un integrante distinto del autor revisó el cambio.
6. Se verificaron todos los criterios de aceptación.
7. No existen credenciales, contraseñas, tokens completos ni URL de producción expuestas.
8. Los logs no contienen datos personales innecesarios.
9. Las historias de seguridad quedan identificadas para revisión MASVS.
10. La evidencia requerida queda versionada y enlazada.
11. Para QR/ubicación se prueban expiración, no reutilización, error de ubicación y error de red cuando corresponda.

## Stack
- Flutter/Dart: `flutter analyze` y pruebas sin errores bloqueantes.
- Node.js: API y pruebas de backend sin errores bloqueantes.
- MySQL: configuración externa; Flutter no contiene credenciales ni conexión SQL directa.
- Las pruebas de integración usan una base MySQL de pruebas.
