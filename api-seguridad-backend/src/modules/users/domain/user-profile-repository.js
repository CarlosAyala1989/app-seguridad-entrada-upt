'use strict';

class UserProfileRepository {
  async findByUserId(_userId) {
    throw new Error('findByUserId debe ser implementado por un adaptador.');
  }
}

module.exports = { UserProfileRepository };
