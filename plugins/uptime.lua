local first = true
local startTime = 0

local onFirstJoin = function(arg)
	if not first then return end
	startTime = os.time()
	first = true
end

local uptime = function(nick, target)
	local dt = os.time() - startTime
	local date = os.date("*t", dt)
	date.day = date.day - 1
	local days = date.day > 0 and date.day .. " days, " or ""
	local hours = date.hour > 0 and date.hour .. " hours, " or ""
	local minutes = date.min > 0 and date.min .. " minutes, " or ""
	local seconds = date.sec > 0 and date.sec .. " seconds, " or ""

	local reply = "Uptime: " .. days .. hours .. minutes .. seconds
	reply = reply:sub(1, -3)

	if target == "##PM" then
		sendPM(nick:trueNick(), reply)
	else
		send(target .. "|" .. reply)
	end
end

COMMAND("updateuser", onFirstJoin, "uptime")
command("uptime", uptime, "uptime")
