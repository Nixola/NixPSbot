local raw = function(nick, room, ...)

  --if nick:lower():sub(2, -1) ~= "nixola" then
  if not nick:trueNick(cmdline.master) then
    --sendMessage(nick, "fuck off")
    return
  end

  local s = table.concat({...}, " ")

  --print("SENDING", s)

  send(s)
end


local pm = function(nick, room, target, ...)
  if not nick:trueNick(cmdline.master) then
    return
  end

  send("|/pm " .. target:trueNick() .. ", " .. table.concat({...}, " "))
end


local join = function(nick, room, targetRoom)
  if not nick:trueNick(cmdline.master) then
    return
  end

  send("|/join " .. targetRoom)
end


local say = function(nick, room, targetRoom, ...)
  if not nick:trueNick(cmdline.master) then
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
command("raw", raw, "control")

command("pm", pm, "control")

command("join", join, "control")
command("j", join, "control")

command("say", say, "control")
command("s", say, "control")
command("c", say, "control")