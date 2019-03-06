local ev = require('ev')
local client = require('websocket.client').ev()

local storage = require "storage"
require "urlencode"
require "utils"
--https://github.com/lipp/lua-websockets

os.execute("mkdir ~/.nixPSbot -p")
-- Creates a directory in home in order to store stuff. Linux only.

do
  local globs = 0
  setmetatable(_G, {__newindex = function(self, key, value) 
    globs = globs + 1
    print("New global", key, value, globs)
    rawset(self, key, value)
  end})
end
-- Tracks the number of global variables. It pollutes stdout though.

local sendQueue = {}


local args = {...}
cmdline = {}
credentials = require "credentials"
for i, v in ipairs(arg) do
    if v:match("^%-%-") then --option
      local optionName = v:match("^%-%-(.+)")
      cmdline[optionName] = true
    else --par
      local prevOptionName = arg[i-1]:match("^%-%-(.+)")
      cmdline[prevOptionName] = v
    end
end
cmdline.nick =  credentials.nick
-- This parses the command line arguments and puts them into a global table,
-- allowing access to them to every part of the program.

cmdline.master = cmdline.master or "nixola"
-- Sets the master of the bot. Mostly legacy code, which makes me the default
-- master in case one isn't specified with a command line argument. Some
-- commands (such as join, say, raw and the like) can only be used by masters.
cmdline.masters = {}
for m in cmdline.master:gmatch("([^,]+)") do
  print("Master", m, m:trueNick())
  cmdline.masters[m:trueNick()] = true
end
-- In case the --master option is a comma separated list, it populates the
-- masters table with it in order to make it easy to have several bot owners.

do
  local masters = cmdline.masters
  isMaster = function(nick)
    return masters[nick:trueNick()]
  end
end
-- Create a function that allows to check if a nick is a master without having
-- to expose the table to the plugins.

local cb = require "callbacks"
local ls = require "ls"
local clone = require "clone"



client:on_open(function()
    print('connected')
end)
-- Callback fired as soon as the bot estabilishes a connection to PS, before
-- any kind of authentication is involved. I should probably move login stuff
-- in here.

client:connect("ws://sim.psim.us:8000/showdown/websocket")
-- Provides the websocket URL of the server to connect to.

send = function(txt, priority)
  priority = priority or 1
  local msg = {text = txt, priority = priority, time = os.clock()}
  sendQueue[#sendQueue + 1] = msg
  table.sort(sendQueue, function(a, b)
    return (a.priority == b.priority) and (a.time < b.time) or (a.priority > b.priority)
  end)
end
-- Function to send raw messages to PS. Can be safely passed to plugins without
-- them being able to modify any table.

local sendPM = function(target, txt)
  send("|/pm " .. target:trueNick() .. ", " .. txt)
end
-- Utility function to send PMs to users. Something feels off about this though

receive = cb("receive")
-- Create a new set of callbacks, fired every time a message is received from
-- the server. Receives the whole message as argument.

client:on_message(function(ws, msg)
  print("RECV", msg)
  receive:fire(msg)
end)

-- Creates a listener for stdin (file descriptor 0) that runs every time it's ready for reading
local io = ev.IO.new(function()
  local msg = io.stdin:read "*l"
  send(msg)
  print("SENDING", msg)
end, 0, ev.READ)

-- Add the listener to main loop
io:start(ev.Loop.default)

-- Creates a timed function that runs every .5 seconds. Used to send rate-limited messages.
local timer = ev.Timer.new(function()
  local msg = sendQueue[1]
  if msg then
    client:send(msg.text)
    table.remove(sendQueue, 1)
  end
end, 0.01, tonumber(cmdline.rate) or 0.75)

-- Add the timer to main loop
timer:start(ev.Loop.default)

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

  if nick and not isMaster(nick) then
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
    env.isMaster     = isMaster

    local file = plugins[i]
    if file == "plugins/login.lua" then
      env.credentials = clone(credentials)
    end
    local f, e = loadfile(file, "t", env)

    if f then f()
    else print("Could not load", file, ":", e)
    end
  end
end, "reload")
commands.reload:fire()

ev.Loop.default:loop()

os.exit(-1)
