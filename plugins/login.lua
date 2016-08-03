--local post = require "post"
--local json = require "rapidjson"

local challstring = function(chstr)

  local t = {}
  t.act      = "getassertion"
  t.userid   = cmdline.nick:trueNick()
  t.pass     = cmdline.pass
  t.challstr = chstr

  local assertion, url = get("http://play.pokemonshowdown.com/action.php", t)

  if assertion:match("^;;.-") then
    print("Error. Could not log in.")
    print(assertion:match("^;;(.-)$"))
    os.exit()
  elseif assertion:find("\n") then
    print("Error. No response from server.")
    os.exit()
  elseif assertion == ";" then
    t.act  = "login"
    t.name = cmdline.nick --t.userid
    t.userid = nil
    --t.pass = cmdline.pass
    local data, body = post("http://play.pokemonshowdown.com/action.php", t)
    if data:sub(1, 1) ~= "]" then
      print("Error. Aborting.")
      print(data)
      os.exit()
    end
    assertion = json.decode(data:sub(2, -1)).assertion
  end

  send("|/trn " .. (t.name or t.userid) .. ",0," .. assertion)

  print("Logged in. Most likely.")


  --[[legacy code
  --the following happens if the nick is registered.
  
  --local t = {}
  t.act = "login"
  t.name = cmdline.nick --"FuckingClod"
  t.pass = cmdline.pass --"87654132"
  t.challstr = chstr

  local data, body = post("http://play.pokemonshowdown.com/action.php", t)

  if data:sub(1,1) ~= "]" then
  	print("Error. Aborting.")
  	print(data)
  	os.exit()
  end

  local assertion = json.decode(data:sub(2, -1)).assertion

  send("|/trn " .. t.name .. ",0," .. assertion)
  print("Logged in, theoretically")--]]
end

--COMMANDS.challstr:register(challstring, "login")
COMMAND("challstr", challstring, "login")