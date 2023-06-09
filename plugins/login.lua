--local post = require "post"
--local json = require "rapidjson"

local challstring = function(chstr)

  local t = {}
  t.act      = "getassertion"
  t.userid   = credentials.nick:trueNick()
  t.pass     = credentials.password
  t.challstr = chstr

  --[[
  local assertion, url = get("http://play.pokemonshowdown.com/action.php", t)
  print("LOG", assertion)

  if assertion:match("^;;.-") then
    print("Error. Could not log in.")
    print(assertion:match("^;;(.-)$"))
    os.exit()
  elseif assertion:find("\n") then
    print("Error. No response from server.")
    os.exit()
  elseif assertion == ";" then
  --]]
    t.act    = "login"
    t.act    = nil
    t.name   = credentials.nick --t.userid
    t.userid = nil

    local data, body = post("https://play.pokemonshowdown.com/api/login", t)
    if data:sub(1, 1) ~= "]" then
      print("Error. Aborting.")
      print(data)
      print("Leaving now.")
      os.exit()
    end
    print("LOG", data)
    assertion = json.decode(data:sub(2, -1)).assertion
--  end

  send("|/trn " .. (t.name or t.userid) .. ",0," .. assertion)

end

COMMAND("challstr", challstring)
