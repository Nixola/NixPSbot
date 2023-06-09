local fields = {
  "storedPokes",
  "totalPokes",
  "strongestPoke",
  "lastPoked"
}
local loadPokes, writePokes, renderLeaderboard
local actions = {
  [function(message) local target = message:match("^/me%s+pokes%s+(.-)$"); return target and (target:trueNick() == cmdline.nick:trueNick()) end] = function(room, nick)
    nick = nick:sub(2,-1)
    local data = loadPokes(nick)

    local s = room .. "|/me "
    local chance = math.random()
    local t = math.max(1, os.time() - data.lastPoked)
    --local p = math.min(1, math.max(0, 1/math.log(t)))
    local p = math.atan(-t/100)+1.643
    print("Poked after", t, p, chance)
    if (chance <= p and data.storedPokes > 0) or p >= 1 then
      --send(room, "|/me pokes " .. nick .. " back.")
      local msg = data.storedPokes > 0 and 
        ( "pokes " .. nick .. " back with the strength of " .. data.storedPokes + 1 .. " pokes!")
        or
        ( "immediately pokes " .. nick .. " back.")

      s = s .. msg
      data.strongestPoke = math.max(data.strongestPoke, data.storedPokes + 1)
      data.storedPokes = -1
    else
      --send(room, "|/me is poked.")
      s = s .. "is poked."
      --storage.write(nick:trueNick(), tostring(pokes + 1))
    end
    send(s)
    data.storedPokes = data.storedPokes + 1
    data.totalPokes = data.totalPokes + 1
    data.lastPoked = os.time()
    writePokes(nick, data)
  end,
  [function(message) local target = message:match("^/mee  +pokes (.-)$"); return target and (target:trueNick()) end] = function(room, nick)
    send(("%s|/sendprivateuhtml %s, smart%X, <span>You think you're smart?</span>"):format(room, nick, math.random(0x10000000, 0xffffffff)))
  end,

  [function(message) local target = message:match("^/me asks (.-) leaderboard") ; return target and target:trueNick():match("^" .. cmdline.nick:trueNick() ) end] = function(room, nick)
    send(room ..  "|/adduhtml pokeleadmsg,<p><button name='send' value='/botmsg " .. cmdline.nick:trueNick() .. ",/me checks the leaderboard in " .. room .. " top 10'>Show Poke leaderboard</button> <button name='send' value='/botmsg " .. cmdline.nick:trueNick() .. ",/me checks the leaderboard in " .. room .. " by strongest top 10'>Show Poke leaderboard by strongest poke</button> (not Pok&eacute;)</p>")
   
  end
  

}

renderLeaderboard = function(strongest, top)
  local players = {}
  for i, nick in ipairs(storage.list()) do
    local data = loadPokes(nick)
    players[i] = {nick = nick, data = data}
  end

  table.sort(players, strongest and 
    function(p1, p2)
      if p1.data.strongestPoke < p2.data.strongestPoke then
        return false
      elseif p1.data.strongestPoke > p2.data.strongestPoke then
        return true
      else
        return p1.data.totalPokes > p2.data.totalPokes
      end
    end
    or
    function(p1, p2)
      if p1.data.totalPokes < p2.data.totalPokes then
        return false
      elseif p1.data.totalPokes > p2.data.totalPokes then
        return true
      else
        return p1.data.strongestPoke > p2.data.strongestPoke
      end
    end
  )
  
  local html = "<table style='border:1px solid;border-spacing:0.15em;text-align:left;'><thead><tr><th>Rank</th><th>Player</th><th>Total pokes</th><th>Strongest poke</th></tr></thead><tbody>%s</tbody></table>"

  local body = {}
  for i, v in ipairs(players) do
    local line = ("<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td></tr>"):format(i, v.nick, v.data.totalPokes, v.data.strongestPoke)
    body[#body+1] = line
    if i == tonumber(top) then break end
  end

  return html:format(table.concat(body, ""))
end


for i, v in ipairs(fields) do
  fields[v] = i
end

loadPokes = function(nick)
  local s = storage.read(nick:trueNick()) or ""
  local data = {}  
  if s:match("\n") then -- new version
    local i = 1
    for line in s:gmatch("([^\n]+)") do
      data[fields[i]] = tonumber(line)
      i = i + 1
    end
  else
    data[fields[1]] = tonumber(s) or 0
  end

  if not data.totalPokes then
    data.totalPokes = data.storedPokes
  end

  data.strongestPoke = data.strongestPoke or 0
  data.lastPoked = data.lastPoked or 0

  return data
end

writePokes = function(nick, data)
  local d = {}
  for i, v in ipairs(fields) do
    d[i] = data[v]
  end
  storage.write(nick:trueNick(), table.concat(d, '\n'))
end

local poke = function(rest, room)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  local nick, msg = rest:match("^(.-)|(.+)$")
  --local pokes = tonumber((storage.read(nick:trueNick()))) or 0
  local link = false
  local mee = false
  msg, link = msg:gsub("%[%[%]%]", "")
  msg, mee = msg:gsub("^/mee ", "/me")
  link = link > 0
  mee = mee > 0
  for condition, action in pairs(actions) do
    if condition(msg) then
      action(room, nick)
      if link or mee then
        send(("%s|/sendprivateuhtml %s, smart%X, <span>You think you're smart?</span>"):format(room, nick, math.random(0x10000000, 0xffffffff)))
      end
    end
  end
end

local pokepm = function(args)
  local sender, target, text = args:match("^(.-)|(.-)|(.+)$")
  if sender:trueNick() == cmdline.nick:trueNick() then return end
  text = text:gsub("^/botmsg%s+", "")
  local request = text:match("^/me checks the leaderboard")
  if not request then return end
  local room = text:match("in (%S+)")
  if not room then return end
  local criterion = text:match("by (%S+)")
  local strongest = criterion == "strongest"
  local top = text:match("top (%d+)")
  local leaderboard = renderLeaderboard(strongest, top)
  local buttoncmd = ("/botmsg %s, /me checks the leaderboard in %s %s %s"):format(cmdline.nick:trueNick(), room, strongest and "by strongest" or "", top and "" or "top 10")
  local button = "<button name=send value=\"" .. buttoncmd .. "\">" .. (top and "Expand" or "Collapse") .. "</button>"
  send(room .. "|/sendprivateuhtml " .. sender:trueNick() .. ", pokeleaderboard, " .. button .. leaderboard .. button)
end

COMMAND("c:", poke, "poke")
COMMAND("pm", pokepm, "poke")
