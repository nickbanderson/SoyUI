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

-- meta class
local UnitFrame = {
  unit = nil,
  hp = nil,
  power = nil,
  barWidth = 140,
  barHeight = 15,
  padding = 2,
  frames = {},
}
UnitFrame.__index = UnitFrame

function UnitFrame:SetUpdateScripts()
  self.frames.hp:RegisterEvent("UNIT_HEALTH")
  self.frames.hp:SetScript("OnEvent",
    function(f, event, ...)
      local u = ...
      if u == self.unit then self:updateHp() end
    end
  )

  self.frames.power:RegisterEvent("UNIT_MANA")
  self.frames.power:SetScript("OnEvent",
    function(f, event, ...)
      local u = ...
      if u == self.unit then self:updatePower() end
    end
  )
end

function UnitFrame:new(unit, x, y)
  local uf = {}
  setmetatable(uf, UnitFrame)

  uf.name = "SoyFrames_" .. unit
  uf.unit = unit

  -- uf.frames.background = createBar(
  local background = createBar(
    uf.name .. "_background", 
    {uf.barWidth + 2 * uf.padding, 2 * uf.barHeight + 3 * uf.padding},
    {0, 0, 0}
  )
  -- uf.frames.background:SetPoint("CENTER", x, y)
  background:SetPoint("CENTER", x, y)

  -- uf.frames.hp = createBar(
  local hp = createBar(
    uf.name .. "_hp",
    {uf.barWidth, uf.barHeight},
    {0, 120, 0}
  )
  hp:SetPoint("TOPLEFT", uf.name .. "_background", "TOPLEFT",
                        uf.padding, -1 * uf.padding)

  -- uf.frames.power = createBar(
  local power = createBar(
    uf.name .. "_power",
    {uf.barWidth, uf.barHeight},
    {0, 0, 120}
  )
  power:SetPoint("BOTTOMLEFT", uf.name .. "_background",
                           "BOTTOMLEFT", uf.padding, uf.padding)

  uf.frames = {
    background = background,
    hp = hp,
    power = power,
  }
  uf:SetUpdateScripts()
  return uf
end

function UnitFrame:updateHp()
  self.frames.hp:SetWidth(self.barWidth * 
                          (UnitHealth(self.unit) / UnitHealthMax(self.unit)))
end

function UnitFrame:updatePower()
  self.frames.power:SetWidth(self.barWidth * 
                             (UnitPower(self.unit) / UnitPowerMax(self.unit)))
end

function UnitFrame:show()
  self:updateHp()
  self:updatePower()
  for i, f in pairs(self.frames) do
    f:Show()
  end
end

function UnitFrame:hide()
  for i, f in pairs(self.frames) do
    f:Hide()
  end
end

local function init()
  SoyUI.modules.SoyFrames.uf.player = UnitFrame:new("player", 300, 0)
  SoyUI.modules.SoyFrames.uf.player:show()

  SoyUI.modules.SoyFrames.uf.focus = UnitFrame:new("focus", 300, -100)
  SoyUI.modules.SoyFrames.uf.focus:hide()

  SoyUI.modules.SoyFrames.uf.target = UnitFrame:new("target", 600, 0)
  SoyUI.modules.SoyFrames.uf.target:hide()

  local ef = CreateFrame("Frame", "SoyFrames_ef", UIParent)
  ef:RegisterEvent("PLAYER_TARGET_CHANGED")
  ef:RegisterEvent("PLAYER_FOCUS_CHANGED")
  ef:SetScript("OnEvent", function(s, event, ...)
    (({
      PLAYER_TARGET_CHANGED = function() 
        if UnitExists("target") then 
          SoyUI.modules.SoyFrames.uf.target:show() 
        else
          SoyUI.modules.SoyFrames.uf.target:hide() 
        end
      end,
      PLAYER_FOCUS_CHANGED = function() 
        if UnitExists("focus") then 
          SoyUI.modules.SoyFrames.uf.focus:show() 
        else
          SoyUI.modules.SoyFrames.uf.focus:hide() 
        end
      end,
    })[event] or print("UNMATCHED EVENT"))()
  end)
end

SoyUI.modules.SoyFrames = {
  init = init,
  defaults = {
  },
  uf = {},
}
