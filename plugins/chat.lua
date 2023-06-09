--local pr = "?"

local chat = function(rest, room, timestamp)
  local nick, text = rest:match("^(.-)|(.+)$")
  if text:sub(1,1) == prefix or room == "#PM" then --this is a command!
  	--print(text)
  	local command = text:match("^" .. prefix .. "?(%w+)")
    if not command then --not command
      return
    end
  	local args = {}
  	local a = text:match("^.-%s(.-)$")
  	--print(command)
  	a = a or ""
  	for arg in a:gmatch("%S+") do
  	  args[#args+1] = arg
  	end
  	--commands[command]:fire(nick, unpack(args))
    fire(command, nick, room, unpack(args))
  end
  print("#" .. room, "<" .. nick .. ">", text)
end

local cts = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  chat(rest, room, ts)
end

local pm = function(rest)
  local sender, target, text = rest:match("^(.-)|(.-)|(.+)$")
  chat(sender .. "|" .. text, "#PM")
end

--[[
COMMANDS.chat:register(chat, "chat")
COMMANDS["c:"]:register(cts, "chat:")
COMMANDS.pm:register(pm, "chatpm")--]]

COMMAND("chat", chat)
COMMAND("c:", cts)
COMMAND("pm", pm)