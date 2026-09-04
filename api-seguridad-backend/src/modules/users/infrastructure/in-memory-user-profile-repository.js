'use strict';

const { UserProfile } = require('../domain/user-profile');
const { UserProfileRepository } = require('../domain/user-profile-repository');

class InMemoryUserProfileRepository extends UserProfileRepository {
  constructor({ scenario = 'success' } = {}) {
    super();
    this.scenario = scenario;
  }

  async findByUserId(_userId) {
    if (this.scenario === 'empty') return null;
    if (this.scenario === 'error') {
      const error = new Error('Falla simulada del proveedor de perfiles.');
      error.code = 'PROFILE_PROVIDER_UNAVAILABLE';
      error.statusCode = 503;
      throw error;
    }

    return new UserProfile({
      fullName: 'Estudiante de Demostración',
      institutionalCode: '2022000000',
      institutionalEmail: '2022000000@virtual.upt.pe',
      role: 'STUDENT',
      school: 'Ingeniería de Sistemas',
      verificationStatus: 'VERIFIED',
      accessStatus: 'ACTIVE',
    });
  }
}

module.exports = { InMemoryUserProfileRepository };
