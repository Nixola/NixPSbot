local callbacks = {}
--[[
This module allows for callback handling. It can probably be improved.
]]
callbacks.mt = {__index = callbacks}
callbacks.new = function(self, name)
  local c = setmetatable({}, self.mt)
  return c
end
-- This function just creates a "callback object" giving it access to its "class"
-- methods.

callbacks.register = function(self, func, id)
  if self[id] then return nil, "ID exists" end
  print("registered", id)
  if not (type(func) == "function") then return nil, "Invalid callback" end
  self[id] = func
  return true
end
-- Allows to register a callback for a specific event. Requires the actual callback
-- and a unique identifier.

callbacks.remove = function(self, id)
  if not self[id] then return nil, "ID does not exist" end
  self[id] = nil
  return true
end
-- Removes a callback with a specific ID, provided it actually exists.

callbacks.fire = function(self, ...)
  for id, c in pairs(self) do
    if c(...) then
      self[id] = nil
    end
  end
end
-- Fires all callbacks registered to the event.

setmetatable(callbacks, {__call = callbacks.new})
return callbacks