--local ranks = {" ", "+", "%", "@", "&", "#", "~", [" "] = 0, ["+"] = 1, ["%"] = 2, ["@"] = 3, ["#"] = 4}

local rank = function(nick, room, action, ...)
  local ranksj = storage.read(room .. ".json") or "{}"
  local ranks  = json.decode(ranksj)

  local owner = nick:rank "#" or nick:trueNick(cmdline.master:trueNick())

  local changed = false

  if action == "add" then
    if not nick:rank("%") then return end
    local target = table.concat({...}, " ")
    if ranks[target:trueNick()] then
      sendPM(nick, target .. " is already on the list.")
    end
    ranks[target:trueNick()] = {name = target, rank = " "}
    changed = true

  elseif action == "promote" then

    if not nick:rank "@" or owner then return end

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

    if not nick:rank "@" or owner then return end

    local args = table.concat({...}, " ")
    local target, rank = args:match("^%s*(.-)%s*,%s*(.-)%s*$")
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
    sendPM(nick, "The user was demoted to " .. (rank or "regular") .. ".")

  end

  if changed then
    local t = {}
    for _, v in pairs(ranks) do
      t[#t+1] = v
    end

    table.sort(t, function(a, b)
      if a:rank() > b:rank() then return true
      elseif a:rank() < b:rank() then return false
      elseif a:rank() == b:rank() then return a.name:trueNick() < b.name:trueNick()
      end
    end)

    local r = {" ", "+", "%", "@", "#", [" "] = 0, ["+"] = 1, ["%"] = 2, ["@"] = 3, ["#"] = 4}
    local R = {"Invite", "Voice (+)", "Driver (%)", "Moderator (@)", "Room Owner (#)"}
    local cr = 4
    
    local l = R[cr] .. ":\n"
    for i, v in ipairs(t) do
      if r[v.rank] < cr then
        cr = r[v.rank]
        l = l .. "\n" .. R[cr] .. ":\n"
      end
      l = l .. "- " .. v.name .. "\n"
    end
    storage.write(room .. ".list", l)
  end
end

command("rank", rank, "rank")
