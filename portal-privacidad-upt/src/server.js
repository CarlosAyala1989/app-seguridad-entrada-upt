import { createServer } from 'node:http';
import { randomBytes } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { cargarConfiguracion } from './config.js';
import { inicio, privacidad, soporte, eliminacion, fallo, noEncontrada } from './paginas.js';

const publicos = new URL('../public/', import.meta.url);
const patronCookie = /^([a-f0-9-]{36})\.([A-Za-z0-9_-]{43})$/;

export function crearServidor({ config = cargarConfiguracion(), solicitar = fetch } = {}) {
  const nombreCookie = config.produccion ? '__Host-upt-eliminacion' : 'upt-eliminacion';
  const cookie = (valor, borrar = false) => `${nombreCookie}=${valor}; Path=/; HttpOnly; SameSite=Lax; Max-Age=${borrar ? 0 : 600}${config.produccion ? '; Secure' : ''}`;
  const leerCredencial = (req) => {
    const entrada = (req.headers.cookie || '').split(';').map((parte) => parte.trim()).find((parte) => parte.startsWith(`${nombreCookie}=`));
    const coincidencia = entrada?.slice(nombreCookie.length + 1).match(patronCookie);
    return coincidencia ? { id: coincidencia[1], verificador: coincidencia[2] } : null;
  };
  const api = async (operacion, datos) => {
    const respuesta = await solicitar(`${config.api}/cuenta/eliminacion/${operacion}`, {
      method: 'POST', redirect: 'error', signal: AbortSignal.timeout(12_000),
      headers: { 'content-type': 'application/json', accept: 'application/json' }, body: JSON.stringify(datos),
    });
    const contenido = await respuesta.json();
    if (!respuesta.ok) {
      const error = new Error(contenido.error?.mensaje || 'El servicio no está disponible temporalmente.');
      error.estado = respuesta.status;
      throw error;
    }
    if (!contenido.datos) throw new Error('Respuesta del servicio no válida.');
    return contenido.datos;
  };
  const enviar = (res, pagina) => {
    res.writeHead(pagina.estado, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(pagina.html);
  };
  const redirigir = (res, destino, nuevaCookie) => {
    if (nuevaCookie) res.setHeader('Set-Cookie', nuevaCookie);
    res.writeHead(303, { Location: destino });
    res.end();
  };

  const servidor = createServer(async (req, res) => {
    res.setHeader('Content-Security-Policy', "default-src 'none'; style-src 'self'; img-src 'self'; form-action 'self' https://accounts.google.com; base-uri 'none'; frame-ancestors 'none'");
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    if (config.produccion) res.setHeader('Strict-Transport-Security', 'max-age=31536000');
    try {
      const ruta = new URL(req.url, config.origen).pathname;
      if (req.method === 'GET' && ruta === '/salud') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ estado: 'correcto' }));
      }
      if (req.method === 'GET' && ['/assets/styles.css', '/assets/logo-upt.png'].includes(ruta)) {
        const archivo = await readFile(new URL(ruta.slice('/assets/'.length), publicos));
        res.writeHead(200, { 'Content-Type': ruta.endsWith('.css') ? 'text/css; charset=utf-8' : 'image/png', 'Cache-Control': 'public, max-age=86400' });
        return res.end(archivo);
      }
      if (req.method === 'GET' && ruta === '/') return enviar(res, inicio(config));
      if (req.method === 'GET' && ruta === '/privacidad') return enviar(res, privacidad(config));
      if (req.method === 'GET' && ruta === '/soporte') return enviar(res, soporte(config));
      if (req.method === 'GET' && ruta === '/eliminar-cuenta') {
        const credencial = leerCredencial(req);
        let estado;
        let mensaje;
        if (credencial) {
          try { estado = await api('estado', credencial); } catch (error) {
            if (error.estado === 410) res.setHeader('Set-Cookie', cookie('', true));
            mensaje = error.estado && error.estado < 500 ? error.message : 'No pudimos consultar el servicio. Vuelve a cargar esta página antes de iniciar otro proceso.';
          }
        }
        return enviar(res, eliminacion(config, estado, mensaje));
      }
      if (req.method !== 'POST' || !['/acciones/eliminacion/iniciar', '/acciones/eliminacion/confirmar', '/acciones/eliminacion/cancelar'].includes(ruta)) return enviar(res, noEncontrada(config));
      if (req.headers.origin !== config.origen || req.headers['sec-fetch-site'] === 'cross-site') {
        return enviar(res, fallo(config, 'Abre el proceso desde este sitio para continuar de forma segura.', 403));
      }
      if (!req.headers['content-type']?.startsWith('application/x-www-form-urlencoded')) return enviar(res, fallo(config, 'El formato del formulario no es válido.', 415));
      let cuerpo = '';
      for await (const parte of req) {
        cuerpo += parte.toString('utf8');
        if (Buffer.byteLength(cuerpo) > 8192) return enviar(res, fallo(config, 'El formulario supera el tamaño permitido.', 413));
      }
      const datos = new URLSearchParams(cuerpo);
      if (ruta.endsWith('/iniciar')) {
        const verificador = randomBytes(32).toString('base64url');
        const resultado = await api('iniciar', { verificador });
        const autorizacion = new URL(resultado.url_autorizacion);
        if (autorizacion.protocol !== 'https:' || autorizacion.hostname !== 'accounts.google.com' || autorizacion.username || autorizacion.password || (autorizacion.port && autorizacion.port !== '443') || !/^[a-f0-9-]{36}$/.test(resultado.id)) {
          throw new Error('Destino de autorización no válido.');
        }
        return redirigir(res, autorizacion.href, cookie(`${resultado.id}.${verificador}`));
      }
      const credencial = leerCredencial(req);
      if (ruta.endsWith('/cancelar')) {
        if (credencial) await api('cancelar', credencial).catch(() => {});
        return redirigir(res, '/eliminar-cuenta', cookie('', true));
      }
      if (!credencial) return enviar(res, fallo(config, 'La verificación venció. Inicia de nuevo para confirmar tu cuenta.', 410));
      if (datos.get('confirmacion') !== 'ELIMINAR' || datos.get('entiendo') !== 'si') return enviar(res, fallo(config, 'Marca la confirmación y escribe ELIMINAR exactamente.', 400));
      await api('confirmar', { ...credencial, confirmacion: 'ELIMINAR' });
      return redirigir(res, '/eliminar-cuenta');
    } catch (error) {
      // No registrar URL, cookies, cuerpo, correo ni respuestas del proveedor.
      if (error.estado && error.estado < 500) return enviar(res, fallo(config, error.message, error.estado));
      return enviar(res, fallo(config, 'El servicio no está disponible temporalmente. Vuelve a intentarlo.'));
    }
  });
  servidor.requestTimeout = 20_000;
  servidor.headersTimeout = 15_000;
  return servidor;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const config = cargarConfiguracion();
  const servidor = crearServidor({ config });
  servidor.listen(config.puerto, '0.0.0.0', () => console.log(`Portal disponible en el puerto ${config.puerto}`));
  const cerrar = () => { servidor.close(() => process.exit(0)); setTimeout(() => process.exit(1), 10_000).unref(); };
  process.on('SIGTERM', cerrar);
  process.on('SIGINT', cerrar);
}
