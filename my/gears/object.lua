local setmetatable = setmetatable;
local pairs = pairs;
local type = type;
local error = error;
local a = require("my.gears.object.properties")
local b = {properties = a, mt = {}}
local function c(d)
    if type(d) ~= "table" or type(d._signals) ~= "table" then
        error("called on non-object")
    end
end
local function e(d, f)
    c(d)
    if not d._signals[f] then
        assert(type(f) == "string", "name must be a string, got: " .. type(f))
        d._signals[f] = {strong = {}, weak = setmetatable({}, {__mode = "kv"})}
    end
    return d._signals[f]
end

function b:connect_signal(f, g)
    assert(type(g) == "function",
           "callback must be a function, got: " .. type(g))
    local h = e(self, f)
    assert(h.weak[g] == nil,
           "Trying to connect a strong callback which is already connected weakly")
    h.strong[g] = true
end
function b:_connect_everything(i) table.insert(self._global_receivers, i) end
local function j(g)
    if _VERSION <= "Lua 5.1" then
        local k = newproxy(true)
        getmetatable(k).__gc = function() end;
        local l = "_secret_key_used_by_gears_object_in_Lua51"
        local m = getfenv(g)
        if m[l] then
            table.insert(m[l], k)
        else
            local n = {[l] = {k}}
            setmetatable(n, {__index = m, __newindex = m})
            setfenv(g, n)
        end
        assert(_G[l] == nil, "Something broke, things escaped to _G")
        return k
    end
    return g
end
function b:weak_connect_signal(f, g)
    assert(type(g) == "function",
           "callback must be a function, got: " .. type(g))
    local h = e(self, f)
    assert(h.strong[g] == nil,
           "Trying to connect a weak callback which is already connected strongly")
    h.weak[g] = j(g)
end
function b:disconnect_signal(f, g)
    local h = e(self, f)
    h.weak[g] = nil;
    h.strong[g] = nil
end
function b:emit_signal(f, ...)
    local h = e(self, f)
    for g in pairs(h.strong) do g(self, ...) end
    for g in pairs(h.weak) do g(self, ...) end
    for o, g in ipairs(self._global_receivers) do g(f, self, ...) end
end
function b._setup_class_signals(p, q)
    q = q or {}
    local r = {}
    function p.connect_signal(f, g)
        assert(f)
        r[f] = r[f] or {}
        table.insert(r[f], g)
    end
    if q.allow_chain_of_responsibility then
        function p._emit_signal_if(f, s, ...)
            assert(f)
            for o, g in pairs(r[f] or {}) do
                if s(...) then return end
                g(...)
            end
        end
    end
    function p.emit_signal(f, ...)
        assert(f)
        for o, g in pairs(r[f] or {}) do g(...) end
    end
    function p.disconnect_signal(f, g)
        for t, u in ipairs(r[f] or {}) do
            if u == g then
                table.remove(r[f], t)
                return true
            end
        end
        return false
    end
    return r
end
local function v(self, l)
    local w = rawget(self, "_class")
    if rawget(self, "get_" .. l) then
        return rawget(self, "get_" .. l)(self)
    elseif w and w["get_" .. l] then
        return w["get_" .. l](self)
    elseif w then
        return w[l]
    end
end
local function x(self, l, y)
    local w = rawget(self, "_class")
    if rawget(self, "set_" .. l) then
        return rawget(self, "set_" .. l)(self, y)
    elseif w and w["set_" .. l] then
        return w["set_" .. l](self, y)
    elseif rawget(self, "_enable_auto_signals") then
        local z = w[l] ~= y;
        w[l] = y;
        if z then self:emit_signal("property::" .. l, y) end
    elseif not rawget(self, "get_" .. l) and not (w and w["get_" .. l]) then
        return rawset(self, l, y)
    else
        error("Cannot set '" .. tostring(l) .. "' on " .. tostring(self) ..
                  " because it is read-only")
    end
end
local function A(q)
    q = q or {}
    local B = {}
    assert(not (q.enable_auto_signals and q.enable_properties ~= true))
    for t, u in pairs(b) do if type(u) == "function" then B[t] = u end end
    B._signals = {}
    B._global_receivers = {}
    local C = {}
    B._class = q.class;
    B._enable_auto_signals = q.enable_auto_signals;
    if q.enable_auto_signals then
        B._class = B._class and setmetatable({}, {__index = q.class}) or {}
    end
    if q.enable_properties then
        C.__index = v;
        C.__newindex = x
    elseif q.class then
        C.__index = B._class
    end
    return setmetatable(B, C)
end
function b.mt.__call(o, ...) return A(...) end
function b.modulename(D)
    return debug.getinfo(D, "S").source:gsub(".*/lib/", ""):gsub("/", "."):gsub(
               "%.lua", "")
end
return setmetatable(b, b.mt)
