local LibExtraTip = LibStub:GetLibrary("LibExtraTip-1")
local colorR
local colorG
local colorB
local function onGameTooltipSetItem(tooltip)
	local _, link = tooltip:GetItem()
	if link == nil then
		return
	end
	local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", link)
	itemId = tonumber(itemId)
	if CLMItems[itemId] == nil then
		return
	end
	local item = CLMItems[itemId]
	if (#item > 0) then
		LibExtraTip:AddDoubleLine(tooltip, "Wishlist group", "WishNumber", 1, 0, 0, 1, 0, 0, false)
	end
	local previousClass
	for _, spec in ipairs(item) do
		local characterType = spec.characterType
		local nickname = spec.nickname
		local wishNumber = spec.wishNumber
		if ("caster" == characterType) then
			colorR = 0
			colorG = 0.58
			colorB = 0.72
		else
			colorR = 0.13
			colorG = 0.545098039
			colorB = 0.13
		end
		if not (previousClass == characterType) then
			LibExtraTip:AddLine(tooltip, characterType, colorR, colorG, colorB, false)
			previousClass = characterType
		end
		local leftText = "   " .. nickname
		LibExtraTip:AddDoubleLine(tooltip, leftText, wishNumber, colorR, colorG, colorB, colorR, colorG, colorB, false)
	end
end

function CLM:initBisTooltip()
	LibExtraTip:AddCallback({ type = "item", callback = onGameTooltipSetItem, allevents = true })
	LibExtraTip:RegisterTooltip(GameTooltip)
	LibExtraTip:RegisterTooltip(ItemRefTooltip)
end