local first = true

local onFirstJoin = function(arg)
  if not first then return end

  local nick, guest, avatar = arg:split("|")

  if not nick:trueNick(cmdline.nick:trueNick()) then 
    print("Invalid nick.")
    return
  end

  if guest == "1" then
    print("Logged in!")
  end

  first = false

  local rooms = {(storage.read("rooms") or ""):split("\n")}

  for i, room in ipairs(rooms) do
    send("|/join " .. room)
  end
end


local autojoin = function(nick, room, action, ...)
  if not isMaster(nick) then return end
  
  local rooms = {(storage.read("rooms") or ""):split("\n")}
  local write = false

  if action == "add" then
    for i, room in ipairs{...} do
      rooms[#rooms + 1] = room
    end
    write = true
  
  elseif action == "remove" then
    local rm = {}
    for i, room in ipairs{...} do
      rm[room] = true
    end

    for i = #rooms, 1, -1 do
      local room = rooms[i]
      if rm[room] then
        table.remove(rooms, i)
      end
    end
    write = true
  
  elseif action == "list" then
    rooms = table.concat(rooms, ",")
    sendPM(nick, "List of rooms to autojoin: " .. rooms)
  end

  if write then
    storage.write("rooms", table.concat(rooms, "\n"))
  end
end

COMMAND("updateuser", onFirstJoin)

command("autojoin", autojoin)