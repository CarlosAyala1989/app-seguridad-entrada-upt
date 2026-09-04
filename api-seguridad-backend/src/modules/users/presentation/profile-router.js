'use strict';

const express = require('express');

function buildProfileRouter({ getCurrentUserProfile, sessionMiddleware }) {
  const router = express.Router();

  router.get('/me/profile', sessionMiddleware, async (request, response, next) => {
    try {
      const profile = await getCurrentUserProfile.execute(request.session.userId);
      if (!profile) return response.status(204).send();
      return response.status(200).json({ data: profile });
    } catch (error) {
      return next(error);
    }
  });

  return router;
}

module.exports = { buildProfileRouter };
