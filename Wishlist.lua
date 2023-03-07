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

local function addCheckmark(checkMark, itemFrame, texture)
	checkMark = itemFrame.frame:CreateTexture(nil, "OVERLAY")
	checkMark:SetWidth(35)
	checkMark:SetHeight(35)
	checkMark:SetPoint("CENTER", 6, -8)
	checkMark:SetTexture(texture)
	table.insert(checkmarks, checkMark)
	return checkMark
end

local function tableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

local function getCheckMarkTemp(marker)
	local checkMarkTemp
	if marker == true then
		checkMarkTemp = false
	else
		checkMarkTemp = true
	end
	return checkMarkTemp
end

local function createItemFrame(itemIcon, itemLink, size, marker, wishNumber, itemId)
	local checkMark
	local itemFrame = AceGUI:Create("Icon")
	itemFrame:SetImageSize(size, size)
	itemFrame:SetImage(itemIcon)
	local checkMarkTexture = "Interface\\AddOns\\CLM\\checkmark.tga"
	local checkMarkTemp = getCheckMarkTemp(marker)
	if CLMUD[charType] and CLMUD[charType][nickname] and CLMUD[charType][nickname][wishNumber] then
		marker = CLMUD[charType][nickname][wishNumber]["marker"]
		checkMarkTexture = "Interface\\AddOns\\CLM\\checkmarkTemp.tga"
	end
	if marker == true then
		checkMark = addCheckmark(checkMark, itemFrame, checkMarkTexture)
	end
	itemFrame:SetCallback(
		"OnClick",
		function()
			if checkMarkTemp == true then
				if marker == true then
					marker = false
				else
					marker = true
				end
				if not CLMUD[charType] then
					CLMUD[charType] = {}
				end
				if not CLMUD[charType][nickname] then
					CLMUD[charType][nickname] = {}
				end
				if not CLMUD[charType][nickname][wishNumber] then
					CLMUD[charType][nickname][wishNumber] = {
						["itemId"] = itemId,
						["marker"] = marker
					}
				end
				if marker == true then
					checkMark = addCheckmark(checkMark, itemFrame, "Interface\\AddOns\\CLM\\checkmarkTemp.tga")
				else
					if tableLength(CLMUD[charType][nickname]) == 1 then
						CLMUD[charType][nickname] = nil
					else
						CLMUD[charType][nickname][wishNumber] = nil
					end
					checkMark:SetTexture(nil)
					if tableLength(CLMUD[charType]) == 0 then
						CLMUD[charType] = nil
					end
				end
			end
		end
	)
	itemFrame:SetCallback(
		"OnEnter",
		function()
			GameTooltip:SetOwner(itemFrame.frame)
			GameTooltip:SetPoint("TOPRIGHT", itemFrame.frame, "TOPRIGHT", 220, -13)
			GameTooltip:SetHyperlink(itemLink)
		end
	)
	itemFrame:SetCallback(
		"OnLeave",
		function()
			GameTooltip:Hide()
		end
	)
	return itemFrame
end

local function createHeaderLabel(text)
	local f = AceGUI:Create("Label")
	f:SetText(text)
	f:SetFont("Fonts\\FRIZQT___CYR.TTF", 14, "")
	f:SetColor(1, 0.843137255, 0)
	return f
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
	if not charType or not nickname then
		return
	end
	local tempBossName = " "
	local wishlist = CLMWishlists[charType][nickname]
	for index, table in ipairs(wishlist) do
		local bossName = table.bossName
		local wishNumber = table.wishNumber
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
		wishlistFrame:AddChild(createItemFrame(table.itemIcon, table.itemLink, 25, table.marker, wishNumber, table.itemId))
		wishlistFrame:AddChild(createLabel(table.itemName))
		wishlistFrame:AddChild(createLabel("        " .. wishNumber))
	end
end

local function loadData()
	charTypeIndex = CLM.db.char.charTypeIndex
	nicknameIndex = CLM.db.char.nicknameIndex
	if CLM.db.char.update then
		DEFAULT_CHAT_FRAME:AddMessage("here")
		CLM.db.char.update = false
	end
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
	dropDownGroup:SetFullWidth(true)
	dropDownGroup:SetUserData(
		"table",
		{
			columns = {
				110,
				120,
				150,
				200
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

	local btn = AceGUI:Create("Button")
	btn:SetWidth(100)
	btn:SetText("Сохранить")
	btn:SetCallback(
		"OnClick",
		function()
			CLM.db.char.update = true
			C_UI.Reload()
		end
	)

	dropDownGroup:AddChild(createHeaderLabel("      " .. "Вишлист"))
	dropDownGroup:AddChild(createHeaderLabel("          " .. "Ник"))
	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(createHeaderLabel(" "))

	dropDownGroup:AddChild(typeDropdown)
	dropDownGroup:AddChild(nicknameDropdown)
	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(btn)

	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(createHeaderLabel(" "))

	dropDownGroup:AddChild(createHeaderLabel("                  " .. "Босс"))
	dropDownGroup:AddChild(createHeaderLabel(" "))
	dropDownGroup:AddChild(createHeaderLabel("       " .. "Предмет"))
	dropDownGroup:AddChild(createHeaderLabel("           " .. "Приоритет"))

	dropDownGroup:AddChild(createHeaderLabel(" "))
end

local function createCharTypeFrame()
	local frame = AceGUI:Create("ScrollFrame")
	frame:SetLayout("Table")
	frame:SetUserData(
		"table",
		{
			columns = {
				{width = 195},
				{width = 25},
				{width = 175},
				{width = 50}
			},
			space = 5,
			align = "CENTER"
		}
	)
	frame:SetFullWidth(true)
	frame:SetHeight(590)
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
	_G["clmMainFrame"] = mainFrame.frame
	table.insert(UISpecialFrames, "clmMainFrame")
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

function CLM:checkTable(table)
	return rawequal(next(table), nil)
end
