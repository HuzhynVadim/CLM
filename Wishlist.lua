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

local function createItemFrame(itemId, size, checkmark)
	local itemFrame = AceGUI:Create("Icon")
	itemFrame:SetImageSize(size, size)
	items[itemId] = Item:CreateFromItemID(itemId)
	if (items[itemId]:GetItemID()) then
		items[itemId]:ContinueOnItemLoad(
				function()
					local itemLink = items[itemId]:GetItemLink()
					itemFrame:SetImage(items[itemId]:GetItemIcon())
					if checkmark == true then
						local checkMark = itemFrame.frame:CreateTexture(nil, "OVERLAY")
						checkMark:SetWidth(25)
						checkMark:SetHeight(25)
						checkMark:SetPoint("CENTER", 6, -8)
						checkMark:SetTexture("Interface\\AddOns\\CLM\\\checkmark-16.tga")
						table.insert(checkmarks, checkMark)
					end
					itemFrame:SetCallback(
							"OnClick",
							function(_)
								SetItemRef(itemLink, itemLink, "LeftButton")
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

local function createLabel(text)
	local color = 0.6
	local f = AceGUI:Create("Label")
	f:SetText(text)
	f:SetFont("Fonts\\FRIZQT___CYR.TTF", 14, "")
	f:SetColor(color, color, color)
	return f
end

local function drawTableHeader()
	wishlistFrame:AddChild(createLabel("Boss"))
	wishlistFrame:AddChild(createLabel("Item"))
	wishlistFrame:AddChild(createLabel("WishNumber"))
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
	local wishlist = CLMWishlists[charType][nickname]
	for wishNumber, table in pairs(wishlist) do
		wishlistFrame:AddChild(createLabel("Повелитель Горнов Игнис")) --[[fix boss name]]
		wishlistFrame:AddChild(createItemFrame(table.itemId, 33, table.marker))
		wishlistFrame:AddChild(createLabel("        " .. wishNumber))
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

local function createDropDownLabel(text)
	local label = AceGUI:Create("Label")
	label:SetText(text)
	label:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "")
	return label
end

local function drawDropdowns()
	local dropDownGroup = AceGUI:Create("SimpleGroup")
	dropDownGroup:SetLayout("Table")
	dropDownGroup:SetUserData(
			"table",
			{
				columns = {
					110,
					110
				},
				space = 1,
				align = "BOTTOMRIGHT"
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
	dropDownGroup:AddChild(createDropDownLabel("Character type"))
	dropDownGroup:AddChild(createDropDownLabel("Nickname"))
	dropDownGroup:AddChild(typeDropdown)
	dropDownGroup:AddChild(nicknameDropdown)
	dropDownGroup:AddChild(createDropDownLabel(" "))
end

local function createCharTypeFrame()
	local frame = AceGUI:Create("ScrollFrame")
	frame:SetLayout("Table")
	frame:SetUserData(
			"table",
			{
				columns = {
					{ width = 195 },
					{ width = 44 },
					{ width = 50 }
				}
			}
	)
	frame:SetFullWidth(true)
	frame:SetHeight(0)
	frame:SetAutoAdjustHeight(false)
	mainFrame:AddChild(frame)
	wishlistFrame = frame
end

function CLM:reloadData()
	charTypeIndex = CLM.db.char.charTypeIndex
	nicknameIndex = CLM.db.char.nicknameIndex
	charType = CLMWishlistsType[charTypeIndex]
	nicknameList = CLMNickname[charType]
	nickname = CLMNickname[charType][nicknameIndex]
	if mainFrame then
		typeDropdown:SetList(CLMWishlistsType)
		typeDropdown:SetValue(charTypeIndex)
		nicknameDropdown:SetList(nicknameList)
		nicknameDropdown:SetValue(nicknameIndex)
		drawCharData()
		mainFrame:SetStatusText("status text")
	end
end

function CLM:createMainFrame()
	if mainFrame then
		CLM:closeMainFrame()
		return
	end
	mainFrame = AceGUI:Create("Frame")
	mainFrame:SetWidth(400)
	mainFrame:SetHeight(750)
	mainFrame.frame:SetResizeBounds(400, 750, 400, 750)
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
