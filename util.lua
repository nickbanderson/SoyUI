local myAddonName, SoyUI = ...

SoyUI.util = {}

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