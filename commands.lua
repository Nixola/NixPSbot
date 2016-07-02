local cb = require "callbacks"

COMMANDS = {}

setmetatable(COMMANDS, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      print("ERROR!", e, name)
      --os.exit()
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
  local room = lines[1]:match("^>(.-)\n") or lines[1]:match("^>(.-)$")
  --print("ROOM", room)

  --if room then table.remove(lines, 1)
  if lines[1]:sub(1,1) == ">" then table.remove(lines, 1)
  --else room = r
  end
  r = room

  for i = 1, #lines do
    local line = lines[i]
    --print(line)
    --print(line)
    local action, rest = line:match("^|(.-)|(.-)$")
    if not action then --just display this? I will create an appropriate callback for this when I know more

    else
      action = lengthen[action:lower()] or action
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
      print("error!", e, name)
      --os.exit()
    end
    --print(name, rawget(self, name))
    self[name] = c
    return self[name]
  end})

--this is basically the same thing as above, but COMMANDS is for internal stuff while this is for chat commands

commands.cmd:register(function(nick, ...)
  local args = {...}
  local action = args[1]

  table.remove(args, 1)

  local actions = {}

  --print(action)

  if not nick:trueNick(cmdline.master) then
    return
  end

  actions.remove = function(nick, command)
    if commands[command] then
      commands[command] = nil
    else
      send("|/pm " .. nick .. ", The command ``" .. command .. "`` already doesn't exist.")
    end
  end

  actions.add = function(nick, cmdname, ...)

    if rawget(commands, cmdname) then
      send("|/pm " .. nick .. ", The command ``" .. cmdname .. "`` already exists. Use ``addow``.")
    else
      return actions.addow(nick, cmdname, ...)
    end
  end

  actions.addow = function(nick, cmdname, ...)
    commands[cmdname] = nil
    local command = table.concat({...}, " ")
    local f, e = loadstring(command)
    if not f then
      send("|/pm " .. nick .. ", Error: " .. e)
      return
    end
    commands[cmdname]:register(function(...)
      local results = {pcall(f, ...)}
      if not results[1] then
        print("commands:", cmdname, "failed:", results[2])
        return
      end
      table.remove(results, 1)
      return unpack(results)
    end, "commands-"..cmdname)
  end


  if actions[action] then actions[action](nick, unpack(args)) end
end, "commands")