# Stack: Flutter + Dart → API REST Node.js → MySQL

Característica: Escanear credencial QR en el punto de acceso

  Escenario: QR legible y validable
    Dado que el personal de seguridad posee rol de validador
    Y la cámara está disponible en Flutter
    Cuando escanea un QR con formato válido
    Entonces Flutter trata su contenido como token opaco
    Y envía el token a Node.js
    Y Node.js consulta MySQL y devuelve un resultado permitido o denegado
    Y el token completo no se muestra en logs

  Escenario: QR ilegible o vacío
    Dado que el escáner está abierto
    Cuando la cámara no reconoce una credencial válida
    Entonces no se registra un ingreso
    Y Flutter mantiene disponible el escáner

  Escenario: Sin conexión
    Dado que el validador no tiene conexión
    Cuando intenta validar el token
    Entonces Flutter no confirma el acceso como permitido
    Y ofrece reintentar

  Escenario: Error del servidor
    Dado que Node.js o MySQL devuelve un error
    Cuando se envía el token
    Entonces no se registra un acceso permitido
    Y Flutter muestra un mensaje comprensible
