local _, SoyUI = ...
SoyUI.modules.SoyTweaks = {
  init = nil,
  defaults = {
    cvars = {
      showArenaNumberOnNameplate = true,
      cursorsizepreferred = 1, -- 0, 1, 2
    },
  },



}
local m = SoyUI.modules.SoyTweaks

local function registerSlashReload()
  SLASH_SOYUI_RELOAD1 = "/rl"
  SlashCmdList["SOYUI_RELOAD"] = function()
    DEFAULT_CHAT_FRAME.editBox:SetText("/reload") 
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end
end

local function setCVars()
  for cvar, value in pairs(m.defaults.cvars) do
    SetCVar(cvar, value)
  end
end

local function enableArenaNumberOnNameplate()
  hooksecurefunc("CompactUnitFrame_UpdateName", function(nameplate)
    if IsActiveBattlefieldArena() and nameplate.unit:find("nameplate", 0, true) then 
      for i=1,5 do 
        if UnitIsUnit( nameplate.unit ,"arena"..i) then 
          nameplate.name:SetText(i)
          nameplate.name:SetTextColor(1,1,0)
          break 
        end 
      end 
    end 
  end)
end

local function disableAutoAddSpell()
  -- This prevents icons from being animated onto the main action bar
  IconIntroTracker.RegisterEvent = function() end
  IconIntroTracker:UnregisterEvent('SPELL_PUSHED_TO_ACTIONBAR')

  -- In the unlikely event that you're looking at a different action page while switching talents
  -- the spell is automatically added to your main bar. This takes it back off.
  local f = CreateFrame('frame')
  f:SetScript('OnEvent', function(self, event, spellID, slotIndex, slotPos)
	  -- This event should never fire in combat, but check anyway
	  if not InCombatLockdown() then
		  ClearCursor()
		  PickupAction(slotIndex)
		  ClearCursor()
	  end
  end)
  f:RegisterEvent('SPELL_PUSHED_TO_ACTIONBAR')
end

function m.init()
  registerSlashReload()
  setCVars()
  if SoyUI_DB.SoyTweaks.showArenaNumberOnNameplate then
    enableArenaNumberOnNameplate()
  end
  disableAutoAddSpell()
end