local _, SoyUI = ...
SoyUI.modules.SoyTweaks = {
  init = nil,
  defaults = {
    showArenaNumberOnNameplate = true,
  },
  cd = {
    ef = nil,
    pf = nil,
    hidden = false,
    timer = -1,
  }
}
local m = SoyUI.modules.SoyTweaks

local pvp_timers = {
  [3] = {
    "Duel starting: 3",
  },
  [15] = {
    "Fifteen seconds until",
  },
  [30] = {
    "Thirty seconds until",
    "begins in 30 seconds",
    "begin in 30 seconds",
  },
  [60] = {
    "One minute until",
    "begins in 1 minute.",
    "begin in 1 minute.",
  },
}

local function registerSlashReload()
  SLASH_SOYUI_RELOAD1 = "/rl"
  SlashCmdList["SOYUI_RELOAD"] = function()
    DEFAULT_CHAT_FRAME.editBox:SetText("/reload") 
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end
end

local function setCVars()
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

local function enablePvpCountdowns()
  m.cd.ef = CreateFrame("Frame")
  function m.cd.ef:OnEvent(event, ...)
    local msg = ...
    for timer, strings in pairs(pvp_timers) do
      for i, string in ipairs(strings) do
        if msg:find(string, 0, true) then
          m.cd.timer = timer
        end
      end
    end
  end
  m.cd.ef:SetScript("OnEvent", m.cd.ef.OnEvent)
  m.cd.ef:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
  m.cd.ef:RegisterEvent("CHAT_MSG_SYSTEM")

  m.cd.pf = CreateFrame("Frame", "CountdownParent", UIParent)
  m.cd.pf:SetHeight(256)
  m.cd.pf:SetWidth(256)
  m.cd.pf:SetPoint("CENTER", 0, 128)

  local ones = m.cd.pf:CreateTexture("CountdownOnes", "HIGH")
  ones:SetHeight(128)
  ones:SetWidth(256)
  ones:SetPoint("CENTER", m.cd.pf, 48, 0)

  local tens = m.cd.pf:CreateTexture("CountdownTens", "HIGH")
  tens:SetHeight(128)
  tens:SetWidth(256)
  tens:SetPoint("CENTER", m.cd.pf, -48, 0)

  m.cd.ef:SetScript("OnUpdate", function(self, elapse)
    -- timer off or just expiring
    if m.cd.timer <= 0 then 
      if not hidden then
        m.cd.hidden = true
        ones:Hide()
        tens:Hide()
      end
      return 
    end

    local old_timer = m.cd.timer
    m.cd.timer = m.cd.timer - elapse

    -- skip graphics update if <1 second has passed
    if math.floor(m.cd.timer) == math.floor(old_timer) then return end

    m.cd.hidden = false

    local ones_digit = math.floor(m.cd.timer % 10)
    local tens_digit = math.floor(m.cd.timer / 10)

    -- SoyUI.print(tens_digit .. " and " .. ones_digit)

    ones:SetTexture("Interface\\Addons\\SoyUI\\assets\\" .. ones_digit)
    ones:Show()

    if tens_digit ~= 0 then
      tens:SetTexture("Interface\\Addons\\SoyUI\\assets\\" .. tens_digit)
      tens:Show()
      -- SoyUI.print("tens on")
      ones:SetPoint("CENTER", m.cd.pf, 48, 0)
    else
      tens:Hide()
      ones:SetPoint("CENTER", m.cd.pf, 0, 0)
      -- SoyUI.print("tens off")
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
  enablePvpCountdowns()
  if SoyUI_DB.SoyTweaks.showArenaNumberOnNameplate then
    -- enableArenaNumberOnNameplate()
  end
  disableAutoAddSpell()
end