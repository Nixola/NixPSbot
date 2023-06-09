local lines = {}
print = function(...)
	local args = {...}
	for i, arg in ipairs(args) do
		args[i] = tostring(arg)
	end
	lines[#lines + 1] = table.concat(args, "\t")
end

local lua = function(nick, target, ...)
	if not isMaster(nick) then sendPM(nick, "You can't control me") return end
	local s = table.concat({...}, " ")
	local res, err = loadstring(s)
	if not res then
		sendPM(nick, err)
		return
	end
	setfenv(res, _G)
	res, err = pcall(res)
	if not res then
		sendPM(nick, err)
		return
	end
	for i, line in ipairs(lines) do
		if target == "#PM" then
			sendPM(nick:trueNick(), line)
		else
			send(target .. "|" .. line)
		end
	end
	lines = {}
end

command("lua", lua, "lua")
