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
Las URL de privacidad, soporte y eliminación de `https://ingreso-upt.fottuto.men`
ya están incorporadas en la app y en
[config/app_store.json](config/app_store.json). Este archivo contiene solo
direcciones públicas y se incluye en Git; no añadir secretos ni credenciales.
Antes del envío a revisión hay que completar la configuración de eliminación
en la API desplegada y verificar el proceso real.

```bash
python3 scripts/verificar_app_store.py
# En un Mac, después de completar los pendientes externos y la firma:
bash scripts/compilar_app_store.sh config/app_store.json
```
