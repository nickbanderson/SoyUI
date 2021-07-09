local _, SoyUI = ...

local function addItemLevelToTooltips()
	local function addItemLevel(tooltip, ...) 
		local itemName, _ = tooltip:GetItem()
		local ilvl, _, _ = GetDetailedItemLevelInfo(itemName);
		if ilvl == nil then 
			return end -- some items have no ilvl :S

		GameTooltipTextLeft1:SetText(
			GameTooltipTextLeft1:GetText() .. ' (' .. ilvl .. ')'
		)
		-- tooltip:Show()
	end

	GameTooltip:HookScript('OnTooltipSetItem', addItemLevel) -- char, bag
end

local function init()
	if SoyUI_DB.SoyTooltip.itemLevelOnTooltips then
		addItemLevelToTooltips() end
end

SoyUI.modules.SoyTooltip = {
	init = init,
	defaults = {
		itemLevelOnTooltips = true,
	},
}