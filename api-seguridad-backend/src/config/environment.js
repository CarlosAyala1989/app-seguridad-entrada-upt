'use strict';

function readEnvironment(env = process.env) {
  return Object.freeze({
    nodeEnv: env.NODE_ENV || 'development',
    port: Number(env.PORT) || 3000,
    profileProvider: env.PROFILE_PROVIDER || 'memory',
    profileScenario: env.PROFILE_SCENARIO || 'success',
    demoSessionToken: env.DEMO_SESSION_TOKEN || '',
  });
}

module.exports = { readEnvironment };
