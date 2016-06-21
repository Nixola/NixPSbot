local git = function(nick)
  send("|/pm " .. nick:trueNick() .. ", https://github.com/Nixola/NixPSbot")
end

command("git", git, "git")