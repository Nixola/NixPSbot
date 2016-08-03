local http = require "socket.http"

return {
function(url, t)
  local s = "?"
  for i, v in pairs(t) do
  	local item = i:encode()
  	if type(v) == "string" or type(v) == "number" then
  	  item = item .. "=" .. tostring(v):encode()
  	end
  	item = item .. "&"
  	s = s .. item
  end
  s = s:match("^(.-)%&$")
  return http.request(url .. s), url..s
end,
function(url, body)
  local b = ""
  for i, v in pairs(body) do
  	local p = (b == "") and "" or "&"
  	b = b .. p .. i:encode() .. "=" .. v:encode()
  end
  return http.request(url, b), b
end}