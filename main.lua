local ev = require('ev')
local client = require('websocket.client').ev()

local storage = require "storage"
require "urlencode"
--https://github.com/lipp/lua-websockets

os.execute("mkdir ~/.nixPSbot -p")

do
  local globs = 0
  setmetatable(_G, {__newindex = function(self, key, value) 
    globs = globs + 1
    print("New global", key, value, globs)
    rawset(self, key, value)
  end})
end


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

local rec = function(func, id)
  receive:register(func, id)
end

string.trueNick = function(str, n)
  if n then
    return str:trueNick() == n
  end
  return str:gsub("%W", ""):lower()
end

string.rank = function(str, rank, ranks)

  ranks = ranks or {
    [" "] = 0;
    ["+"] = 1;
    ["★"] = 1.3;
    --staff
    ["$"] = 1.5;
    ["%"] = 2;
    ["@"] = 3;
    ["&"] = 4;
    ["#"] = 5;
    ["~"] = 6;
  }

  local r, nick = str:match("^(.)(.-)$")
  if not rank then
    return ranks[r] or 0
  elseif str:trueNick() == "" then
    return ranks[str] or " "
  end
  return ranks[r] >= ranks[rank]
end

local hang

do
  local ex = os.execute
  hang = function(n)
    if not tonumber(n) then return end
    --require "socket".select(nil, nil, n)
    ex("sleep " .. string.format("%d", n))
  end
end


--for _, file in ipairs(ls "plugins") do

commands.reload:register(function(nick)

  if nick and not nick:trueNick(cmdline.master) then
    return
  end
  
  local get, post = unpack(require "connect")

  local plugins = ls "plugins"
  for i = #plugins, 1, -1 do

    local st, e, c = storage.new(plugins[i]:match("^plugins/(.-)%.lua$"))
    if not st then
      print("Could not add storage for ", plugins[i], e, c)
    end

    local env        = {}
    env.send         = send
    env.sendPM       = sendPM
    env.math         = clone(math)
    env.table        = clone(table)
    env.print        = print -- potentially unsafe or at least annoying
    env.unpack       = unpack
    env.ipairs       = ipairs
    env.pairs        = pairs
    env.select       = select
    env.rawget       = rawget
    env.rawset       = rawset
    env.setfenv      = setfenv
    env.setmetatable = setmetatable
    env.loadstring   = loadstring
    env.pcall        = pcall
    env.tostring     = tostring
    --env.io           = clone(io) --UNSAFE! WILL CHANGE
    env.json         = clone(require "rapidjson")
    env.get          = get
    env.post         = post
    env.COMMAND      = COMMAND
    env.command      = command
    env.FIRE         = FIRE
    env.fire         = fire
    env.receive      = receive
    env.tonumber     = tonumber

    env.wait         = hang -- TEMPORARY! BEWARE!

    env.storage      = st

    env.prefix       = "?"

    env.cmdline      = clone(cmdline)

    local file = plugins[i]
    local f, e = loadfile(file, "t", env)

    if f then f()
    else print("Could not load", file, ":", e)
    end
  end
end, "reload")
commands.reload:fire()

ev.Loop.default:loop()

os.exit(-1)