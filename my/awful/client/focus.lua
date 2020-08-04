local a = require("my.gears.geometry").rectangle;
local b = {screen = screen, client = client}
local screen;
do
    screen = setmetatable({}, {
        __index = function(c, d)
            screen = require("my.awful.screen")
            return screen[d]
        end,
        __newindex = error
    })
end
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
local e = {}
local function f(g) return g and b.screen[g] end
function e.byidx(h, i)
    local j = client.next(h, i)
    if j then
        j:emit_signal("request::activate", "client.focus.byidx", {raise = true})
    end
   
end
function e.byidx_global(h,i) 
    local j = client.next_global(h, i)
    if j then
        j:emit_signal("request::activate", "client.focus.byidx", {raise = true})
    end
end
function e.filter(i)
    if i.type == "desktop" or i.type == "dock" or i.type == "splash" or
        not i.focusable then return nil end
    return i
end


function e.bydirection(r, i, s)
    local q = i or b.client.focus;
    if q then
        local t = client.visible(q.screen, s)
        local u = {}
        for h, v in ipairs(t) do u[h] = v:geometry() end
        local j = a.get_in_direction(r, u, q:geometry())
        if j then
            t[j]:emit_signal("request::activate", "client.focus.bydirection",
                             {raise = false})
        end
    end
end
function e.global_bydirection(r, i, s)
    local q = i or b.client.focus;
    local w = f(q and q.screen or screen.focused())
    e.bydirection(r, q)
    if q == b.client.focus then
        screen.focus_bydirection(r, w)
        if w ~= f(screen.focused()) then
            local t = client.visible(screen.focused(), s)
            local u = {}
            for h, v in ipairs(t) do u[h] = v:geometry() end
            local j = a.get_in_direction(r, u, w.geometry)
            if j then
                t[j]:emit_signal("request::activate",
                                 "client.focus.global_bydirection",
                                 {raise = false})
            end
        end
    end
end
return e
