local mmrandom = function(nick, room)
  send(("%s|/botmsg PartBot,,mastermind boardgames setcode %s, %04o"):format(room,nick,math.random(4096)-1))
end

command("mmrandom", mmrandom, "mmrandom")
