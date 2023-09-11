isOwner = function(nick, ranks)
  local a = nick:rank "#"
  local b = isMaster(nick)
 
  return a or b
end

local rapidJsonArrayMt = {__jsontype = "array"}

local loadLeaderboards = function(room)
  local contents = storage.read(room:trueNick()) or ""
  local leaderboards = json.decode(contents) or {}
  for i, lb in pairs(leaderboards) do
    for ii, entry in ipairs(lb.list) do
      lb.list[entry.nick:trueNick()] = entry
    end
  end
  return leaderboards
end

local newLeaderboard = function(lbs, name)
  local n = name:trueNick()
  if lbs[n] then
    return nil, lbs[n].name
  end
  local lb = {name = name, list = setmetatable({}, rapidJsonArrayMt), clear = {}}
  lbs[n] = lb
  return lb
end

local addPoints = function(lb, amount, ...)
  for i, nick in ipairs{...} do
    nick = nick:match("^%s*(.-)%s*$")
    local n = nick:trueNick()
    local entry = lb.list[n]
    if not entry then
      entry = {score = 0, nick = nick}
      lb.list[#lb.list+1] = entry
      lb.list[n] = entry
    end
    entry.score = entry.score + amount
  end
  table.sort(lb.list, function(a, b) return a.score > b.score end)
end

local renderLb = function(lb)
  local msg = {("!code Leaderboard for %s:"):format(lb.name)}
  local pos = 1
  local prev
  for i, v in ipairs(lb.list) do
    if prev and prev.score > v.score then
      pos = pos + 1
    end
    msg[#msg + 1] = ("%d. %s - %d"):format(pos, v.nick, v.score)
    prev = v
  end
  return table.concat(msg, "\n")
end

--local rapidJsonOptions = {empty_table_as_array = true}
local saveLeaderboards = function(room, lbs)
  local contents = json.encode(lbs)
  storage.write(room:trueNick(), contents)
end

local lb = function(nick, room, action, ...)

  local owner = isOwner(nick, ranks)
  if not (nick:rank "%" or owner) then return end

  local changed = false
  local n = nick:trueNick()
  local arg = table.concat({...}, " ")

  local leaderboards = loadLeaderboards(room)

  if action == "create" then

    local name = arg
    local lb,lname = newLeaderboard(leaderboards, name)
    if lb then
      changed = true
      send(("%s|You created a new leaderboard for '%s'!"):format(room, name))
    else
      send(("%s|A leaderboard named '%s' already exists."):format(room, lname))
    end
    
  elseif action == "addp" then
    local args = {arg:split(",")}
    local lbname = args[1]
    local lb = leaderboards[lbname:trueNick()]
    if not lb then
      send(("%s|There's no leaderboard with that name."):format(room))
      return
    end
    table.remove(args, 1)
    local amount = 1
    if tonumber(args[1]) then
      amount = tonumber(args[1])
      table.remove(args, 1)
    end
    changed = true
    addPoints(leaderboards[lbname:trueNick()], amount, unpack(args))
    send(("%s|%s"):format(room, renderLb(leaderboards[lbname:trueNick()])))
  elseif action == "show" then

    local lbname = arg
    local lb = leaderboards[lbname:trueNick()]
    local msg = lb and renderLb(lb) or "There's no leaderboard with that name."
    send(("%s|%s"):format(room, msg))

  elseif action == "clear" then
    local lb = leaderboards[arg:trueNick()]
    if not lb then
      send(("%s|There's no leaderboard with that name."):format(room))
      return
    end
    if lb.clear[nick:trueNick()] and lb.clear[nick:trueNick()] > os.time()-10 then
      lb.list = setmetatable({}, rapidJsonArrayMt)
      lb.clear = {}
      send(("%s|The leaderboard has been cleared."):format(room))
      changed = true
    else
      lb.clear[nick:trueNick()] = os.time()
      send(("%s|Are you sure you want to clear the leaderboard for '%s'? Clear it again within 10 seconds to confirm."):format(room, lb.name))
      changed = true
    end
  elseif action == "remove" then
    local lb = leaderboards[arg:trueNick()]
    if not lb then
      send(("%s|There's no leaderboard with that name."):format(room))
    elseif #lb.list == 0 then
      leaderboards[arg:trueNick()] = nil
      changed = true
      send(("%s|The leaderboard has been removed."):format(room))
    else
      send(("%s|The leaderboard isn't empty. Clear it first."):format(room))
    end
  elseif action == "help" then
    sendPM(nick, "``?lb create <name>`` in a room lets you create a leaderboard, ``?lb addp <name>,[amount,]p1[,p2,...]`` adds ``amount`` points (default 1) to all specified players in the specified leaderboard; ``?lb show <name>`` shows the specified leaderboard; ``?lb clear <name>`` clears it; ``?lb remove <name>`` removes it, but only if it's empty.")
  end

  if changed then
    saveLeaderboards(room, leaderboards)
  end
end

command("lb", lb)
