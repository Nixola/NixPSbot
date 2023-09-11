isOwner = function(nick, ranks)
  local a = nick:rank "#"
  local b = isMaster(nick)
 
  return a or b
end

local rapidJsonArrayMt = {__jsontype = "array"}
local loadQueue = function(room)
  local contents = storage.read(room:trueNick()) or ""
  local queue = json.decode(contents) or {list = {}, clear = {}}
  setmetatable(queue.list, rapidJsonArrayMt)
  return queue
end

--local rapidJsonOptions = {empty_table_as_array = true}
local saveQueue = function(room, queue)
  local contents = json.encode(queue)
  print(contents)
  storage.write(room:trueNick(), contents)
end

local queue = function(nick, room, action, ...)

  local owner = isOwner(nick, ranks)

  local changed = false
  local queue = loadQueue(room)
  local n = nick:trueNick()

  if action == "join" then
    local present = false
    for i, v in ipairs(queue.list) do
      if v:trueNick() == n then
        present = true
        send(("%s|%s, you're already in this room's queue."):format(room, nick))
        break
      end
    end

    if not present then
      if queue.locked then
        send(("%s|The queue is locked; ask a driver or higher to add you."):format(room))
        return
      end
      queue.list[#queue.list+1] = nick
      print(queue.list[1])
      changed = true
      send(("%s|%s, you joined the queue!"):format(room, nick))
    end
  
  elseif action == "add" then
    if not (nick:rank "%" or owner) then return end
    local present = false
    local target = table.concat({...}, " ")
    local ntarget = target:trueNick()
    for i, v in ipairs(queue.list) do
      if v:trueNick() == n then
        present = true
        send(("%s|%s already is in this room's queue."):format(room, target))
        break
      end
    end

    if not present then
      queue.list[#queue.list + 1] = target
      changed = true
      send(("%s|%s, %s has been added to the queue!"):format(room, nick, target))
    end
  elseif action == "drop" then

    local present = false
    for i, v in ipairs(queue.list) do
      if v:trueNick() == n then
        if queue.locked then
          send(("%s|The queue is locked; ask a driver or higher to remove you."):format(room))
          return
        end
        table.remove(queue.list, i)
        changed = true
        send(("%s|%s, you dropped out of the queue."):format(room, nick))
        present = true
        break
      end
    end
    if not present then
      send(("%s|%s, you aren't in this room's queue."):format(room, nick))
    end
  
  elseif action == "remove" then
    if not (nick:rank "%" or owner) then return end
    local present = false
    local target = table.concat({...}, " ")
    local ntarget = target:trueNick()

    for i, v in ipairs(queue.list) do
      if v:trueNick() == ntarget then
        table.remove(queue.list, i)
        changed = true
        send(("%s|%s, %s has been removed from the queue."):format(room, nick, target))
        present = true
        break
      end
    end
    if not present then
      send(("%s|%s, %s is not in this room's queue."):format(room, nick, target))
    end
  elseif action == "lock" or action == "unlock" then
    if not (nick:rank "%" or owner) then return end
    queue.locked = action == "lock"
    changed = true
    send(("%s|The queue has been %sed."):format(room, action))

  elseif action == "pop" or action == "rotate" then

    if not (nick:rank "%" or owner) then return end
    local pop = queue.list[1]
    if not pop then
      send(("%s|There's no one in the queue."):format(room))
      return
    end
    changed = true
    send(("%s|Next up: %s!"):format(room, pop))
    table.remove(queue.list, 1)
    if action == "rotate" then
      queue.list[#queue.list+1] = pop
    end
  
  elseif action == "show" then
    if not (nick:rank "%" or owner) then return end
    if not queue.list[1] then
      send(("%s|There's no one in the queue."):format(room))
      return
    end
    local msg = "Here's the current queue: " .. table.concat(queue.list, ", ")
    local messages = {}
    while #msg > 300 do
      local rpart = msg:sub(1, 300):reverse()
      local comma = 300 - part:find(",")
      local part = msg:sub(1, comma)
      messages[#messages + 1] = part
      msg = msg:sub(comma + 1)
    end
    messages[#messages + 1] = msg

    for i, v in ipairs(messages) do
      send(("%s|%s"):format(room, v))
    end

  elseif action == "clear" then
    if not (nick:rank "%" or owner) then return end
    if queue.clear[nick:trueNick()] and queue.clear[nick:trueNick()] > os.time()-10 then
      queue.list = {}
      queue.clear = {}
      send(("%s|The queue has been cleared."):format(room))
      changed = true
    else
      queue.clear[nick:trueNick()] = os.time()
      send(("%s|Are you sure you want to clear the queue for this room? Clear it again within 10 seconds to confirm."):format(room))
      changed = true
    end
  elseif action == "help" then
    sendPM(nick, "``?queue join`` in a room lets you join a queue, ``?queue drop`` to drop out; if you're a driver or higher, ``?queue pop`` shows the next person and removes them from the queue, ``?queue rotate`` does the same but also queues them back right in; ``?queue lock`` and ``?queue unlock`` lock and unlock the queue, preventing people from joining and dropping, while ``?queue add <target>`` and ``?queue remove <target>`` add or remove a user to the queue. ``?queue show`` shows the current queue and ``?queue clear`` clears it.")
  end

  if changed then
    saveQueue(room, queue)
  end
end

command("queue", queue)
