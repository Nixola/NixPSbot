local callbacks = {}
callbacks.mt = {__index = callbacks}
callbacks.new = function(self, name)
  --if self[name] then return nil, "Callback exists" end
  local c = setmetatable({}, self.mt)
  --c.name = name
  --c.cbs = {}
  --self[name] = c
  return c
end

callbacks.register = function(self, func, id)
  --if self.cbs[id] then return nil, "ID exists" end
  if self[id] then return nil, "ID exists" end
  print("registered", id)
  if not (type(func) == "function") then return nil, "Invalid callback" end
  --self.cbs[id] = func
  self[id] = func
  return true
end

callbacks.remove = function(self, id)
  --if not self.cbs[id] then return nil, "ID does not exist" end
  if not self[id] then return nil, "ID does not exist" end
  --self.cbs[id] = nil
  self[id] = nil
  return true
end

callbacks.fire = function(self, ...)
  --for id, callback in pairs(self.cbs) do
  for id, c in pairs(self) do
    if c(...) then
      self[id] = nil
    end
  end
end

setmetatable(callbacks, {__call = callbacks.new})
return callbacks