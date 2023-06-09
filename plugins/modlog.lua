--local pr = "?"

local chat = function(rest, room, timestamp)
  local nick, text = rest:match("^(.-)|(.+)$")
  if room == "#PM" then
    --don't
    return
  end
  if text:match("^/log") then -- relay the log
    local targets = {(storage.read(room) or ""):split("\n")}
    local msg = ("Log in %s: %s"):format(room, text:gsub("^/log ", ""))
    for i, nick in ipairs(targets) do
      sendPM(nick, msg)
    end
  end
end

 
local cts = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  chat(rest, room, ts)
end

local register = function(nick, room)
  if nick:rank("*") then
    local targets = {(storage.read(room) or ""):split("\n")}
    targets[#targets + 1] = nick:trueNick();
    storage.write(room, table.concat(targets, "\n"))
    sendPM(nick, ("Registered for logs in %s."):format(room))
  end
end


COMMAND("chat", chat, "modlog")
COMMAND("c:", cts, "modlog")

command("log", register, "modlog")
