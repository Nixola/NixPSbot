--local ranks = {" ", "+", "%", "@", "&", "#", "~", [" "] = 0, ["+"] = 1, ["%"] = 2, ["@"] = 3, ["#"] = 4}
loadRanks = function(room)
  return json.decode(storage.read(room .. ".json") or "{}")
end

isOwner = function(nick, ranks)
  local a = nick:rank "#"
  local b = isMaster(nick)
  local c = ranks[nick:trueNick()] and ranks[nick:trueNick()].rank == "#"

  print("isMaster", nick, a, b, c)
  
  return a or b or c
end

local rank = function(nick, room, action, ...)
  --local ranksj = storage.read(room .. ".json") or "{}"
  --local ranks  = json.decode(ranksj)

  local ranks = loadRanks(room)

  local owner = isOwner(nick, ranks)

  local changed = false

  if action == "add" then
    if not (nick:rank("%") or owner) then return end
    local target = table.concat({...}, " ")
    if ranks[target:trueNick()] then
      sendPM(nick, target .. " is already on the list.")
    end
    ranks[target:trueNick()] = {name = target, rank = " "}
    changed = true

  elseif action == "promote" then

    if not (nick:rank "@" or owner) then return end

    local args = table.concat({...}, " ")
    local target, rank = args:match("^%s*(.-)%s*,%s*(.-)%s*$")
    if not (target and rank) then
      sendPM(nick, "Usage: ``" .. prefix .. "rank promote <nick>,<rank>``")
      return
    end

    ranks[target:trueNick()] = ranks[target:trueNick()] or {name = target, rank = " "}

    local currentRank = ranks[target:trueNick()].rank
    if rank:rank() < currentRank:rank() then
      sendPM(nick, "The user's rank is higher. Maybe you meant ``" .. prefix .. "rank demote``?")
    elseif rank:rank() == currentRank:rank() then
      sendPM(nick, "The user is already " .. rank .. ".")
    else
      if rank:rank() >= ("@"):rank() and not owner then
        sendPM(nick, "You're not allowed to promote a user to that rank.")
      end
      ranks[target:trueNick()].rank = rank
      sendPM(nick, "The user was promoted to " .. rank .. ".")
      changed = true
    end
  elseif action == "demote" then

    if not (nick:rank "@" or owner) then return end

    local args = table.concat({...}, " ")
    local target, rank = args:match("^%s*(.-)%s*,%s*(.-)%s*$")
    target = target or args
    if not target then
      sendPM(nick, "Usage: ``" .. prefix .. "rank promote <nick>,<rank>``")
      return
    end

    rank = rank or " "

    if not ranks[target:trueNick()] then
      sendPM(nick, target .. " isn't even in my list. u w8 m8")
      return
    end

    local currentRank = ranks[target:trueNick()].rank

    if (currentRank:rank() >= ("@"):rank()) and not owner then
      sendPM(nick, "You're not allowed to demote that user.")
      return
    end

    if currentRank:rank() == rank:rank() then
      sendPM(nick, "The user is already that rank.")
      return
    elseif currentRank:rank() < rank:rank() then
      sendPM(nick, "The user's rank is lower. Maybe you meant ``" .. prefix .. "rank promote``?")
      return
    end

    ranks[target:trueNick()].rank = rank
    sendPM(nick, "The user was demoted to " .. (rank == " " and "regular" or rank) .. ".")

    changed = true
  elseif action == "remove" then
    if not (nick:rank "%" or owner) then return end

    local target = table.concat({...}, " ")
    if not target then
      sendPM(nick, "Usage: ``" .. prefix .. "rank remove <nick>``")
      return
    end

    if not ranks[target:trueNick()] then
      sendPM(nick, target .. " isn't even in my list. u wot m8")
      return
    end

    local currentRank = ranks[target:trueNick()].rank

    if (currentRank:rank() >= ("@"):rank() or currentRank:rank() >= nick:rank()) and not owner then
      sendPM(nick, "You're not allowed to remove that user.")
      return
    end

    ranks[target:trueNick()] = nil
    sendPM(nick, "The user was removed from the list.")

    changed = true
  elseif action == "refresh" then
  	local r = table.concat({...}, " ")
    newRoom = r and r:gsub("[^%w-]+", "")
    if room == "#PM" and not newRoom then
      sendPM(nick, "Usage: ``" .. prefix .. "rank refresh[ room]``")
      return
    end
    ranks = newRoom and loadRanks(newRoom) or ranks
    room = newRoom or room
    owner = isOwner(nick, ranks)
    if ranks[nick:trueNick()].rank:rank() < ("+"):rank() and not owner then return end
    changed = true
  elseif action == "guide" then
    sendPM(nick, "https://static.niix.ga/perm/rankGuide.html")
  elseif action == "quit" then
    if room == "#PM" then
      local r = table.concat({...}, " ")
      room = r and r:gsub("[^%w-]+", "")
      ranks = loadRanks(room)
    end
    if not ranks[nick:trueNick()] then
      sendPM(nick, "You're not even in that list. u wot m8")
      return
    end
    ranks[nick:trueNick()] = nil
    sendPM(nick, "You succesfully quit the room.")
    changed = true
  elseif action == "invite" then
  	if not owner then
  	  sendPM(nick, "You're not allowed to invite everyone.")
  	  return
  	end

    local w
    if tonumber((...)) then
      w = tonumber((...))
    end

  	for i, v in pairs(ranks) do
  	  --send("|/w " .. i .. ", Hi! Join <<" .. room .. ">>! This is an automated message. You can \"unsubscribe\" by writing ``" .. prefix .. "rank quit " .. room .. "``.")
  	  --sendPM(i, "/invite " .. room)
  	  sendPM(i, "Join <<" .. room .. ">>! This is an automated message. You can \"unsubscribe\" by writing me ``" .. prefix .. "rank quit " .. room .. "``, or just ``" .. prefix .. "rank quit`` in the room you want to quit.")

      if w then
        print("Waiting", w, "seconds")
        wait(w)
      end
  	end
  end


  if changed then
    local t = {}
    for _, v in pairs(ranks) do
      t[#t+1] = v
    end

    table.sort(t, function(a, b)
      if a.rank:rank() > b.rank:rank() then return true
      elseif a.rank:rank() < b.rank:rank() then return false
      elseif a.rank:rank() == b.rank:rank() then return a.name:trueNick() < b.name:trueNick()
      end
    end)

    local r = {" ", "+", "%", "@", "#", [" "] = 0, ["+"] = 1, ["%"] = 2, ["@"] = 3, ["#"] = 4}
    local R = {[0] = "Invite", "Voice (+)", "Driver (%)", "Moderator (@)", "Room Owner (#)"}
    local cr = 4

    local page = "<html><meta charset=\"UTF-8\"><head><title>List - " .. room .. "</title></head><body>%s</body></html>"
    
    local l = R[cr] .. ":<br>"
    for i, v in ipairs(t) do
      if r[v.rank] < cr then
        cr = r[v.rank]
        l = l .. "<br>" .. R[cr] .. ":<br>"
      end
      l = l .. "- " .. v.name .. "<br>"
    end
    storage.write(room .. ".html", page:format(l))

    storage.write(room .. ".json", json.encode(ranks, {pretty = true}))
  end
end


invites = function(args)
  local sender, target, text = args:match("^(.-)|(.-)|(.+)$")

  local s = sender:trueNick()

  local cmd, rest = text:match("^/(%w+)%s*(.-)$")

  if cmd ~= "invite" then return end

  local room = rest:gsub("[^%w-]+", "")

  if not room then return end

  local ranks = loadRanks(room)
  local owner = isOwner(sender, ranks)
  local rank  = ranks[s] and ranks[s].rank:rank() or 0

  if not ((rank >= ("+"):rank()) or owner) then return end

  send("|/join " .. room)

end


local belle = function(nick, room, ...)
  if room == "##PM" then return end
  local ranks = loadRanks(room)
  local owner = isOwner(nick, ranks)

  if nick:rank "+" or owner then
    send("|/pm Bellematon,/invite " .. room)
  end
end

command("rank", rank)
COMMAND("pm", invites)
command("belle", belle)