# ADR-001 · Arquitectura de la aplicación

- **Estado:** aceptada
- **Fecha:** 2026-09-04
- **Decidido por:** Carlos Ayala Ramos, María del Rosario Delgado y Jefferson Rosas Chambilla

## Contexto

El sistema de identidad digital y control de acceso de la UPT contempla aproximadamente 25 pantallas entre estudiante, personal de seguridad y administración. La solución consume una API REST propia, integra en el backend la autenticación institucional y un adaptador temporal de intranet, utiliza cámara, geolocalización y almacenamiento seguro, y debe controlar sesiones, roles, credenciales QR temporales, OTP, nonce, expiración, prevención de reutilización y auditoría.

El equipo está integrado por tres personas y ejecutará seis sprints más un periodo final de estabilización. La arquitectura debe permitir que la futura integración oficial de la UPT sustituya el adaptador de intranet sin modificar la aplicación móvil.

## Alternativas consideradas

| Alternativa | Ventajas | Desventajas | Adecuación al tamaño |
|---|---|---|---|
| MVC clásico | Estructura inicial simple y conocida. | Tiende a concentrar estado, red y reglas en controladores; dificulta las pruebas sin interfaz. | Insuficiente para el riesgo de identidad y acceso. |
| MVVM + repositorio y dominio ligero | Separa interfaz, estado, dominio y datos; permite probar el ViewModel sin emulador; mantiene un costo estructural proporcional. | Exige disciplina para impedir que reglas críticas migren al ViewModel. | **Adecuada.** |
| Clean Architecture completa con caso de uso para cada acción | Máxima separación y sustitución de adaptadores. | Multiplica clases y contratos incluso en operaciones sin lógica, elevando el costo para tres integrantes. | Desproporcionada para el horizonte académico. |

## Decisión

Se adopta **MVVM + repositorio con capa de dominio ligera**, organizada por funcionalidad en Flutter. Se crean casos de uso únicamente cuando existe lógica de negocio real: validación de los datos mínimos del perfil, comparación de identidad, validación de geocerca, generación de credenciales, validación anti-replay y aplicación de reglas por rol/horario.

El límite del sistema se conserva de forma obligatoria:

```text
Flutter → HTTPS/REST → Node.js → MySQL
```

Asimismo, se aplican estas reglas:

1. La vista no contiene reglas de negocio ni realiza llamadas de red.
2. El ViewModel no importa Flutter ni otro framework de interfaz.
3. Los DTO de la API y las entidades del dominio son clases distintas y se conectan mediante un mapeador.
4. Las dependencias se reciben por constructor y se ensamblan en `core/di`.
5. Flutter no se conecta a MySQL ni decide de forma definitiva autenticación, roles, geocerca o validez del QR.
6. La integración con la intranet permanece aislada en Node.js y nunca persiste contraseña, CAPTCHA, cookies o sesión temporal.

## Consecuencias

**Positivas.** El ViewModel puede probarse sin emulador; la API o el futuro proveedor institucional pueden cambiar detrás de sus adaptadores; los datos personales permanecen fuera del QR; cada funcionalidad sigue la misma estructura; y las reglas críticas se concentran en Node.js.

**Negativas.** Se crean más archivos por funcionalidad; la inyección manual debe mantenerse ordenada; y las revisiones de Pull Request deben vigilar la regla de dependencia.

**Costo de revertir.** Medio antes del Sprint 3 y alto después de implementar autenticación, QR y auditoría.
