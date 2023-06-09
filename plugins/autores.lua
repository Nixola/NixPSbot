local line = "([^\n]+)"

local autores = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  local nick, msg = rest:match("^(.-)|(.+)$")
  if nick:trueNick() == cmdline.nick:trueNick() then return end
  local autores = storage.read(room) or ""
  for rline in autores:gmatch(line) do
    local name, trigger, response = rline:match("^(.-)%|(.-)%|(.-)$")
    trigger = trigger:gsub("$self", cmdline.nick)
    if msg:match("^" .. trigger .. "$") then
      response = response:gsub("$self", cmdline.nick):gsub("$user", nick)
      send(room .. "|" .. response)
      break
    end
  end
end

local cmd = function(nick, room, action, ...)
  if not isMaster(nick) then return end
  if action == "add" then
    storage.write(room, (storage.read(room) or "") .. "\n" .. table.concat({...}, " "))
  elseif action == "remove" then
    local name = table.concat({...}, " ")
    local t = {}
    local list = storage.read(room) or ""
    for res in list:gmatch(line) do
      local rname = res:match("^(.-)|")
      if rname ~= name then
        t[#t+1] = res
      end
      storage.write(room, table.concat(t, "\n"))
    end
  elseif action == "list" then
    local list = storage.read(room) or ""
    local names = {}
    for res in list:gmatch(line) do
      local rname = res:match("^(.-)|")
      names[#names+1] = rname
    end
    sendPM(nick, "Autores in room " .. room .. ": " .. table.concat(names, ", "))
  elseif action == "print" then
    local list = storage.read(room) or ""
    local name = table.concat({...}, " ")
    for res in list:gmatch(line) do
      local rname = autores:match("^(.-)|")
      if rname == name then
        sendPM(nick, res)
      end
    end
  end
end

COMMAND("c:", autores, "autores")
command("autores", cmd, "autores")
