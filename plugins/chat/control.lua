local raw = function(nick, room, ...)

  --if nick:lower():sub(2, -1) ~= "nixola" then
  if not isMaster(nick) then
    --sendMessage(nick, "fuck off")
    return
  end

  local s = table.concat({...}, " ")

  --print("SENDING", s)

  send(s)
end


local pm = function(nick, room, target, ...)
  if not isMaster(nick) then
    return
  end

  send("|/pm " .. target:trueNick() .. ", " .. table.concat({...}, " "))
end


local join = function(nick, room, targetRoom)
  if not isMaster(nick) then
    return
  end

  send("|/join " .. targetRoom)
end


local say = function(nick, room, targetRoom, ...)
  if not isMaster(nick) then
    return
  end

  local words = {...}

  if targetRoom:sub(-1,-1) ~= "," then --this is no room!
  	table.insert(words, 1, targetRoom)
  	targetRoom = room
  else
  	targetRoom = targetRoom:sub(1, -2)
  end

  local s = table.concat(words, " ")
  send(targetRoom:gsub("[^%w-]", "") .. "|" .. s)
end

--commands.raw:register(raw, "control")
command("raw", raw)

command("pm", pm)

command("join", join)
command("j", join)

command("say", say)
command("s", say)
command("c", say)