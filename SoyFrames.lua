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

local function createPlayer()
  local player = {}

  player.parent = createBar("SoyUIPlayerFrame", {144,36}, {0,0,0}) 
  player.parent:SetPoint("CENTER", 500, -100)

  player.health = createBar("SoyUIPlayerHealth", {140,15}, {0,200,0}) 
  player.health:SetPoint("TOPLEFT", "SoyUIPlayerFrame", "TOPLEFT", 2, -2)
  player.health:RegisterEvent("UNIT_HEALTH")
  player.health:SetScript("OnEvent", 
    function(self, event, ...)
      local unit = ...
      if unit ~= "player" then return end
      player.health:SetWidth(140 * (UnitHealth(unit))/UnitHealthMax(unit))
    end
  )

  player.power = createBar("SoyUIPlayerPower", {140,15}, {0,0,200}) 
  player.power:SetPoint("BOTTOMLEFT", "SoyUIPlayerFrame", "BOTTOMLEFT", 2, 2)
  player.power:RegisterEvent("UNIT_MANA")
  player.power:SetScript("OnEvent", 
    function(self, event, ...)
      local unit, type = ...
      if unit ~= "player" then return end
      player.power:SetWidth(141 * (UnitPower(unit))/UnitPowerMax(unit))
    end
  )


  return player
end

local function init()
  SoyUI.modules.SoyFrames.frames.player = createPlayer()
end

SoyUI.modules.SoyFrames = {
  init = init,
  defaults = {
  },
  frames = {},
}
