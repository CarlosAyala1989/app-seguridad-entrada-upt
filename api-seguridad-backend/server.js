'use strict';

require('dotenv').config();

const { buildApp } = require('./src/app');
const { readEnvironment } = require('./src/config/environment');

const environment = readEnvironment();
const app = buildApp({ environment });

app.listen(environment.port, () => {
  console.log(`API de IngresoUPT disponible en el puerto ${environment.port}`);
});
