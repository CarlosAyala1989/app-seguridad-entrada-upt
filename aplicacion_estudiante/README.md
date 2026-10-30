# Aplicación estudiante - examen práctico de la unidad II

**Curso:** SI-988 Soluciones Móviles II  
**Estudiante:** Carlos Daniel Ayala Ramos  
**Código:** 2022074266  
**Tipo de examen:** 4

## Cambios implementados

- Se agregó en el perfil el botón «Guardar QR sin conexión», que prepara la vinculación existente del QR e informa si se pudo guardar.
- Se agregó un servicio para serializar, guardar, leer y borrar registros del historial mediante interfaces de archivo y cifrado.
- Se añadieron pruebas unitarias separadas para el guardado y la lectura (punto 4), y para el archivo dañado y el borrado (punto 5). Las pruebas usan sustitutos simulados de archivo y cifrado.

El servicio de historial todavía no está conectado a la interfaz ni a implementaciones reales de archivo privado y cifrado AES-GCM. El modo sin conexión existente corresponde al QR y no cumple por sí solo el requisito de guardar una lista de registros en un archivo. Las pruebas simuladas no acreditan la implementación de los puntos 1 a 3.

## Archivos móviles afectados

- `lib/core/di/app_dependencies.dart`: conexión del botón con la preparación del QR.
- `lib/features/perfil_digital/presentation/views/perfil_digital_page.dart`: botón y mensajes de resultado.
- `lib/features/historial/data/local/historial_sin_conexion.dart`: servicio e interfaces de almacenamiento y cifrado.
- `test/features/historial/historial_punto_4_test.dart`: pruebas del punto 4.
- `test/features/historial/historial_punto_5_test.dart`: pruebas del punto 5.
- `test/features/historial/historial_simulados.dart`: sustitutos utilizados por las pruebas.

## Ejecutar las pruebas

Desde este directorio:

```bash
flutter test --reporter expanded test/features/historial/historial_punto_4_test.dart
flutter test --reporter expanded test/features/historial/historial_punto_5_test.dart
```
