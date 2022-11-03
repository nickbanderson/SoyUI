local _, SoyUI = ...
SoyUI.modules.SoyFrames = {
  init = nil,
  defaults = {
    player = {x = 500, y = 300},
    pet = {x = 600, y = 300},
    target = {x = 700, y = 300},
    focus = {x = 300, y = 300},
    hp_height__pct = 60,
  },
  uf = {},
}

-- aliases
local print = SoyUI.util.print
local m = SoyUI.modules.SoyFrames
local C = SoyUI.util.COLORS

function m.init()
  m.uf.player = SoyUI.UnitFrame:new("player")
  m.uf.player:hide()
  m.uf.player:show()

  m.uf.pet = SoyUI.UnitFrame:new("pet")
  m.uf.pet:hide()

  m.uf.target = SoyUI.UnitFrame:new("target")
  m.uf.target:hide()

  m.uf.focus = SoyUI.UnitFrame:new("focus")
  m.uf.focus:hide()

  local ef = CreateFrame("Frame", "SoyFrames_ef", UIParent)
  ef:RegisterEvent("PLAYER_LOGIN")
  ef:RegisterEvent("UNIT_PET")
  ef:RegisterEvent("PLAYER_TARGET_CHANGED")
  ef:RegisterEvent("PLAYER_FOCUS_CHANGED")
  ef:RegisterEvent("PLAYER_REGEN_DISABLED")
  ef:RegisterEvent("PLAYER_REGEN_ENABLED")
  ef:SetScript("OnEvent", function(s, event, ...)
    (({
      PLAYER_LOGIN = function()
        m.uf.player:show()
      end,
      UNIT_PET = function()
        local has_pet_ui, _ = HasPetUI()
        if has_pet_ui then
          m.uf.pet:show()
        else
          m.uf.pet:hide()
        end
      end,
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
      UNIT_COMBAT = function(...)
        local unit, _, _, _, _ = ...
        setCombatIndicator(unit)
      end,
      UNIT_HEALTH = function(...)
        local unit = ...
        setCombatIndicator(unit)
      end,
      PLAYER_REGEN_DISABLED = function()
        m.uf.player.frames.background.name_text:SetTextColor(unpack(C.red))
      end,
      PLAYER_REGEN_ENABLED = function()
        m.uf.player.frames.background.name_text:SetTextColor(unpack(C.white))
      end,
    })[event] or print("UNMATCHED EVENT"))(...)
  end)
end
