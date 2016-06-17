local http = require "socket.http"

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

return function(url, body)
  local b = ""
  for i, v in pairs(body) do
  	local p = (b == "") and "" or "&"
  	b = b .. p .. url_encode(i) .. "=" .. url_encode(v)
  end
  return http.request(url, b), b
end