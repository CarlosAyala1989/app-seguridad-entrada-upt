# Arquitectura del incremento · Perfil de identidad digital

## Contexto del sistema

```mermaid
flowchart TD
    F["Flutter · MVVM"] -->|"HTTPS/REST + sesión"| N["Node.js · API"]
    N -->|"repositorio"| M[("MySQL")]
    N -->|"adaptador aislado"| I["Identidad e intranet UPT"]
    N --> A["Auditoría"]
```

Flutter no conoce credenciales de MySQL ni la automatización de intranet. Las decisiones de seguridad se ejecutan en Node.js.

## Dependencias de la funcionalidad vertical

```mermaid
flowchart TD
    V["Vista"] --> VM["ViewModel"]
    VM --> R["Interfaz de repositorio · dominio"]
    RI["Repositorio · datos"] --> R
    RI --> DS["Fuente remota"]
    DS --> API["API Node.js"]
    DTO["PerfilDigitalDto"] --> MAP["Mapeador"]
    MAP --> E["PerfilDigital · entidad"]
    DS --> DTO
```

La capa de dominio no importa datos ni presentación. El DTO y la entidad son tipos distintos. El ensamblaje se realiza en `core/di/app_dependencies.dart`.

## Secuencia de consulta

```mermaid
sequenceDiagram
    participant UI as Vista Flutter
    participant VM as ViewModel
    participant RP as Repositorio
    participant API as Node.js
    UI->>VM: cargar()
    VM-->>UI: Loading
    VM->>RP: obtenerPerfilActual()
    RP->>API: GET /api/v1/users/me/profile
    alt perfil disponible
        API-->>RP: 200 + DTO mínimo
        RP-->>VM: PerfilDigital
        VM-->>UI: Data
    else sin perfil
        API-->>RP: 204
        VM-->>UI: Empty
    else sesión o servicio inválido
        API-->>RP: 401/5xx
        VM-->>UI: Error + reintento
    end
```
