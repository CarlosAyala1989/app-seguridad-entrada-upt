# ADR-002 · Stack tecnológico

- **Estado:** aceptada
- **Fecha:** 2026-09-04
- **Decidido por:** equipo IngresoUPT

## Contexto

El producto requiere una aplicación móvil con cámara/QR, GPS y almacenamiento seguro; un backend que concentre autenticación, autorización, OTP/nonce, anti-replay y auditoría; y persistencia relacional. Debe ser viable desde Windows/Linux durante el desarrollo cotidiano y conservar una ruta de compilación para Android e iOS.

## Evaluación

La matriz completa se encuentra en [`evaluacion_stacks.csv`](evaluacion_stacks.csv). La calificación ponderada fue:

| Alternativa | Puntaje sobre 5 |
|---|---:|
| Flutter | **4.90** |
| React Native | 3.65 |
| Nativo | 3.45 |
| Kotlin Multiplatform | 2.70 |

## Prueba de humo de los finalistas

Se prepararon dos incrementos mínimos para la capacidad crítica de cámara:

- `spikes/flutter_camera/`: inicializa la cámara con el paquete `camera` y presenta `CameraPreview`.
- `spikes/react_native_camera/`: solicita permiso e inicializa `CameraView` mediante `expo-camera`.

La CI verifica que ambos incrementos resuelvan dependencias y produzcan una compilación/exportación. La comprobación de imagen real y permiso en teléfono físico se registra separadamente porque un runner de CI no sustituye el sensor del dispositivo.

## Decisión

Se selecciona **Flutter + Dart** para la aplicación móvil, **Node.js** para la API REST y la lógica de seguridad, y **MySQL** para la persistencia. Flutter obtiene el mayor puntaje, coincide con la base existente y permite mantener una sola aplicación móvil. Node.js conserva aisladas las integraciones institucionales y MySQL soporta relaciones, transacciones y auditoría.

## Plan de salida

Si Flutter deja de cubrir una capacidad crítica o presenta un problema de rendimiento medido que no pueda resolverse con un complemento nativo, se reconsiderará React Native o desarrollo nativo.

La salida conserva:

- La API REST Node.js y sus contratos.
- El modelo y las migraciones MySQL.
- Las reglas de negocio del backend, autenticación, OTP/nonce, geocerca, anti-replay y auditoría.
- Las historias, ADR, pruebas de contrato y especificación de estados.

Se reescribirían la presentación, el manejo de estado y los adaptadores de dispositivo desarrollados en Dart. El costo estimado es medio antes del Sprint 3 y alto desde el Sprint 4. La migración se ejecutaría por funcionalidad, manteniendo el mismo contrato REST para evitar una sustitución simultánea del backend.
