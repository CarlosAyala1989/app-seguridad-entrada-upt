# Stack: Flutter + Dart → API REST Node.js → MySQL

Característica: Visualizar identidad digital universitaria

  Escenario: La identidad tiene datos
    Dado que el usuario ha iniciado sesión
    Y existe un registro universitario asociado en MySQL
    Cuando Flutter solicita la identidad a la API Node.js
    Entonces ve nombre, fotografía, código, rol, escuela o unidad y estado
    Y no ve datos innecesarios para identificarse

  Escenario: La identidad no tiene datos disponibles
    Dado que el usuario ha iniciado sesión
    Y Node.js no devuelve un registro utilizable
    Cuando abre su identidad digital
    Entonces Flutter muestra información no disponible
    Y una acción de soporte
    Y no se genera una credencial válida

  Escenario: Falla la conexión
    Dado que el dispositivo no tiene conexión
    Cuando abre su identidad digital
    Entonces Flutter indica que no puede confirmar el estado actual
    Y no presenta como vigente una autorización no verificable
    Y ofrece reintentar

  Escenario: Error del servidor
    Dado que la API Node.js responde con error
    Cuando abre su identidad digital
    Entonces Flutter muestra un mensaje comprensible sin detalles técnicos
    Y un botón para reintentar
