CLM = LibStub("AceAddon-3.0"):NewAddon("CLM")

function CLM:OnInitialize()
  CLM.AceAddonName = "ConsulLootMaster"
  CLM.AddonNameAndVersion = "ConsulLootMaster 0.0.4"
  CLM:initConfig()
  CLM:addMapIcon()
  CLM:initWishlists()
  CLM:initBisTooltip()
end