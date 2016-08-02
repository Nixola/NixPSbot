local f
if cmdline.log == "stdout" then
  f = io.stdout
else
  f = io.open("/tmp/nix.showbot.log", "w")
end

local log = function(msg)
  f:write(msg)
  f:write('\n')
  f:flush()
end

receive:register(log, "log")