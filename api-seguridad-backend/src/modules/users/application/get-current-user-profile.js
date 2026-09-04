'use strict';

class GetCurrentUserProfile {
  constructor(userProfileRepository) {
    this.userProfileRepository = userProfileRepository;
  }

  async execute(userId) {
    return this.userProfileRepository.findByUserId(userId);
  }
}

module.exports = { GetCurrentUserProfile };
