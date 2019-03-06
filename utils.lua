string.split = function(str, sep)
  assert(#sep == 1, "Invalid separator")
  local t = {}
  for p in str:gmatch(("([^%s]+)"):format(sep)) do
    t[#t+1] = p
  end
  return unpack(t)
end
-- This splits a string along a separator, returning the different parts.
-- The separator can't be anything but a single byte.

string.trueNick = function(str, n)
  if n then
    return str:trueNick() == n
  end
  return str:gsub("%W", ""):lower()
end
-- This strips characters from the username, resulting in the "base nick"
-- which actually identifies a nick. Quite barebones, prone to breakage.
-- I should yank code from PS to fix this, as it's incomplete.