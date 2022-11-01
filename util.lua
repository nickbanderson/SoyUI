local myAddonName, SoyUI = ...

SoyUI.util = {}

SoyUI.util.POWER_TYPE = { -- incomplete, hard to find source
  MANA = 0,
  RAGE = 1,
  FOCUS = 2,
  ENERGY = 3,
}

SoyUI.util.COLORS = {
  POWER = {
    [0] = { -- mana
      main = {0, 0, 1},    
      lighter = {.678, .847, .902},
    },
    [1] = { -- rage
      main = {1, 0, 0},    
      lighter = {1, .6, .597},
    },
    [2] = { -- focus
      main = {1, .502, .251},    
      lighter = {.996, .847, .694},
    },
    [3] = { -- energy
      main = {1, 1, 0},    
      lighter = {1, 1, .878},
    },
    [6] = { -- runic power
      main = {0, .820, 1},    
      lighter = {.635, .777, .828},
    },
  },
  CLASS = {
    NPC = {0, 1, 0},
    DEATHKNIGHT  = {.773, .118, .227},
    DRUID  = {1, .486, .039},
    HUNTER  = {.667, .827, .447},
    MAGE  = {.247, .780, .922},
    PALADIN  = {.957, .549, .729},
    PRIEST  = {1, 1, 1},
    ROGUE  = {1, .96, .408},
    SHAMAN  = {0, .478, .867},
    WARLOCK  = {.529, .533, .933},
    WARRIOR = {.776, .608, .427},
  },
  red = {.8, .1, .2},
  yellow = {1, .9, .4},
  green = {0, .9, 0},
  white = {1, 1, 1},
}

-- recursively stringify a table
SoyUI.util.stringify = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. SoyUI.util.stringify(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- print with color, automatically stringifying tables
SoyUI.util.print = function(msg)
  if type(msg) == 'table' then
    msg = SoyUI.util.stringify(msg)
  elseif msg == nil then
    msg = "nil"
  end

  DEFAULT_CHAT_FRAME:AddMessage("|cff00eeffSoyUI:|r " .. msg)	
end

-- split string of words into table of words
SoyUI.util.split = function(str)
  words = {}
  for word in str:gmatch("%w+") do 
    table.insert(words, word)
  end
  return words
end

-- 342 => 342, 1234 => 1.2k, 1234234 => 1.2mil
SoyUI.util.fmtNum = function(num)
  if num < 1000 then
    return num
  end
    
  local n = #tostring(num)
  local suffix = n > 6 and "m" or "k"
  local split = n > 6 and n - 6 or n - 3
  return string.sub(tostring(num), 0, split) .. "." 
          .. string.sub(tostring(num), split + 1, split + 1) .. suffix
end

-- return class (eg "DEATHKNIGHT") or "NPC" if not player
SoyUI.util.UnitClass = function(unit)
  return UnitIsPlayer(unit) 
          and select(2, UnitClass(unit))
          or "NPC"
end

SoyUI.util.constrainValue = function(val, limits)
  return math.max(limits[1], math.min(val, limits[2]))
end
