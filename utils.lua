string.split = function(str, sep)
    local t = {}
    for p in str:gmatch(("([^%s])"):format(sep)) do
        t[#t+1] = p
    end
    return unpack(t)
end