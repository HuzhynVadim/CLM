CLM = LibStub("AceAddon-3.0"):NewAddon("CLM")

function CLM:OnInitialize()
	CLM.AceAddonName = "ConsulLootMaster"
	CLM.AddonNameAndVersion = "ConsulLootMaster 0.0.4"
	CLM:initConfig()
	CLM:addMapIcon()
	if not #CLMWishlistsType == 0 and not #CLMNickname == 0 and not #CLMWishlists == 0 then
		CLM:initWishlists()
	end
	if not #CLMItems == 0 then
		CLM:initBisTooltip()
	end
end