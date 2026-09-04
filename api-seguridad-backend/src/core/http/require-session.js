'use strict';

const { timingSafeEqual } = require('node:crypto');

function requireSession(expectedToken) {
  return function sessionMiddleware(request, response, next) {
    if (!expectedToken) {
      return response.status(503).json({
        error: {
          code: 'DEMO_SESSION_NOT_CONFIGURED',
          message: 'La sesión de demostración no está configurada.',
        },
      });
    }

    const header = request.get('authorization') || '';
    const receivedToken = header.startsWith('Bearer ') ? header.slice(7) : '';
    const expectedBuffer = Buffer.from(expectedToken);
    const receivedBuffer = Buffer.from(receivedToken);
    const isValid = expectedBuffer.length === receivedBuffer.length
      && timingSafeEqual(expectedBuffer, receivedBuffer);

    if (!isValid) {
      return response.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'La sesión no es válida.',
        },
      });
    }

    request.session = { userId: 1 };
    return next();
  };
}

module.exports = { requireSession };
