local setmetatable = setmetatable;
local ipairs = ipairs;
local a = {key = key, root = root, awesome = awesome}
local b = require("my.gears.math")
local c = require("my.gears.table")

local e = require("my.gears.object")
local key = {mt = {}, hotkeys = {}}
local f = setmetatable({}, {__mode = "k"})
function key:set_key(g) for h, i in ipairs(self) do i.key = g end end
function key:get_key() return self[1].key end
function key:set_modifiers(j)
    local k = b.subsets(key.ignore_modifiers)
    for g, l in ipairs(k) do self[g].modifiers = c.join(j, l) end
end
for h, m in ipairs {"on_press", "on_release", "name"} do
    key["get_" .. m] = function(self) return f[self][m] end;
    key["set_" .. m] = function(self, n) f[self][m] = n end
end
function key:trigger()
    local o = f[self]
    if o.on_press then o.on_press() end
    if o.on_release then o.on_release() end
end
function key:get_has_root_binding() return a.root.has_key(self) end
function key:get__is_awful_key() return true end
local function p(self, g)
    if key["get_" .. g] then return key["get_" .. g](self) end
    if type(key[g]) == "function" then return key[g] end
    local o = f[self]
    assert(o)
    return o[g]
end
local function q(self, g, n)
    if key["set_" .. g] then return key["set_" .. g](self, n) end
    local o = f[self]
    assert(o)
    o[g] = n
end
local r = {__index = p, __newindex = q}
key.ignore_modifiers = {"Lock", "Mod2"}
local function s(j, t, u, v, o)
    if type(v) == 'table' then
        o = v;
        v = nil
    end
    local w = {}
    local k = b.subsets(key.ignore_modifiers)
    for h, x in ipairs(t) do
        for h, l in ipairs(k) do
            local y = a.key {modifiers = c.join(j, l), key = x[1]}
            y._private._legacy_convert_to = w;
            y:connect_signal("press", function(h, ...)
                if w.on_press then
                    if x[2] ~= nil then
                        w.on_press(x[2], ...)
                    else
                        w.on_press(...)
                    end
                end
            end)
            y:connect_signal("release", function(h, ...)
                if w.on_release then
                    if x[2] ~= nil then
                        w.on_release(x[2], ...)
                    else
                        w.on_release(...)
                    end
                end
            end)
            w[#w + 1] = y
        end
    end
    o = o and c.clone(o) or {}
    o.mod = j;
    o.keys = t;
    o.on_press = u;
    o.on_release = v;
    o._is_capi_key = false;
    assert(not o.key or type(o.key) == "string")
    table.insert(key.hotkeys, o)
    o.execute = function(h)
        assert(#t == 1, "key:execute() makes no sense for groups")
        key.execute(j, t[1])
    end;
    f[w] = o;
    return setmetatable(w, r)
end
key.keygroups = {
    numrow = {},
    arrows = {
        {"Left", "Left"}, {"Right", "Right"}, {"Up", "Up"}, {"Down", "Down"}
    }
}
for z = 1, 10 do
    table.insert(key.keygroups.numrow, {"#" .. z + 9, z == 10 and 0 or z})
end
local function A(B)
    if not B.keygroup then return {{B.key}} end
    assert(not B.key,
           "Please provide either the `key` or `keygroup` property, not both")
    assert(key.keygroups[B.keygroup], "Please provide a valid keygroup")
    return key.keygroups[B.keygroup]
end
function key.new(B, C, u, v, o)
    if not C then
        assert(not (u or v or o), "Calling awful.key() requires a key name")
        local D = A(B)
        return s(B.modifiers, D, B.on_press, B.on_release, B)
    else
        return s(B, {{C}}, u, v, o)
    end
end
function key.match(C, E, F)
    if F ~= C.key then return false end
    local j = C.modifiers;
    for h, G in ipairs(j) do if not c.hasitem(E, G) then return false end end
    return #E == #j
end
function key.mt:__call(...) return key.new(...) end
e.properties(a.key, {auto_emit = true})
return setmetatable(key, key.mt)
