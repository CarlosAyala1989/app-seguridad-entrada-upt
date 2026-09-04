# IngresoUPT

Sistema de identidad digital y control de acceso para la Universidad Privada de Tacna.

## Arquitectura obligatoria

```text
Flutter → HTTPS/REST → Node.js → MySQL
```

La aplicación móvil nunca se conecta directamente a MySQL. El backend concentra autenticación institucional e intranet, sesiones, roles, geocerca, OTP/nonce, credenciales QR temporales, prevención de reutilización y auditoría. La contraseña y el CAPTCHA de la intranet no se persisten.

## Taller 02 · funcionalidad vertical

Se implementó la consulta del perfil de identidad digital mediante MVVM + repositorio y dominio ligero:

- Entidad y contrato en `domain/`.
- DTO, mapeador, fuente remota y repositorio concreto en `data/`.
- Estados, ViewModel sin dependencia de Flutter y vista en `presentation/`.
- Estados de carga, datos, vacío y error con reintento.
- API Node.js protegida por una sesión de demostración configurable.
- Tres pruebas unitarias del ViewModel ejecutables sin emulador.

## Configuración local del incremento

### Backend

```bash
cd api-seguridad-backend
cp .env.example .env
# Definir DEMO_SESSION_TOKEN con un valor temporal solo para desarrollo.
npm ci
npm test
npm start
```

El adaptador `memory` es exclusivo del taller. `PROFILE_SCENARIO` acepta `success`, `empty` o `error` para demostrar los cuatro estados sin usar información personal real.

### Flutter

```bash
cd aplicacion_estudiante
flutter pub get
flutter analyze
flutter test --coverage
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=DEMO_SESSION_TOKEN=<mismo-valor-local>
```

En producción, `DevelopmentSessionTokenProvider` debe sustituirse por un adaptador de almacenamiento seguro; no se debe compilar un token real dentro de la aplicación.

## Documentación del taller

- Decisiones: `docs/decisiones/`
- Arquitectura: `docs/arquitectura/`
- Definition of Done: `docs/equipo/DEFINITION_OF_DONE.md`
- Evidencias: `docs/evidencias/S02/`
- Pruebas de humo: `spikes/`

## Equipo

- Carlos Ayala Ramos — 2022074266 — `CarlosAyala1989`
- María del Rosario Delgado — 2026087688 — `rosario-code`
- Jefferson Rosas Chambilla — 2021072618 — `Ankluna72`
