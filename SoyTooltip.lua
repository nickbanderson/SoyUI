--[[

bug: show a tooltip, mouse over bonfire/object = wrong position
	hooking OnUpdate is too late in the load cycle; it is UGLY

GameTooltip is a widget, so useful to look for widget handlers/methods

--]]

local tooltip_x = -20
local tooltip_y = 200

-- makes -first- load of ANY gametooltip positioned right (see bug)
GameTooltip:HookScript("OnShow", function(self)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", tooltip_x, tooltip_y)
end)

-- players and npcs
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	--self:ClearAllPoints() -- not necessary until it is :)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", tooltip_x, tooltip_y)

	local name = GameTooltipTextLeft1:GetText()
	local guild, _, _ = GetGuildInfo("mouseover")
	local _, class, _ = UnitClass("mouseover")
	if class == nil then class = "PRIEST" end -- priest is white (default text color)
	if guild == nil then
		guild = ""
	else
		guild = "\n|cffaaaaaa<" .. guild .. ">|r"
  end

	GameTooltipTextLeft1:SetText("|c" .. RAID_CLASS_COLORS[class].colorStr.. name .. "|r" .. guild)
end)

-- action bar spells
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", tooltip_x, tooltip_x)
end)

-- action bar items
GameTooltip:HookScript("OnTooltipSetItem", function(self)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", tooltip_x, tooltip_y)
end)