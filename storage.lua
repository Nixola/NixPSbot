local storage = {}

storage.new = function(name)
  if name:match("/") then return end
  local f, e, c = io.open("storage/" .. name)
  if not f then
  	if c == 2 then
  	  os.execute("mkdir -p storage/" .. name)
    else
      return nil, e, c
    end
  else
    f:close()
  end

  local t = {}
  t.write = function(filename, ...)
    if filename:match("/") then return end
    local f, e, c = io.open("storage/" .. name .. "/" .. filename, "wb")
    if not f then
      return f, e, c
    end
    local s, r, e, c = pcall(f.write, f, ...)
    if not s then return s, r end
    if not r then return r, e, c end

    f:close()
  end

  t.read = function(filename, what)
    if filename:match("/") then return end
    local f, e, c = io.open("storage/" .. name .. "/" .. filename, "rb")
    if not f then
      return f, e, c
    end
    local s, r, e, c = pcall(f.read, f, what or "*a")
    if not s then return s, r end
    if not r then return r, e, c end

    f:close()
    return r
  end

  t.append = function(filename, ...)
    if filename:match("/") then return end
    local f, e, c = io.open("storage/" .. name .. "/" .. filename, "ab")
    if not f then
      return f, e, c
    end
    local s, r, e, c = pcall(f.write, f, ...)
    if not s then return s, r end
    if not r then return r, e, c end

    f:close()
  end

  return t
end

return storage