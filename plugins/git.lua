local git = function(nick, room)
  send("|/pm " .. nick:trueNick() .. ", https://github.com/Nixola/NixPSbot")
end

command("git", git, "git")