'use strict';

class UserProfile {
  constructor({
    fullName,
    institutionalCode,
    institutionalEmail,
    role,
    school,
    verificationStatus,
    accessStatus,
    photoUrl = null,
  }) {
    this.fullName = fullName;
    this.institutionalCode = institutionalCode;
    this.institutionalEmail = institutionalEmail;
    this.role = role;
    this.school = school;
    this.verificationStatus = verificationStatus;
    this.accessStatus = accessStatus;
    this.photoUrl = photoUrl;
    Object.freeze(this);
  }
}

module.exports = { UserProfile };
