# IngresoUPT

Sistema de identidad digital y control de acceso para la Universidad Privada de Tacna.

## Stack

- **Flutter + Dart** — aplicación móvil.
- **Node.js** — API REST y lógica de negocio.
- **MySQL** — persistencia.
- Arquitectura: **Flutter → HTTPS/REST → Node.js → MySQL**.

## Seguridad de acceso

El usuario se autentica mediante correo institucional e intranet/SSO. La credencial QR utiliza un token opaco de corta vigencia asociado en el backend con OTP/nonce, ubicación y estado de autorización; el QR no expone esos datos en texto legible.

## Equipo

- Carlos Ayala Ramos — 2022074266
- Maria del Rosario Delgado — 2026087688
- Jefferson Rosas Chambilla — 2021072618

## Taller 03

Los artefactos de Product Goal, Product Backlog, refinamiento, estimación y Sprint 1 Planning se encuentran bajo `docs/` y `scripts/`.
