local ev = require('ev')
local client = require('websocket.client').ev()
--https://github.com/lipp/lua-websockets


local args = {...}
cmdline = {}
for i, v in ipairs(arg) do
    if v:match("^%-%-") then --option
      cmdline[v:match("^%-%-(.-)$")] = true
    else --par
      local o = arg[i-1]:match("^%-%-(.-)$")
      cmdline[o] = v
    end
end

cmdline.master = cmdline.master or "nixola"

local cb = require "callbacks"
local ls = require "ls"
local clone = require "clone"



client:on_open(function()
    print('connected')
end)

client:connect("ws://sim.psim.us:8000/showdown/websocket")

--local send = function(txt)
send = function(txt)
  client:send(txt)
end

local sendPM = function(target, txt)
  send("|/pm " .. target:trueNick() .. ", " .. txt)
end

receive = cb("receive")

client:on_message(function(ws, msg)
  receive:fire(msg)
    --print(msg)
  end)

require "commands"
if cmdline.log then
  require "log"
end

local COMMAND = function(cmd, func, id)
  return COMMANDS[cmd]:register(func, id)
end

local command = function(cmd, func, id)
  return commands[cmd]:register(func, id)
end

local FIRE = function(cmd, ...) -- should NOT need this
  return COMMANDS[cmd]:fire(...)
end

local fire = function(cmd, ...)
  return commands[cmd]:fire(...)
end

string.trueNick = function(str, n)
  if n then
    return str:trueNick() == n
  end
  return str:gsub("%W", ""):lower()
end


--for _, file in ipairs(ls "plugins") do

commands.reload:register(function(nick)

  if nick and not nick:trueNick(cmdline.master) then
    return
  end

  local plugins = ls "plugins"
  for i = #plugins, 1, -1 do

    local env   = {}
    env.send    = send
    env.sendPM  = sendPM
    env.math    = clone(math)
    env.table   = clone(table)
    env.print   = print -- potentially unsafe or at least annoying
    env.unpack  = unpack
    --env.io      = clone(io) --UNSAFE! WILL CHANGE
    env.json    = clone(require "rapidjson")
    env.post    = require "post"
    env.COMMAND = COMMAND
    env.command = command
    --env.FIRE    = FIRE
    env.fire    = fire

    env.cmdline = clone(cmdline)

    local file = plugins[i]
    local f, e = loadfile(file, "t", env)

    if f then f()
    else print("Could not load", file, ":", e)
    end
  end
end, "reload")
commands.reload:fire()
ev.Loop.default:loop()