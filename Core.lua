CLM = LibStub("AceAddon-3.0"):NewAddon("CLM")

local function checkTable(table)
	return rawequal(next(table), nil)
end

function CLM:OnInitialize()
	CLM.AceAddonName = "ConsulLootMaster"
	CLM.AddonNameAndVersion = "ConsulLootMaster 0.0.4"
	if not checkTable(CLMNickname) and not checkTable(CLMWishlists) then
		CLM:initConfig()
		CLM:addMapIcon()
		CLM:initWishlists()
	end
	if not checkTable(CLMItems) then
		CLM:initBisTooltip()
	end
end