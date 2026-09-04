'use strict';

const assert = require('node:assert/strict');
const { afterEach, test } = require('node:test');

const { buildApp } = require('../src/app');
const { InMemoryUserProfileRepository } = require('../src/modules/users/infrastructure/in-memory-user-profile-repository');

const servers = [];
afterEach(() => {
  for (const server of servers.splice(0)) server.close();
});

async function requestProfile({ scenario = 'success', token = 'test-session' } = {}) {
  const app = buildApp({
    environment: {
      nodeEnv: 'test',
      profileScenario: scenario,
      demoSessionToken: 'test-session',
    },
    profileRepository: new InMemoryUserProfileRepository({ scenario }),
  });
  const server = app.listen(0);
  servers.push(server);
  await new Promise((resolve) => server.once('listening', resolve));
  const { port } = server.address();
  return fetch(`http://127.0.0.1:${port}/api/v1/users/me/profile`, {
    headers: token ? { authorization: `Bearer ${token}` } : {},
  });
}

test('devuelve el perfil mínimo con una sesión válida', async () => {
  const response = await requestProfile();
  assert.equal(response.status, 200);
  const payload = await response.json();
  assert.equal(payload.data.verificationStatus, 'VERIFIED');
  assert.equal(payload.data.password, undefined);
});

test('devuelve 204 cuando el perfil no está disponible', async () => {
  const response = await requestProfile({ scenario: 'empty' });
  assert.equal(response.status, 204);
});

test('rechaza una solicitud sin sesión', async () => {
  const response = await requestProfile({ token: '' });
  assert.equal(response.status, 401);
});

test('traduce la caída del proveedor a un error sin datos sensibles', async () => {
  const response = await requestProfile({ scenario: 'error' });
  assert.equal(response.status, 503);
  const payload = await response.json();
  assert.equal(payload.error.code, 'PROFILE_PROVIDER_UNAVAILABLE');
  assert.equal(payload.error.message, 'El servicio no está disponible temporalmente.');
});
