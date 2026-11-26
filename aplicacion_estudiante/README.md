# Identidad UPT — aplicación de estudiante

Aplicación Flutter de identidad digital, QR de ingreso, historial y avisos.
Este directorio contiene exclusivamente la aplicación de estudiante.

```bash
flutter pub get
flutter analyze
flutter test
```

La configuración y los pendientes de publicación iOS se encuentran en
[docs/app_store/PUBLICACION.md](docs/app_store/PUBLICACION.md).
Las URL de privacidad, soporte y eliminación están vacías por ahora en
[config/app_store.example.json](config/app_store.example.json).
La página oficial debe permitir la eliminación real antes del envío a revisión.

```bash
python3 scripts/verificar_app_store.py --source-only
# En un Mac, después de completar configuración y firma:
bash scripts/compilar_app_store.sh config/app_store.json
```
