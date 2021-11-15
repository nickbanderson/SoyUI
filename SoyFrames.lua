local _, SoyUI = ...
SoyUI.modules.SoyFrames = {
  init = nil,
  defaults = {
  },
  uf = {},
}
local m = SoyUI.modules.SoyFrames

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

-- 342 => 342, 1234 => 1.2k, 1234234 => 1.2mil
local function fmtNum(num)
  if num < 1000 then
    return num
  end
    
  local n = #tostring(num)
  local suffix = n > 6 and "m" or "k"
  local split = n > 6 and n - 6 or n - 3
  return string.sub(tostring(num), 0, split) .. "." 
          .. string.sub(tostring(num), split + 1, split + 1) .. suffix
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

  local background = createBar(
    uf.name .. "_background", 
    {uf.barWidth + 2 * uf.padding, 2 * uf.barHeight + 3 * uf.padding},
    {0, 0, 0}
  )
  background:SetPoint("CENTER", x, y)
  background.text = background:CreateFontString(uf.name .. "_bgText", "MEDIUM",
                                                "GameTooltipText")
  background.text:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 0)

  local hp = createBar(
    uf.name .. "_hp",
    {uf.barWidth, uf.barHeight},
    {0, 120, 0}
  )
  hp:SetPoint("TOPLEFT", uf.name .. "_background", "TOPLEFT",
                        uf.padding, -1 * uf.padding)
  hp.text = hp:CreateFontString(uf.name .. "_hpText", "MEDIUM", "GameTooltipText")
  hp.text:SetPoint("BOTTOM", uf.name .. "_background" , "CENTER", 0, uf.padding)

  local power = createBar(
    uf.name .. "_power",
    {uf.barWidth, uf.barHeight},
    {0, 0, 120}
  )
  power:SetPoint("BOTTOMLEFT", uf.name .. "_background",
                           "BOTTOMLEFT", uf.padding, uf.padding)
  power.text = power:CreateFontString(uf.name .. "_powerText", "MEDIUM", "GameTooltipText")
  power.text:SetPoint("TOP", uf.name .. "_background" , "CENTER", 0, -1 * uf.padding)

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
  self.frames.hp.text:SetText(fmtNum(UnitHealth(self.unit)))
end

function UnitFrame:updatePower()
  self.frames.power:SetWidth(self.barWidth * 
                             (UnitPower(self.unit) / UnitPowerMax(self.unit)))
  self.frames.power.text:SetText(fmtNum(UnitPower(self.unit)))
end

function UnitFrame:updateMeta()
  self.frames.background.text:SetText(GetUnitName(self.unit))
  local t = UnitPowerType(self.unit)
  local color = {
    [0] = {0, 0, 255},    -- mana
    [1] = {255, 0, 0},    -- rage
    [2] = {255, 128, 64}, -- focus
    [3] = {255, 255, 0},  -- energy
    [6] = {0, 209, 255},  -- runic power
  }
  if color[t] == nil then
    print(self.unit .. " " .. t)
    error("unit power type doesn't have color defined in addon")
  end
  self.frames.power.texture:SetTexture(color[t][1], color[t][2], color[t][3])
end

function UnitFrame:show()
  self:updateMeta()
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

function m.init()
  m.uf.player = UnitFrame:new("player", 300, 0)
  m.uf.player:hide()
  m.uf.player:show()

  m.uf.focus = UnitFrame:new("focus", 300, -100)
  m.uf.focus:hide()

  m.uf.target = UnitFrame:new("target", 600, 0)
  m.uf.target:hide()

  local ef = CreateFrame("Frame", "SoyFrames_ef", UIParent)
  ef:RegisterEvent("PLAYER_TARGET_CHANGED")
  ef:RegisterEvent("PLAYER_FOCUS_CHANGED")
  ef:SetScript("OnEvent", function(s, event, ...)
    (({
      PLAYER_TARGET_CHANGED = function() 
        if UnitExists("target") then 
          m.uf.target:show() 
        else
          m.uf.target:hide() 
        end
      end,
      PLAYER_FOCUS_CHANGED = function() 
        if UnitExists("focus") then 
          m.uf.focus:show() 
        else
          m.uf.focus:hide() 
        end
      end,
    })[event] or print("UNMATCHED EVENT"))()
  end)
end

