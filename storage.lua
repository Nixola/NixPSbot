local storage = {}
--[[
This is a module that allows plugins to manage their own storage. Each plugin
basically gets assigned a folder in which it can read and/or write [to] whatever
file it needs. There's no size limit, so a plugin can "easily" fill up the
entire hard disk rendering the system useless. Plugins are kind of sandboxed
to prevent most kinds of damage, but you're still supposed to check them before
downloading/installing/enabling/whatever any from an untrusted source.
]]

storage.new = function(name)
  if name:match("/") then return end
  -- No slashes allowed in folder name. Any attempt to do so will result in naught.
  local f, e, c = io.open("storage/" .. name)
  -- Checking if the folder exists
  if not f then
    -- Could not open folder
  	if c == 2 then
      -- Folder doesn't exist, creating it
  	  os.execute("mkdir -p storage/" .. name)
    else
      -- Any other reason, bail out
      return nil, e, c
    end
  else
    -- Folder exists. Or a file with its name, but that's f***ed up.
    f:close()
  end

  local t = {}
  t.write = function(filename, ...)
    if filename:match("/") then return end
    -- No slashes allowed in file name. Not allowing any kind of directory access.
    local f, e, c = io.open("storage/" .. name .. "/" .. filename, "wb")
    if not f then
      -- File does not exist.
      return f, e, c
    end
    local s, r, e, c = pcall(f.write, f, ...)
    -- Trying to write to the file; errors are "propagated" as return nil, stuff
    if not s then return s, r end
    if not r then return r, e, c end

    f:close()
  end

  t.read = function(filename, what)
    if filename:match("/") then return end
    -- No slashes allowed in file name. Not allowing any kind of directory access.
    local f, e, c = io.open("storage/" .. name .. "/" .. filename, "rb")
    if not f then
      -- File does not exist.
      return f, e, c
    end
    local s, r, e, c = pcall(f.read, f, what or "*a")
    -- Trying to read from the file; errors are "propagated" as return nil, stuff
    if not s then return s, r end
    if not r then return r, e, c end

    f:close()
    return r
  end

  t.append = function(filename, ...)
    -- Same thing as above; appends to a file.
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