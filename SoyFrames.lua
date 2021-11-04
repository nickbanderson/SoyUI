local _, SoyUI = ...


local function createBar(name, size, color)
  local f = CreateFrame("Frame", name, UIParent)
  f:SetFrameStrata("LOW")
  f:SetWidth(size[1])
  f:SetHeight(size[2])
  
  local t = f:CreateTexture(nil, "BACKGROUND")
  t:SetTexture(color[1], color[2], color[3]) -- color = {r, g, b}
  t:SetAllPoints(f)
  f.texture = t

  return f
end

local function createUnitFrame(unit, x, y)
  local f = {}

  local parent_name = "SoyUIUnitFrame_" .. unit
  f.parent = createBar(parent_name, {144,36}, {0,0,0}) 
  f.parent:SetPoint("CENTER", x, y)

  f.health = createBar(parent_name .. "_hp", {140,15}, {0,200,0}) 
  f.health:SetPoint("TOPLEFT", parent_name, "TOPLEFT", 2, -2)
  f.health:RegisterEvent("UNIT_HEALTH")
  f.health:SetScript("OnEvent", 
    function(self, event, ...)
      local u = ...
      if u ~= unit then return end
      f.health:SetWidth(140 * (UnitHealth(unit))/UnitHealthMax(unit))
    end
  )

  f.power = createBar(parent_name .. "_power", {140,15}, {0,0,200}) 
  f.power:SetPoint("BOTTOMLEFT", parent_name, "BOTTOMLEFT", 2, 2)
  f.power:RegisterEvent("UNIT_MANA")
  f.power:SetScript("OnEvent", 
    function(self, event, ...)
      local u, type = ...
      if u ~= unit then return end
      f.power:SetWidth(140 * (UnitPower(unit))/UnitPowerMax(unit))
    end
  )

  return f
end

local function hideUnitFrame(f)
  for i, frame in pairs(f) do
    frame:Hide()
  end
end

local function showUnitFrame(f)
  for i, frame in pairs(f) do
    frame:Show()
  end
end

local function init()
  SoyUI.modules.SoyFrames.frames.player = createUnitFrame("player", 300, 0)

  SoyUI.modules.SoyFrames.frames.target = createUnitFrame("target", 600, 0)
  hideUnitFrame(SoyUI.modules.SoyFrames.frames.target)
  SoyUI.modules.SoyFrames.frames.target.parent:RegisterEvent("PLAYER_TARGET_CHANGED")
  SoyUI.modules.SoyFrames.frames.target.parent:SetScript("OnEvent",
    function(self, event, ...)
      if UnitExists("target") then
        showUnitFrame(SoyUI.modules.SoyFrames.frames.target)
      else
        hideUnitFrame(SoyUI.modules.SoyFrames.frames.target)
      end
    end
  )

  SoyUI.modules.SoyFrames.frames.focus = createUnitFrame("focus", 300, -100)
  hideUnitFrame(SoyUI.modules.SoyFrames.frames.focus)
  SoyUI.modules.SoyFrames.frames.focus.parent:RegisterEvent("PLAYER_FOCUS_CHANGED")
  SoyUI.modules.SoyFrames.frames.focus.parent:SetScript("OnEvent",
    function(self, event, ...)
      if UnitExists("focus") then
        showUnitFrame(SoyUI.modules.SoyFrames.frames.focus)
      else
        hideUnitFrame(SoyUI.modules.SoyFrames.frames.focus)
      end
    end
  )
end

SoyUI.modules.SoyFrames = {
  init = init,
  defaults = {
  },
  frames = {},
}
