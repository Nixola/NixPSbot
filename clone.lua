local deepcopy
deepcopy = function(t, cache)
  if type(t) ~= 'table' then
    return t
  end

  cache = cache or {}
  if cache[t] then
    return cache[t]
  end

  local new = {}

  cache[t] = new

  for key, value in pairs(t) do
    new[deepcopy(key, cache)] = deepcopy(value, cache)
  end

  return new
end

return deepcopy