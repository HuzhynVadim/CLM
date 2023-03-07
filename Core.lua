CLM = LibStub("AceAddon-3.0"):NewAddon("CLM")

function CLM:OnInitialize()
	CLM.AceAddonName = "ConsulLootMaster"
	CLM.Version = 1.0
	CLM.AddonNameAndVersion = "ConsulLootMaster 1.0"
	if not CLM:checkTable(CLMWishlistsType) and not CLM:checkTable(CLMNickname) and not CLM:checkTable(CLMWishlists) then
		CLM:initConfig()
		CLM:addMapIcon()
		CLM:initWishlists()
	end
	if not CLM:checkTable(CLMItems) then
		CLM:initBisTooltip()
	end
end
