# ADR-003 · Backend propio y adaptadores temporales

- **Estado:** aceptada
- **Fecha:** 2026-09-04

## Decisión

Se utiliza un backend propio en Node.js. Durante el Taller 02, el endpoint de perfil emplea un repositorio en memoria únicamente como doble controlado mediante `PROFILE_SCENARIO`. Este adaptador permite demostrar datos, vacío y error sin conectar Flutter a MySQL ni inventar una autenticación institucional.

Antes de producción, el adaptador se sustituirá por un repositorio MySQL y la sesión de demostración por el módulo de autenticación institucional e intranet. El caso de uso y el contrato REST no deberán cambiar.

## Restricciones

- El repositorio en memoria no se habilita en producción.
- `DEMO_SESSION_TOKEN` se configura localmente y no se versiona.
- La contraseña y el CAPTCHA de la intranet no forman parte de este incremento ni se almacenan.
- Las respuestas de perfil contienen únicamente los datos mínimos de la identidad digital.
