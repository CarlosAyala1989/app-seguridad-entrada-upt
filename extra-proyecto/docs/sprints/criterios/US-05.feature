# Stack: Flutter + Dart → API REST Node.js → MySQL

Característica: Generar QR dinámico con OTP/nonce y ubicación

  Escenario: Se genera una credencial vigente
    Dado que el usuario ha iniciado sesión
    Y su estado permite el ingreso
    Y Flutter obtiene una ubicación reciente dentro de la política permitida
    Cuando solicita generar su credencial a Node.js
    Entonces Node.js crea un OTP o nonce de un solo uso
    Y emite un token opaco de corta vigencia asociado en MySQL a identidad y coordenadas
    Y Flutter representa únicamente el token como QR
    Y el QR no contiene correo, nombre, OTP ni coordenadas en texto legible

  Escenario: No existe autorización o ubicación utilizable
    Dado que no existe una condición válida para emitir la credencial
    Cuando el usuario solicita generar el QR
    Entonces Node.js no genera una credencial válida
    Y Flutter muestra una causa general y una acción sugerida

  Escenario: Falla la conexión
    Dado que el dispositivo no tiene conexión
    Cuando solicita un nuevo QR
    Entonces Flutter no inventa ni extiende la vigencia de un token
    Y ofrece reintentar

  Escenario: Error del servidor
    Dado que la API Node.js responde con error
    Cuando solicita el QR
    Entonces Flutter no muestra un QR como válido
    Y presenta un mensaje comprensible
    Y permite reintentar
