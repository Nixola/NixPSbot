local f = io.open("/tmp/nix.showbot.log", "w")

local log = function(msg)
  f:write(msg)
  f:write('\n')
  f:flush()
end

receive:register(log, "log")
