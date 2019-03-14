local poke = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  local nick, msg = rest:match("^(.-)|(.+)$")
  local target = msg:match("^%/me pokes (.-)$")
  if target and (target:trueNick() == cmdline.nick:trueNick()) then
  	local s = room .. "|/me "
  	if math.random() <= 0.1 then
  	  --send(room, "|/me pokes " .. nick .. " back.")
  	  s = s .. "pokes " .. nick .. " back."
  	else
  	  --send(room, "|/me is poked.")
  	  s = s .. "is poked."
  	end
  	send(s)
  end
end

COMMAND("c:", poke)