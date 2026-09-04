# Definition of Done · IngresoUPT

Esta definición se aplica a cada incremento. Un criterio manual no se declara cumplido sin evidencia verificable en el Pull Request.

| # | Criterio adaptado | Cómo se verifica |
|---|---|---|
| 1 | Flutter compila para Android e iOS y Node.js inicia sin errores de sintaxis. | Jobs `flutter-android`, `flutter-ios` y `backend` de la CI en verde. |
| 2 | No existen advertencias del analizador estático ni errores del linter. | `flutter analyze` y `npm run lint` en CI. |
| 3 | La lógica nueva tiene pruebas unitarias en verde. | `flutter test --coverage` y `npm test` en CI. |
| 4 | La cobertura de la capa de dominio de Flutter es al menos 70 %. | `scripts/check_domain_coverage.dart` bloquea la CI si el porcentaje es menor. |
| 5 | Un integrante distinto del autor revisó el cambio. | Pull Request con una aprobación obligatoria. |
| 6 | No existen secretos, tokens reales ni contraseñas versionadas. | Trivy Secret Scanner en CI y revisión del diff. |
| 7 | La funcionalidad opera en un teléfono físico. | Video o captura completa en `docs/evidencias/S02/dispositivo/`, enlazado en el PR. |
| 8 | Se implementaron carga, datos, vacío y error con reintento. | Pruebas del ViewModel y revisión de `perfil_digital_page.dart`. |
| 9 | Los textos visibles se encuentran centralizados y preparados para localización. | Revisión de `shared/l10n/app_strings.dart`; no se aceptan cadenas visibles dispersas. |
| 10 | Los controles tienen etiquetas comprensibles y contraste suficiente. | Revisión con Semantics/Accessibility Scanner y tema Material 3. |
| 11 | Los cambios de arranque, variables y dependencias están documentados. | Lista de configuración y comandos en README revisada en el PR. |
| 12 | El incremento puede demostrarse sin explicación previa. | Ensayo con el guion éxito-vacío-error-reintento y evidencia enlazada. |

## Reglas adicionales de seguridad

- Flutter nunca accede directamente a MySQL.
- Las decisiones de autenticación, rol, geocerca y validez de credencial pertenecen al backend.
- Las credenciales reales se inyectan mediante configuración no versionada.
- Ningún log contiene contraseña de intranet, token completo, OTP, CAPTCHA o datos personales innecesarios.
