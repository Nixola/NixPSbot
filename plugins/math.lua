local mathEnv = setmetatable({tau = math.pi * 2, e = 2.71828182845904523536028747135266249775724709369995, ln = math.log, log = math.log10}, {__index = function(t, k) return rawget(t, k) or math[k] end})
mathEnv.math = mathEnv

local math

local mathPM = function(args)
  local sender, target, text = args:match("^(.-)|(.-)|(.+)$") 
  local rest = "00|" .. sender .. "|" .. text
  return math(rest, "#PM", 00)
end

math = function(rest, target, timestamp)
  local ts = rest:match("^(%d+)")
  rest = rest:match("^%d+|(.-)$")
  local nick, code = rest:match("^(.-)|(.+)$")
  if nick:trueNick() == cmdline.nick:trueNick() then return end
  if not code or #code == 0 then --[[sendNotice("Do you want me to guess the expression you wanna know the result of?", source)]] return end
  local blacklist = {'"', "'", "function", "%[%=*%[", "%.%.", "^true$", "^false$", "^not%s+[_a-zA-Z][_a-zA-Z0-9]*$"}
  for i, v in ipairs(blacklist) do
  	if code:match(v) then return end
  end
  if not code:match("^%=") then return end
  code = code:sub(2, -1)
  --if code:find '"' or code:find "'" or code:find '{' or code:find 'function' or code:match "%[%=*%[" or code:find '%.%.' then --[[sendNotice("You just WON'T hang me. Fuck you.", source)]] return end
  local expr, err = loadstring("return "..code)
  if not expr then --[[sendNotice(err, source)]] return end
  setfenv(expr, mathEnv)
  local results = {pcall(expr)}
  if not results[1] then --[[sendNotice(results[2], source)]] return end
  local maxN = table.maxn(results)
  for i = maxN, 1, -1 do
    if results[i] == nil then table.remove(results, i) end
  end
  if results[2] == nil then
    --sendNotice("Your expression has no result.", source)
    return
  end
  if #results == 2 then
    --reply(source, target, "= "..tostring(results[2])..".")
    if target == "#PM" then
      sendPM(nick:trueNick(), "= " .. tostring(results[2]) .. ".")
    else
      send(target .. "|= " .. tostring(results[2]) .. ".")
    end
  else 
    table.remove(results, 1)
    for i, v in ipairs(results) do
      results[i] = tostring(v)
    end
    --reply(source, target, "= " .. table.concat(results, ', ') .. ".")
    if target == "#PM" then
      sendPM(nick:trueNick(), "= " .. table.concat(results, ', ') .. ".")
    else
      send(target .. "|= " .. table.concat(results, ', ') .. ".")
    end
  end
  --return true
end

COMMAND("c:", math, "math")
COMMAND("pm", mathPM, "math")
