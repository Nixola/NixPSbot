local post = require "post"

local json = require "rapidjson"

local challstring = function(chstr)
  
  local t = {}
  t.act = "login"
  t.name = "gzip"
  t.pass = "87654132"
  t.challstr = chstr

  local data = post("http://play.pokemonshowdown.com/action.php", t)

  if data:sub(1,1) ~= "]" then
  	print("Error. Aborting.")
  	print(data)
  	os.exit()
  end

  local assertion = json.decode(data:sub(2, -1)).assertion

  send("|/trn " .. t.name .. ",0," .. assertion)
end

commands.challstr:register(challstring, "challstr")