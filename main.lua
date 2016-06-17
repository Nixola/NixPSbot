local ev = require('ev')
local client = require('websocket.client').ev()

local cb = require "callbacks"
local ls = require "ls"

client:on_open(function()
    print('connected')
end)

client:connect("ws://sim.psim.us:8000/showdown/websocket")

send = function(txt)
  client:send(txt)
end

receive = cb("receive")

client:on_message(function(ws, msg)
  receive:fire(msg)
    --print(msg)
  end)

--for _, file in ipairs(ls "plugins") do
local plugins = ls "plugins"
for i = #plugins, 1, -1 do
  local file = plugins[i]
  local f, e = loadfile(file)
  if f then f()
  else print("Could not load", file, ":", e)
  end
end

ev.Loop.default:loop()