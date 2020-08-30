local a = {awesome = awesome}
local ipairs = ipairs;
local pairs = pairs;
local setmetatable = setmetatable;
local table = table;
local tonumber = tonumber;
local b = debug.traceback;
local unpack = unpack or table.unpack;
local c = require("lgi").GLib;
local d = require("my.gears.object")
local e = require("my.gears.protected_call")
local f = require("my.gears.debug")
local g = {mt = {}}
function g:start()
    if self.data.source_id ~= nil then
        f.print_error(b("timer already started"))
        return
    end
    self.data.source_id = c.timeout_add(c.PRIORITY_DEFAULT,
                                        self.data.timeout * 1000, function()
        e(self.emit_signal, self, "timeout")
        return true
    end)
    self:emit_signal("start")
end
function g:stop()
    if self.data.source_id == nil then
        f.print_error(b("timer not started"))
        return
    end
    c.source_remove(self.data.source_id)
    self.data.source_id = nil;
    self:emit_signal("stop")
end
function g:again()
    if self.data.source_id ~= nil then self:stop() end
    self:start()
end
local h = {
    __index = function(self, i)
        if i == "timeout" then
            return self.data.timeout
        elseif i == "started" then
            return self.data.source_id ~= nil
        end
        return g[i]
    end,
    __newindex = function(self, i, j)
        if i == "timeout" then
            self.data.timeout = tonumber(j)
            self:emit_signal("property::timeout", j)
        end
    end
}
function g.new(k)
    k = k or {}
    local l = d()
    l.data = {timeout = 10}
    setmetatable(l, h)
    for m, n in pairs(k) do l[m] = n end
    if k.autostart then l:start() end
    if k.callback then
        if k.call_now then k.callback() end
        l:connect_signal("timeout", k.callback)
    end
    if k.single_shot then
        l:connect_signal("timeout", function() l:stop() end)
    end
    return l
end
function g.start_new(o, p)
    local q = g.new({timeout = o})
    q:connect_signal("timeout", function()
        local r = e(p)
        if not r then q:stop() end
    end)
    q:start()
    return q
end
function g.weak_start_new(o, p)
    local s = setmetatable({}, {__mode = "v"})
    s.callback = p;
    return g.start_new(o, function()
        local t = s.callback;
        if t then return t() end
    end)
end
local u = {}
function g.run_delayed_calls_now()
    for v, p in ipairs(u) do e(unpack(p)) end
    u = {}
end
function g.delayed_call(p, ...)
    assert(type(p) == "function",
           "callback must be a function, got: " .. type(p))
    table.insert(u, {p, ...})
end
a.awesome.connect_signal("refresh", g.run_delayed_calls_now)
function g.mt.__call(v, ...) return g.new(...) end
return setmetatable(g, g.mt)
