--local post = require "post"
--local json = require "rapidjson"

local challstring = function(chstr)

  local t = {}
  t.act      = "getassertion"
  t.userid   = credentials.nick:trueNick()
  t.pass     = credentials.password
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
    t.name = credentials.nick --t.userid
    t.userid = nil
    --t.pass = cmdline.pass
    local data, body = post("https://play.pokemonshowdown.com/action.php", t)
    if data:sub(1, 1) ~= "]" then
      print("Error. Aborting.")
      print(data)
      os.exit()
    end
    assertion = json.decode(data:sub(2, -1)).assertion
  end

  send("|/trn " .. (t.name or t.userid) .. ",0," .. assertion)

end

--COMMANDS.challstr:register(challstring, "login")
COMMAND("challstr", challstring, "login")
