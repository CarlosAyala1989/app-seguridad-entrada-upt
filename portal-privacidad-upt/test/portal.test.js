import assert from 'node:assert/strict';
import { after, before, describe, it } from 'node:test';
import { crearServidor } from '../src/server.js';
import { cargarConfiguracion } from '../src/config.js';

const config = cargarConfiguracion({ NODE_ENV: 'production', SITIO_PUBLICO_URL: 'https://portal.upt.test', API_BASE_URL: 'https://api.upt.test/api' });
let estado = 'PENDIENTE';
let falloApi = false;
let destinoGoogle = 'https://accounts.google.com/o/oauth2/v2/auth?state=publico';
let credencial;
const llamadas = [];
const id = 'b35ea0f5-764f-4f20-8de1-09d0db9eb644';
const servidor = crearServidor({ config, solicitar: async (url, opciones) => {
  llamadas.push(url);
  assert.equal(opciones.redirect, 'error');
  const datos = JSON.parse(opciones.body);
  if (falloApi) return Response.json({ error: { mensaje: 'Fallo de prueba' } }, { status: 503 });
  if (url.endsWith('/iniciar')) {
    assert.match(datos.verificador, /^[A-Za-z0-9_-]{43}$/);
    credencial = { id, verificador: datos.verificador };
    return Response.json({ datos: { id, url_autorizacion: destinoGoogle } });
  }
  assert.equal(datos.id, credencial.id);
  assert.equal(datos.verificador, credencial.verificador);
  if (url.endsWith('/confirmar')) { assert.equal(datos.confirmacion, 'ELIMINAR'); estado = 'COMPLETADA'; }
  if (url.endsWith('/cancelar')) estado = 'PENDIENTE';
  return Response.json({ datos: { estado, ...(estado === 'LISTA' ? { cuenta: { nombre: '<script>alert(1)</script>', correo: 'prueba@virtual.upt.pe' } } : {}) } });
} });
let base;
before(async () => {
  await new Promise((resolve) => servidor.listen(0, '127.0.0.1', resolve));
  base = `http://127.0.0.1:${servidor.address().port}`;
});
after(async () => { servidor.closeAllConnections(); await new Promise((resolve) => servidor.close(resolve)); });
const post = (ruta, cookie, cuerpo = '', origen = config.origen, cabeceras = {}) => fetch(`${base}${ruta}`, { method: 'POST', redirect: 'manual', headers: { ...(origen === null ? {} : { origin: origen }), 'content-type': 'application/x-www-form-urlencoded', ...(cookie ? { cookie } : {}), ...cabeceras }, body: cuerpo });

describe('Portal público y confirmación de eliminación', () => {
  it('sirve las tres páginas sin autenticación y con el responsable y plazo acordados', async () => {
    for (const ruta of ['/', '/privacidad', '/soporte', '/eliminar-cuenta']) {
      const res = await fetch(`${base}${ruta}`);
      assert.equal(res.status, 200);
      assert.equal(res.headers.get('cache-control'), 'no-store, no-transform');
      // no-referrer convierte Origin en null al enviar formularios HTML.
      assert.equal(res.headers.get('referrer-policy'), 'same-origin');
      assert.ok(res.headers.get('content-security-policy').includes("form-action 'self'"));
      const html = await res.text();
      assert.ok(html.includes('Carlos Daniel Ayala Ramos'));
      assert.ok(html.includes('ca2022074266@virtual.upt.pe'));
      assert.ok(!html.includes('<script'));
      if (ruta === '/privacidad') assert.ok(html.includes('30 días'));
    }
    assert.equal((await fetch(`${base}/no-existe`)).status, 404);
    assert.equal((await fetch(`${base}/assets/styles.css`)).status, 200);
    assert.equal((await fetch(`${base}/assets/logo-upt.png`)).status, 200);
  });

  it('rechaza peticiones de otro origen y no inicia una verificación al hacer GET', async () => {
    const total = llamadas.length;
    for (const origen of ['https://ajeno.test', 'https://portal.upt.test.ajeno.test', 'null', null]) {
      assert.equal((await post('/acciones/eliminacion/iniciar', null, '', origen)).status, 403);
    }
    assert.equal((await post('/acciones/eliminacion/iniciar', null, '', config.origen, { 'sec-fetch-site': 'cross-site' })).status, 403);
    assert.equal((await fetch(`${base}/acciones/eliminacion/confirmar`)).status, 404);
    assert.equal(llamadas.length, total);
  });

  it('usa cookie HttpOnly Secure; el borrado solo ocurre tras verificar y confirmar exactamente', async () => {
    const res = await post('/acciones/eliminacion/iniciar');
    assert.equal(res.status, 303);
    assert.ok(res.headers.get('location').startsWith('https://accounts.google.com/'));
    const setCookie = res.headers.get('set-cookie');
    assert.match(setCookie, /^__Host-upt-eliminacion=/);
    assert.match(setCookie, /HttpOnly/);
    assert.match(setCookie, /Secure/);
    assert.match(setCookie, /SameSite=Lax/);
    const cookie = setCookie.split(';')[0];
    estado = 'LISTA';
    const lista = await fetch(`${base}/eliminar-cuenta`, { headers: { cookie } });
    const html = await lista.text();
    assert.ok(html.includes('&lt;script&gt;'));
    assert.ok(!html.includes(credencial.verificador));
    assert.ok(!html.includes(credencial.id));
    assert.equal((await post('/acciones/eliminacion/confirmar', cookie, 'entiendo=si&confirmacion=eliminar')).status, 400);
    assert.equal(estado, 'LISTA');
    assert.equal((await post('/acciones/eliminacion/confirmar', cookie, 'entiendo=si&confirmacion=ELIMINAR')).status, 303);
    const fin = await fetch(`${base}/eliminar-cuenta`, { headers: { cookie } });
    const resultado = await fin.text();
    assert.ok(resultado.includes('Cuenta eliminada'));
    assert.ok(!resultado.includes('prueba@virtual.upt.pe'));
  });

  it('la caída de la API no impide leer privacidad y nunca muestra un borrado exitoso', async () => {
    falloApi = true;
    assert.equal((await fetch(`${base}/privacidad`)).status, 200);
    const fallida = await post('/acciones/eliminacion/iniciar');
    assert.equal(fallida.status, 503);
    assert.ok(!(await fallida.text()).includes('<h1>Cuenta eliminada'));
    falloApi = false;
  });

  it('configuración de producción exige URLs y HTTPS público', () => {
    assert.throws(() => cargarConfiguracion({ NODE_ENV: 'production' }), /SITIO_PUBLICO_URL/);
    assert.throws(() => cargarConfiguracion({ NODE_ENV: 'production', SITIO_PUBLICO_URL: 'http://portal.test', API_BASE_URL: 'https://api.test/api' }), /HTTPS/);
    assert.throws(() => cargarConfiguracion({ SOPORTE_CORREO: '<script>' }), /SOPORTE_CORREO/);
  });

  it('no sigue un destino de autorización ajeno ni crea su cookie', async () => {
    destinoGoogle = 'https://otro-proveedor.test/identidad';
    const res = await post('/acciones/eliminacion/iniciar');
    assert.equal(res.status, 503);
    assert.equal(res.headers.get('location'), null);
    assert.equal(res.headers.get('set-cookie'), null);
    destinoGoogle = 'https://accounts.google.com/o/oauth2/v2/auth?state=publico';
  });
});
