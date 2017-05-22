local cb = require "callbacks"
--[[
This module parses the PS protocol and provides a self-filling table containing
callbacks for PS commands. For some reason, I decided it would be a good idea
to have in this same file a basically unrelated model that allows masters to
define new commands (as Lua code!) for the bot on the go via chat.
]]

COMMANDS = {}

setmetatable(COMMANDS, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      print("ERROR!", e, name)
    end
    self[name] = c
    return self[name]
  end})
-- Set COMMANDS' metatable so that it automatically creates a callback handler
-- and assigns it in case something tries to access/use one that does not
-- exist yet. Does nothing to prevent invalid actions from being registered.

local lengthen = {
  c = "chat",
  b = "battle",
  j = "join",
  l = "leave",
  n = "name"
}
-- Just a table with aliases PS uses for common events.

local parse = function(msg)
  -- This is the function that does a preliminary parsing of PS' messages.
  local lines = {}
  for line in msg:gmatch("[^\n]+") do
    lines[#lines+1] = line
  end
  -- Split the whole message into different lines, so that each can be handled
  -- separately.
  local room = lines[1]:match("^>(.-)\n") or lines[1]:match("^>(.-)$") or "lobby"
  -- Tries to figure out what room this message is for, defaulting to lobby if
  -- unspecified.
  if #lines > 10 then
    return --I refuse to parse all the text that's in the room before joining
  end

  --if room then table.remove(lines, 1)
  if lines[1]:sub(1,1) == ">" then
    table.remove(lines, 1)
    -- Remove the first line, if it's the room the block refers to.
  end

  for i = 1, #lines do
    local line = lines[i]
    local action, rest = line:match("^|(.-)|(.-)$")
    -- Extract the "action" (type of PS message) and the rest of the stuff.
    if not action then
      --just display this? I will create an appropriate callback for this when
      -- I know more.
    else
      action = lengthen[action:lower()] or action
      -- action should always be the long version, for clarity.
      COMMANDS[action]:fire(rest, room)
      -- Fires the callbacks for the received type of message, passing the
      -- "arguments" of the message as first argument, as received from PS,
      -- and the room it happens in as second.
    end
  end
end

receive:register(parse, "COMMANDS")
-- Register the parse function as callback when anything's received.



commands = {}
--[[
As stated above, this module allows master to add/set and remove custom bot
commands as Lua code. It's completely unrelated to the functionality above.
]]

setmetatable(commands, {__index = function(self, name)
    local c, e = cb(name)
    if not c then
      print("error!", e, name)
    end
    self[name] = c
    return self[name]
  end})
-- Set commands' metatable so that it automatically creates a callback handler
-- and assigns it in case something tries to access/use one that does not
-- exist yet. This is related to bot commands, not PS actions.

commands.cmd:register(function(nick, ...)
  local args = {...}
  local action = args[1]

  table.remove(args, 1)

  local actions = {}

  if not isMaster(nick) then
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