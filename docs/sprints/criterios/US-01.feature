# Stack: Flutter + Dart -> API REST Node.js -> MySQL

Característica: Inicio de sesión con correo institucional e intranet

  Escenario: Autenticación válida
    Dado que el usuario posee un correo institucional registrado
    Y existe un registro universitario asociado
    Cuando valida su identidad mediante la intranet o SSO definido
    Entonces Node.js crea una sesión asociada únicamente a ese registro
    Y Flutter permite acceder a la identidad digital
    Y la contraseña institucional no se almacena en texto plano

  Escenario: Cuenta no registrada
    Dado que el correo no corresponde a un registro habilitado
    Cuando el usuario intenta iniciar sesión
    Entonces el sistema rechaza el acceso
    Y no revela información sobre otros registros

  Escenario: Credenciales inválidas o sin conexión
    Dado que existe un registro institucional
    Cuando la autenticación falla o el dispositivo no puede comunicarse con el servicio
    Entonces no se crea una sesión
    Y Flutter permite volver a intentar

  Escenario: Error del servidor
    Dado que la intranet, SSO o API Node.js no responde correctamente
    Cuando el usuario intenta iniciar sesión
    Entonces no se crea una sesión parcial
    Y Flutter muestra un mensaje comprensible con opción de reintento
