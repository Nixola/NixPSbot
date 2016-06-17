local chat = function(room, rest)
  local nick, text = rest:match("^(.-)|(.+)$")
  print("#" .. room, "<" .. nick .. ">", text)
end

commands.chat:register(chat, "chat")