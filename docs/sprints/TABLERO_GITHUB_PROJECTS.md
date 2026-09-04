# Sprint Board - IngresoUPT

El tablero operativo del curso debe implementarse en **GitHub Projects** y contener todos los elementos del `PRODUCT_BACKLOG.csv`.

## Columnas y límites WIP

1. **Product Backlog** - sin límite operativo.
2. **Sprint Backlog** - historias seleccionadas para el sprint actual.
3. **En progreso (WIP 3)** - máximo una historia activa por Developer.
4. **En revisión (WIP 2)** - cambios con Pull Request abierto.
5. **En pruebas (WIP 2)** - aprobados por otro integrante y en verificación.
6. **Listo** - criterios de aceptación y Definition of Done cumplidos.

## Políticas explícitas de paso

| Paso | Política |
|---|---|
| Sprint Backlog -> En progreso | El Developer no tiene otra historia en progreso. |
| En progreso -> En revisión | Pull Request abierto, CI en verde y autoprueba en emulador. |
| En revisión -> En pruebas | Aprobado por un integrante distinto del autor. |
| En pruebas -> Listo | Todos los criterios de aceptación verificados y DoD cumplida. |

## Campos personalizados requeridos

- Sprint.
- Puntos.
- Riesgo.
- Dato personal.

## Distribución inicial

- Carlos Ayala Ramos (`CarlosAyala1989`): autenticación, integración institucional, backend y seguridad.
- Maria del Rosario Delgado (`rosario-code`): Flutter estudiante, identidad, ubicación y experiencia de usuario.
- Jefferson Rosas Chambilla (`Ankluna72`): MySQL, escáner, validación en puerta y soporte backend.

## Seguridad del tablero

- No colocar credenciales, contraseñas, tokens ni URLs de producción.
- Las historias que tratan datos personales están marcadas en el backlog.
- Las historias sensibles conservan la marca de requisitos de seguridad para revisión MASVS posterior.

> La captura verificable del tablero con los límites WIP visibles debe almacenarse en `docs/evidencias/S03/tablero.png`. La configuración del Project no puede sustituirse por este documento.
