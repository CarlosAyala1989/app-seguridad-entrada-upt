# Sprint Backlog - Sprint 1 · IngresoUPT

## Equipo
- Carlos Ayala Ramos - 2022074266 - `CarlosAyala1989`
- Maria del Rosario Delgado - 2026087688 - `rosario-code`
- Jefferson Rosas Chambilla - 2021072618 - `Ankluna72`

## Fechas
- Inicio: **lunes 07/09/2026**
- Fin: **viernes 18/09/2026**
- Sprint Review: **18/09/2026, 19:00**
- Sprint Retrospective: **18/09/2026, 19:30**

## Stack técnico del Sprint 1
- **Flutter + Dart:** proyecto móvil, login, cliente HTTP, estados de interfaz e identidad digital.
- **Node.js:** API REST inicial, autenticación y endpoint de identidad.
- **MySQL:** esquema inicial de usuarios/sesiones/estado de identidad y conexión exclusiva desde Node.js.
- Flujo obligatorio: **Flutter -> HTTPS/REST -> Node.js -> MySQL**.

## Sprint Goal
**Al finalizar el Sprint 1, un miembro de la comunidad UPT podrá autenticarse con su correo institucional y el mecanismo de intranet/SSO definido para el prototipo, y visualizar su identidad digital universitaria básica obtenida desde un servicio, con la aplicación funcionando en emulador y con manejo de los estados principales de interfaz.**

### Prueba del Sprint Goal
El objetivo se mantiene si una tarea técnica se sustituye por otra equivalente. El foco es demostrar el flujo de valor autenticación -> identidad digital, no completar una suma rígida de tarjetas.

## Capacidad
- 3 Developers x 10 días hábiles x 3 h/día = 90 h.
- Eventos de Scrum: aprox. 8 h.
- Saldo: 82 h.
- Reserva por imprevistos: 15 % = 12,3 h.
- Capacidad efectiva aproximada: **70 h**.
- Compromiso: **12 story points**, dentro de la regla del curso de 8-13 puntos para Sprint 1.

## Elementos seleccionados
| ID | Issue | Responsable inicial | Puntos |
|---|---|---|---:|
| SP-01 | #1 | Carlos Ayala Ramos (`CarlosAyala1989`) | 2 |
| TD-01 | #2 | Jefferson Rosas Chambilla (`Ankluna72`) | 2 |
| US-01 | #3 | Carlos Ayala Ramos (`CarlosAyala1989`) | 3 |
| US-04 | #4 | Maria del Rosario Delgado (`rosario-code`) | 5 |
| | | **Total** | **12** |

## Plan de entrega
| Elemento | Tareas principales | Responsable |
|---|---|---|
| SP-01 | Analizar login institucional, asociación cuenta-registro y backend simulado alternativo | Carlos |
| TD-01 | Base Flutter, cliente HTTP, API Node.js inicial, persistencia MySQL y estados loading/data/empty/error | Jefferson |
| US-01 | Pantalla de login, integración de autenticación, errores y sesión inicial | Carlos |
| US-04 | UI de identidad, datos mínimos y cuatro estados de interfaz | Maria |

## Riesgos
- No disponer de integración autorizada con intranet/SSO: usar adaptador simulado y declararlo.
- Asociación incorrecta correo-registro: resolver en backend; no confiar solo en el dominio del correo.
- Exposición de credenciales/tokens: no almacenar contraseña ni imprimir secretos.
- Dependencia entre Flutter y el contrato Node.js: usar mocks/dobles mientras se estabiliza el backend.

## Daily Scrum
- Hora: **20:30**
- Canal: **Google Meet**
- Duración: **15 minutos**
- Enfoque: progreso hacia el Sprint Goal, siguiente paso e impedimentos.

## GitHub
- SP-01: https://github.com/CarlosAyala1989/app-seguridad-entrada-upt/issues/1
- TD-01: https://github.com/CarlosAyala1989/app-seguridad-entrada-upt/issues/2
- US-01: https://github.com/CarlosAyala1989/app-seguridad-entrada-upt/issues/3
- US-04: https://github.com/CarlosAyala1989/app-seguridad-entrada-upt/issues/4

Los cuatro elementos ya tienen responsable identificable en GitHub. La rama inicial de Sprint 1 para US-01 se registra como evidencia del inicio del sprint.
