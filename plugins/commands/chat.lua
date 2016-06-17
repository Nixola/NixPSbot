local chat = function(rest, room, timestamp)
  local nick, text = rest:match("^(.-)|(.+)$")
  if text:sub(1,1) == "!" then --this is a command! now what the fuck should I call this
  	local command = text:match("^!(%w)+")
  	local args = {}
  	for arg in (text:match("^.-%s(.-)$")):gmatch("^%S") do
  	  args[#args+1] = arg
  	end
  end
  print("#" .. room, "<" .. nick .. ">", text)
end

local cts = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)")
  chat(rest, room, ts)
end

local pm = function(rest)
  local sender, target, text = rest:match("^(.-)|(.-)|(.+)$")
  print(sender, target, text)
  chat(sender .. "|" .. text, "PM")
end

COMMANDS.chat:register(chat, "chat")
COMMANDS["c:"]:register(cts, "chat:")
COMMANDS.pm:register(pm, "chatpm")