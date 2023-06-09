local tells = {}

local tell = function(nick, room, ...) --this is the command
  nick = nick:trueNick()
  local s = table.concat({...}, " ")
  if not s:match("^.-%,.-$") then
  	sendPM(nick, "Usage: tell <nick>, <message>")
  	return
  end
  local target, text = s:match("^(.-)%,%s*(.-)$")
  target = target:trueNick()

  tells[target] = tells[target] or {}
  local t = tells[target]

  t[nick] = text

  sendPM(nick, "Got it. Message for " .. target .. ".")

end

command("tell", tell)

--nick is the nickname the messages were left for. nick2 is in case the user just changed nick to another one, so the second would receive the me
local deliver = function(nick)
  nick = nick:trueNick()
  if tells[nick] then
  	for sender, msg in pairs(tells[nick]) do
  	  sendPM(nick2 or nick, sender .. " left a message for you: " .. msg)
  	  tells[nick][sender] = nil
  	end
  end
end

--join, name, chat, PM; the bot should look for these commands.
--I could make it depend on chat.lua because of chat and PM, but I don't need the full functionality, the sender will be enough.

local name = function(rest, room)
  local n2, n1 = rest:match("^(.-)|(.-)$")
  deliver(n2)
end

local chatplus = function(rest, room)
  local nick = rest:match("^.-|(.-)|.-$")
  deliver(nick)
end

local pm = function(rest)
  local nick = rest:match("^(.-)|.-$")
  deliver(nick)
end

--COMMAND("chat", activity, "tell")
COMMAND("c:",   chatplus)
COMMAND("join", deliver)
COMMAND("pm",   pm)
COMMAND("name", name)
--COMMAND("join", function(...) print("JOIN", ...) end, "tell")