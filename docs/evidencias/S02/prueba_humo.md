# Evidencia · Prueba de humo de cámara

## Propósito

Se evaluó la capacidad crítica de cámara requerida para el futuro escáner QR en los dos stacks finalistas: Flutter y React Native.

## Artefactos ejecutables

| Stack | Ruta | Verificación automatizada |
|---|---|---|
| Flutter | `spikes/flutter_camera/` | Resolución de dependencias, análisis estático y compilación Android en la CI. |
| React Native + Expo | `spikes/react_native_camera/` | Resolución de dependencias y exportación web en la CI. |

## Procedimiento reproducible en dispositivo

1. Se abre el incremento del stack correspondiente.
2. Se instala en un teléfono de pruebas sin credenciales ni datos personales.
3. Se acepta el permiso de cámara.
4. Se confirma que la previsualización en vivo ocupa la pantalla.
5. Se niega el permiso y se confirma que la aplicación ofrece una explicación y una salida controlada.
6. Se registra un video corto o capturas completas en `docs/evidencias/S02/dispositivo/`.

## Criterio de decisión

La compilación automatizada demuestra que las bibliotecas se integran con cada stack. La evidencia de sensor real requiere ejecución física y no se sustituye por una captura fabricada. La decisión final se conserva en ADR-002 y favorece Flutter por competencia, mantenibilidad y puntaje ponderado.
