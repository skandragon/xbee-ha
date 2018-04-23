require_relative './profile_zdo'
require_relative './profile_ha'

class Prrofiles
  PROFILE_ZDO = 0x0000
  PROFILE_IPM = 0x0101
  PROFILE_HA = 0x0104
  PROFILE_CBA = 0x0105
  PROFILE_TA = 0x0107
  PROFILE_PHHC = 0x0108
  PROFILE_AMI = 0x0109

  PROFILES = {
      PROFILE_ZDO: { name: "ZDO", id: PROFILE_ZDO, klass: ProfileZDO },
      PROFILE_IPM: { name: "IPM", id: PROFILE_IPM },
      PROFILE_HA: { name: "HA", id: PROFILE_HA, klass: ProfileHA },
      PROFILE_CBA: { name: "CBA", id: PROFILE_CBA },
      PROFILE_TA: { name: "TA", id: PROFILE_TA },
      PROFILE_PHHC: { name: "PHHC", id: PROFILE_PHHC },
      PROFILE_AMI: { name: "AMI", id: PROFILE_AMI },
  }
end