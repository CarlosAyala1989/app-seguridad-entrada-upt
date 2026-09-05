# Refinamiento INVEST - Sprints 1 y 2

Se revisaron las historias de usuario previstas para Sprint 1 y Sprint 2. Los spikes y habilitadores técnicos no se fuerzan al formato de historia de usuario: se controlan mediante timebox y criterios de terminación explícitos.

| ID | I | N | V | E | S | T | Evidencia de refinamiento |
|---|---|---|---|---|---|---|---|
| US-01 | Sí | Sí | Sí | Sí | Sí | Sí | Alcance limitado a autenticación institucional + intranet/SSO y creación de sesión; Gherkin en `criterios/US-01.feature`. |
| US-04 | Sí | Sí | Sí | Sí | Sí | Sí | Perfil mínimo separado de la emisión QR; cuatro estados explícitos en `criterios/US-04.feature`. |
| US-05 | Sí | Sí | Sí | Sí | Sí | Sí | Emisión QR dinámica delimitada a token opaco, OTP/nonce, ubicación y vigencia; Gherkin en `criterios/US-05.feature`. |
| US-06 | Sí | Sí | Sí | Sí | Sí | Sí | Captura/validación de ubicación separada de la representación QR; criterios en `criterios/US-06.feature`. |
| US-08 | Sí | Sí | Sí | Sí | Sí | Sí | Escaneo y envío del token al backend; la decisión de acceso no se mezcla con Flutter; criterios en `criterios/US-08.feature`. |

## Interpretación

- **Independent:** cada historia puede implementarse y probarse con contratos o dobles aunque otra integración aún no esté disponible.
- **Negotiable:** los detalles de UI y adaptadores pueden cambiar sin alterar el valor buscado.
- **Valuable:** cada historia entrega una capacidad observable a usuario, validador o sistema.
- **Estimable:** todas tienen alcance y criterios suficientes para recibir puntos relativos.
- **Small:** ninguna supera 5 puntos; no existen historias de 13 puntos o más.
- **Testable:** cada historia de Sprint 1 y 2 posee criterios verificables; las que muestran/tratan datos incluyen éxito, vacío/no disponible, sin conexión y error de servidor.

## Elementos no-Historia en los dos primeros sprints

- SP-01 y SP-02: spikes de 4 horas con resultado documental.
- TD-01 y TD-02: habilitadores técnicos con criterios de terminación verificables.
