local cb = require "callbacks"

COMMANDS = {}

setmetatable(COMMANDS, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      os.exit()
    end
    --print(name, rawget(self, name))
    self[name] = c
    return self[name]
  end})

local lengthen = {
  c = "chat",
  b = "battle",
  j = "join",
  l = "leave",
  n = "name"
}

local r

local parse = function(msg)
  --if msg:sub(1, 1) ~= "|" then return end
  local lines = {}
  for line in msg:gmatch("[^\n]+") do
    lines[#lines+1] = line
  end
  local room = lines[1]:match("^>(.-)\n")

  if room then table.remove(lines, 1)
  else room = r
  end
  r = room

  for i = 1, #lines do
    local line = lines[i]
    --print(line)
    --print(line)
    local action, rest = line:match("^|(.-)|(.-)$")
    if not action then --just display this? I will create an appropriate callback for this when I know more

    else
      action = lengthen[action] or action
      print("ACTION", action)
      COMMANDS[action]:fire(rest, room)
    end
  end
end

receive:register(parse, "COMMANDS")

--welp... this is awkward

commands = {}

setmetatable(commands, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      os.exit()
    end
    --print(name, rawget(self, name))
    self[name] = c
    return self[name]
  end})

--this is basically the same thing as above, but COMMANDS is for internal stuff while this is for chat commands

--return commands