return function(path, t)

  t = t or "f"

  if path:sub(-1, -1) ~= "/" then path = path .. "/" end
  local cmd = "find '" .. path .. "' -type " .. t .. " | sort "
  
  local p = io.popen(cmd, "r")
  local r = p:read "*a"
  p:close()
  local t = {}
  for file in r:gmatch("[^\n]+") do
  	t[#t+1] = file
  end
  return t
end
