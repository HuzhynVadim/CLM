local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local iconLoaded = false
local iconName = "CLMIcon"

local dbDefaults = {
	char = {
		minimapIcon = true,
		charTypeIndex = 1,
		nicknameIndex = 1
	}
}

local configTable = {
	type = "group",
	args = {
		minimapIcon = {
			name = "Show minimap icon",
			order = 0,
			desc = "Shows/hides minimap icon",
			type = "toggle",
			set = function(_, val)
				CLM.db.char.minimapIcon = val
				if val == true then
					if iconLoaded == true then
						LDBIcon:Show(iconName)
					else
						CLM:addMapIcon()
					end
				else
					LDBIcon:Hide(iconName)
				end
			end,
			get = function(_)
				return CLM.db.char.minimapIcon
			end
		}
	}
}

local function migrateAddonDB()
	if not CLM.db.char["version"] then
		CLM.db.char.version = 0.4
		CLM.db.char.charTypeIndex = 1
		CLM.db.char.nicknameIndex = 1
	end
end

local configShown = false
function CLM:openConfigDialog()
	if configShown then
		InterfaceOptionsFrame_Show()
	else
		InterfaceOptionsFrame_OpenToCategory(CLM.AceAddonName)
		InterfaceOptionsFrame_OpenToCategory(CLM.AceAddonName)
	end
	configShown = not (configShown)
end

function CLM:addMapIcon()
	if CLM.db.char.minimapIcon then
		iconLoaded = true
		if LDB then
			local PCMinimapBtn =
				LDB:NewDataObject(
				iconName,
				{
					type = "launcher",
					text = iconName,
					icon = "interface/icons/classicon_druid.blp",
					OnClick = function(_, button)
						if button == "LeftButton" then
							CLM:createMainFrame()
						end
						if button == "RightButton" then
							CLM:openConfigDialog()
						end
					end,
					OnTooltipShow = function(tt)
						tt:AddLine(CLM.AddonNameAndVersion)
						tt:AddLine("|cffffff00Left click|r to open the BiS lists window")
						tt:AddLine("|cffffff00Right click|r to open addon configuration window")
					end
				}
			)
			if LDBIcon then
				LDBIcon:Register(iconName, PCMinimapBtn, CLM.db.char)
			end
		end
	end
end

function CLM:initConfig()
	CLM.db = LibStub("AceDB-3.0"):New("CLMDB", dbDefaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(CLM.AceAddonName, configTable)
	AceConfigDialog:AddToBlizOptions(CLM.AceAddonName, CLM.AceAddonName)
	migrateAddonDB()
end
