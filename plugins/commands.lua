local cb = require "callbacks"

commands = {}

setmetatable(commands, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      print(e)
      os.exit()
    end
    --print(name, rawget(self, name))
    self[name] = cb
    return self[name]
  end})

local lengthen = {
  c = "chat",
  b = "battle",
  j = "join",
  l = "leave",
  n = "name"
}

local parse = function(msg)
  --if msg:sub(1, 1) ~= "|" then return end
  local lines = {}
  for line in msg:gmatch("[^\n]+") do
    lines[#lines+1] = line
  end
  local room = lines[1]:match("^>(.-)\n")

  for i = 2, #lines do
    local line = lines[i]
    --print(line)
    --print(line)
    local action, rest = line:match("^|(.-)|(.-)$")
    print(action)
    if not action then --just display this? I will create an appropriate callback for this when I know more

    else
      action = lengthen[action] or action
      commands[action]:fire(room, rest)
    end
  end
end

receive:register(parse, "commands")

--return commands