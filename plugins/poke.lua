local poke = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  local nick, msg = rest:match("^(.-)|(.+)$")
  local target = msg:match("^%/me pokes (.-)$")
  print(target)
  if target and target:trueNick() == cmdline.nick:trueNick() then
  	if math.random() <= 0.1 then
  	  send(room, "|/me pokes " .. nick .. " back.")
  	else
  	  send(room, "|/me is poked.")
  	end
  end
end

COMMAND("c:", poke, "poke")