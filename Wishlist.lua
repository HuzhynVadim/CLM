local AceGUI = LibStub("AceGUI-3.0")
local charType
local charTypeIndex
local nickname
local nicknameIndex
local nicknameList
local wishlistFrame
local items = {}
local mainFrame
local typeDropdown
local nicknameDropdown
local checkmarks = {}

local function createLabel(text)
	local color = 1
	local f = AceGUI:Create("Label")
	f:SetText(text)
	f:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "")
	f:SetColor(color, color, color)
	f:SetWidth(175)
	f:SetHeight(33)
	return f
end

local function createItemFrame(item, size, checkmark)
	local itemFrame = AceGUI:Create("Icon")
	itemFrame:SetImageSize(size, size)
	if (item:GetItemID()) then
		item:ContinueOnItemLoad(
				function()
					local itemLink = item:GetItemLink()
					itemFrame:SetImage(item:GetItemIcon())
					if checkmark == true then
						local checkMark = itemFrame.frame:CreateTexture(nil, "OVERLAY")
						checkMark:SetWidth(35)
						checkMark:SetHeight(35)
						checkMark:SetPoint("CENTER", 6, -8)
						checkMark:SetTexture("Interface\\AddOns\\CLM\\checkmark.tga")
						table.insert(checkmarks, checkMark)
					end
					itemFrame:SetCallback(
							"OnClick",
							function(_)
								--SetItemRef(itemLink, itemLink, "LeftButton") todo need to update xlsx table
								print("here")
							end
					)
					itemFrame:SetCallback(
							"OnEnter",
							function(_)
								GameTooltip:SetOwner(itemFrame.frame)
								GameTooltip:SetPoint("TOPRIGHT", itemFrame.frame, "TOPRIGHT", 220, -13)
								GameTooltip:SetHyperlink(itemLink)
							end
					)
					itemFrame:SetCallback(
							"OnLeave",
							function(_)
								GameTooltip:Hide()
							end
					)
				end
		)
	end
	return itemFrame
end

local function createHeaderLabel(text)
	local f = AceGUI:Create("Label")
	f:SetText(text)
	f:SetFont("Fonts\\FRIZQT___CYR.TTF", 14, "")
	f:SetColor(1,0.843137255,0)
	return f
end


local function drawTableHeader()
	wishlistFrame:AddChild(createHeaderLabel("Босс"))
	wishlistFrame:AddChild(createHeaderLabel(" "))
	wishlistFrame:AddChild(createHeaderLabel("Предмет"))
	wishlistFrame:AddChild(createHeaderLabel("Номер"))
end

local function saveData()
	CLM.db.char.charTypeIndex = charTypeIndex
	CLM.db.char.nicknameIndex = nicknameIndex
end

local function clearCheckMarks()
	for _, value in ipairs(checkmarks) do
		value:SetTexture(nil)
	end
	checkmarks = {}
end

local function drawCharData()
	clearCheckMarks()
	saveData()
	items = {}
	wishlistFrame:ReleaseChildren()
	drawTableHeader(wishlistFrame)
	if not charType or not nickname then
		return
	end
	local tempBossName = " "
	local wishlist = CLMWishlists[charType][nickname]
	for index, table in ipairs(wishlist) do
		local itemId = table.itemId
		items[itemId] = Item:CreateFromItemID(itemId)
		local itemName = items[itemId]:GetItemName()
		local bossName = table.boss
		if index == 1 then
			wishlistFrame:AddChild(createLabel(bossName))
			tempBossName = bossName
		else
			if tempBossName == bossName then
				wishlistFrame:AddChild(createLabel(" "))
			else
				wishlistFrame:AddChild(createLabel(bossName))
				tempBossName = bossName
			end
		end
		wishlistFrame:AddChild(createItemFrame(items[itemId], 25, table.marker))
		wishlistFrame:AddChild(createLabel(itemName))
		wishlistFrame:AddChild(createLabel("        " .. table.wishNumber))
	end
end

local function loadData()
	charTypeIndex = CLM.db.char.charTypeIndex
	nicknameIndex = CLM.db.char.nicknameIndex
	if charTypeIndex then
		charType = CLMWishlistsType[charTypeIndex]
	end
	if nicknameIndex then
		nicknameList = CLMNickname[charType]
		nickname = CLMNickname[charType][nicknameIndex]
	end
end

local function drawDropdowns()
	local dropDownGroup = AceGUI:Create("SimpleGroup")
	dropDownGroup:SetLayout("Table")
	dropDownGroup:SetAutoAdjustHeight(false)
	dropDownGroup:SetWidth(228)
	dropDownGroup:SetHeight(48)
	dropDownGroup:SetUserData(
			"table",
			{
				columns = {
					110,
					110
				},
				space = 1,
				align = "CENTER"
			}
	)
	mainFrame:AddChild(dropDownGroup)
	typeDropdown = AceGUI:Create("Dropdown")
	nicknameDropdown = AceGUI:Create("Dropdown")
	nicknameDropdown:SetDisabled(true)
	typeDropdown:SetCallback(
			"OnValueChanged",
			function(_, _, key)
				charTypeIndex = key
				charType = CLMWishlistsType[key]
				nicknameList = CLMNickname[charType]
				nicknameDropdown:SetDisabled(false)
				nicknameDropdown:SetList(nicknameList)
				nicknameDropdown:SetValue(1)
				nickname = nicknameList[1]
				drawCharData()
			end
	)
	nicknameDropdown:SetCallback(
			"OnValueChanged",
			function(_, _, key)
				nicknameIndex = key
				nickname = CLMNickname[charType][nicknameIndex]
				drawCharData()
			end
	)
	typeDropdown:SetList(CLMWishlistsType)
	typeDropdown:SetValue(charTypeIndex)
	if (charTypeIndex) then
		nicknameDropdown:SetList(nicknameList)
		nicknameDropdown:SetDisabled(false)
	end
	nicknameDropdown:SetValue(nicknameIndex)
	dropDownGroup:AddChild(createHeaderLabel("Вишлист"))
	dropDownGroup:AddChild(createHeaderLabel("Ник"))
	dropDownGroup:AddChild(typeDropdown)
	dropDownGroup:AddChild(nicknameDropdown)
end

local function createCharTypeFrame()
	local frame = AceGUI:Create("ScrollFrame")
	frame:SetLayout("Table")
	frame:SetUserData(
			"table",
			{
				columns = {
					{ width = 195 },
					{ width = 25 },
					{ width = 175 },
					{ width = 50 }
				},
				space = 5, align = "CENTER"
			}
	)
	frame:SetFullWidth(true)
	frame:SetHeight(0)
	frame:SetAutoAdjustHeight(false)
	mainFrame:AddChild(frame)
	wishlistFrame = frame
end

function CLM:createMainFrame()
	if mainFrame then
		CLM:closeMainFrame()
		return
	end
	mainFrame = AceGUI:Create("Frame")
	local width = 575
	local height = 750
	mainFrame:SetWidth(width)
	mainFrame:SetHeight(height)
	mainFrame.frame:SetResizeBounds(width, height, width, height)
	mainFrame:SetCallback(
			"OnClose",
			function(widget)
				clearCheckMarks()
				wishlistFrame = nil
				items = {}
				AceGUI:Release(widget)
				mainFrame = nil
			end
	)
	mainFrame:SetLayout("List")
	mainFrame:SetTitle(CLM.AddonNameAndVersion)
	mainFrame:SetStatusText("Dev discord -> Grigoriy#3059")
	drawDropdowns()
	createCharTypeFrame()
	drawCharData()
end

function CLM:closeMainFrame()
	if mainFrame then
		AceGUI:Release(mainFrame)
		typeDropdown = nil
		nicknameDropdown = nil
		return
	end
end

function CLM:initWishlists()
	loadData()
	LibStub("AceConsole-3.0"):RegisterChatCommand(
			"clm",
			function()
				CLM:createMainFrame()
			end,
			persist
	)
end
