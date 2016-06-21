local master = "nixola"

local raw = function(nick, ...)

  --if nick:lower():sub(2, -1) ~= "nixola" then
  if not nick:trueNick(master) then
    --sendMessage(nick, "fuck off")
    return
  end

  local s = table.concat({...}, " ")

  --print("SENDING", s)

  send(s)
end


local pm = function(nick, target, ...)
  if not nick:trueNick(master) then
    return
  end

  send("|/pm " .. target:trueNick() .. ", " .. table.concat({...}, " "))
end


local join = function(nick, room)
  if not nick:trueNick(master) then
    return
  end

  send("|/j " .. room)
end


local say = function(nick, room, ...)
  if not nick:trueNick(master) then
    return
  end

  local s = table.concat({...}, " ")
  send(room:trueNick() .. "|" .. s)
end

--commands.raw:register(raw, "control")
command("raw", raw, "control")

command("pm", pm, "control")

command("join", join, "control")
command("j", join, "control")

command("say", say, "control")
command("s", say, "control")
command("c", say, "control")