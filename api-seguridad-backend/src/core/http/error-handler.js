'use strict';

function errorHandler(error, _request, response, _next) {
  const status = Number(error.statusCode) || 500;
  const message = status >= 500
    ? 'El servicio no está disponible temporalmente.'
    : error.message;

  response.status(status).json({
    error: {
      code: error.code || 'INTERNAL_ERROR',
      message,
    },
  });
}

module.exports = { errorHandler };
