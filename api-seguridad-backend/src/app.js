'use strict';

const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');

const { readEnvironment } = require('./config/environment');
const { errorHandler } = require('./core/http/error-handler');
const { requireSession } = require('./core/http/require-session');
const { GetCurrentUserProfile } = require('./modules/users/application/get-current-user-profile');
const { InMemoryUserProfileRepository } = require('./modules/users/infrastructure/in-memory-user-profile-repository');
const { buildProfileRouter } = require('./modules/users/presentation/profile-router');

function buildApp({ environment = readEnvironment(), profileRepository } = {}) {
  const app = express();
  const repository = profileRepository || new InMemoryUserProfileRepository({
    scenario: environment.profileScenario,
  });
  const getCurrentUserProfile = new GetCurrentUserProfile(repository);

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: '32kb' }));
  if (environment.nodeEnv !== 'test') app.use(morgan('combined'));

  app.get('/health', (_request, response) => {
    response.status(200).json({ status: 'ok' });
  });

  app.use('/api/v1/users', buildProfileRouter({
    getCurrentUserProfile,
    sessionMiddleware: requireSession(environment.demoSessionToken),
  }));

  app.use((_request, response) => {
    response.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Ruta no encontrada.' },
    });
  });
  app.use(errorHandler);

  return app;
}

module.exports = { buildApp };
