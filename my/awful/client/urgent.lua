local a = {}
local b = {client = client}
local client;
do
    client = setmetatable({}, {
        __index = function(c, d)
            client = require("my.awful.client")
            return client[d]
        end,
        __newindex = error
    })
end
local e = setmetatable({}, {__mode = 'k'})
function a.get()
    if #e > 0 then
        return e
    else
	    return {}

    end
end
function a.jumpto(h)
    local i = client.urgent.get()
    if i then i:jump_to(h) end
end
function a.add(i, j)
    if j == "urgent" and i.urgent then table.insert(e, i) end
end
function a.delete(i)
    for d, g in ipairs(e) do
        if i == g then
            table.remove(e, d)
            break
        end
    end
end
b.client.connect_signal("property::urgent", a.add)
b.client.connect_signal("focus", a.delete)
b.client.connect_signal("request::unmanage", a.delete)
return a
