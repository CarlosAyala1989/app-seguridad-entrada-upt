export function cargarConfiguracion(env = process.env) {
  const produccion = env.NODE_ENV === 'production';
  const puerto = Number(env.PORT || 3000);
  if (!Number.isInteger(puerto) || puerto < 1 || puerto > 65535) throw new Error('PORT no es válido.');
  if (produccion && !env.SITIO_PUBLICO_URL) throw new Error('Configura SITIO_PUBLICO_URL con el dominio HTTPS del portal.');
  if (produccion && !env.API_BASE_URL) throw new Error('Configura API_BASE_URL con la URL de la API, terminada en /api.');
  const publica = new URL(env.SITIO_PUBLICO_URL || `http://127.0.0.1:${puerto}`);
  const api = new URL(env.API_BASE_URL || 'http://127.0.0.1:3199/api');
  if (publica.username || publica.password || publica.search || publica.hash || publica.pathname !== '/') throw new Error('SITIO_PUBLICO_URL debe contener solamente el origen del sitio.');
  if (produccion && publica.protocol !== 'https:') throw new Error('El portal público requiere HTTPS en producción.');
  if (!['https:', 'http:'].includes(api.protocol) || api.username || api.password || api.search || api.hash) throw new Error('API_BASE_URL no es válida.');
  const correo = env.SOPORTE_CORREO || 'ca2022074266@virtual.upt.pe';
  if (!/^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$/.test(correo)) throw new Error('SOPORTE_CORREO no es válido.');
  return Object.freeze({
    puerto, produccion, origen: publica.origin, api: api.href.replace(/\/$/, ''),
    responsable: env.RESPONSABLE_NOMBRE || 'Carlos Daniel Ayala Ramos',
    correo,
    alojamiento: env.ALOJAMIENTO_DESCRIPCION || 'Infraestructura administrada por el responsable del servicio mediante Dokploy.',
    // El plazo acordado también se aplica en la tarea de depuración de la API.
    retencionDias: 30,
  });
}
