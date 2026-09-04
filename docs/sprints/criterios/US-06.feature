# Stack: Flutter + Dart → API REST Node.js → MySQL

Característica: Capturar ubicación para emitir la credencial

  Escenario: Ubicación disponible dentro de la zona
    Dado que el usuario otorgó permiso de ubicación
    Y Flutter obtiene latitud, longitud, precisión y timestamp recientes
    Cuando solicita generar su credencial
    Entonces Flutter envía las coordenadas a Node.js
    Y Node.js determina si pertenecen a una zona permitida almacenada en MySQL
    Y conserva la marca de tiempo y precisión asociadas a la solicitud

  Escenario: Permiso de ubicación denegado
    Dado que el usuario denegó el permiso de ubicación
    Cuando intenta generar la credencial
    Entonces Flutter no genera un QR válido
    Y explica por qué se requiere la ubicación
    Y ofrece abrir la configuración de permisos

  Escenario: Sin ubicación o sin conexión
    Dado que Flutter no puede obtener una ubicación reciente o enviarla a Node.js
    Cuando el usuario solicita generar el QR
    Entonces el sistema no confirma la emisión
    Y ofrece reintentar

  Escenario: Error de validación geográfica
    Dado que Node.js no puede validar la geocerca o MySQL no responde
    Cuando se evalúan las coordenadas
    Entonces el sistema no asume que el usuario está dentro de la zona
    Y Flutter muestra un mensaje comprensible
