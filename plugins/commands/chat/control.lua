local raw = function(nick, ...)

  if nick:lower():sub(2, -1) ~= "nixola" then
  	--sendMessage(nick, "fuck off")
    return
  end

  local s = "|" .. table.concat({...}, " ")

  print("SENDING", s)

  send(s)
end

commands.raw:register(raw, "control")