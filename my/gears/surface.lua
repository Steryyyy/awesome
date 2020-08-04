local setmetatable = setmetatable;
local type = type;
local a = {awesome = awesome}
local b = require("lgi").cairo;
local c = require("lgi").GdkPixbuf;
local d = nil;
local e = require("my.gears.debug")
local f = require("my.wibox.hierarchy")
local g, h, i = string.match(require('lgi.version'), '(%d)%.(%d)%.(%d)')
if tonumber(g) <= 0 and
    (tonumber(h) < 8 or tonumber(h) == 8 and tonumber(i) < 0) then
    error("lgi too old, need at least version 0.8.0")
end
local j = {mt = {}}
local k = setmetatable({}, {__mode = 'v'})
local function l(m)
    if type(m) == 'nil' then return b.ImageSurface(b.Format.ARGB32, 0, 0) end
    return m
end
function j.load_uncached_silently(n, o)
    if not n then return l(o) end
    if b.Surface:is_type_of(n) then return n end
    if type(n) == "string" then
        local p, q = c.Pixbuf.new_from_file(n)
        if not p then return l(o), tostring(q) end
        n = a.awesome.pixbuf_to_surface(p._native, n)
        if b.Surface:is_type_of(n) then return n end
    end
    return b.Surface(n, true)
end
function j.load_silently(n, o)
    if type(n) == "string" then
        local r = k[n]
        if r then return r end
        local s, q = j.load_uncached_silently(n, o)
        if not q then k[n] = s end
        return s, q
    end
    return j.load_uncached_silently(n, o)
end
local function t(n, u)
    if type(n) == 'nil' then return l() end
    local s, q = u(n, false)
    if s then return s end
    e.print_error(debug.traceback("Failed to load '" .. tostring(n) .. "': " ..
                                      tostring(q)))
    return l()
end
function j.load_uncached(n) return t(n, j.load_uncached_silently) end
function j.load(n) return t(n, j.load_silently) end
function j.mt.__call(v, ...) return j.load(...) end
function j.get_size(w)
    local x = b.Context(w)
    local y, z, A, B = x:clip_extents()
    return A - y, B - z
end
function j.duplicate_surface(C)
    C = j.load(C)
    local x = b.Context(C)
    local y, z, A, B = x:clip_extents()
    local s = C:create_similar(C.content, A - y, B - z)
    x = b.Context(s)
    x:set_source_surface(C, 0, 0)
    x.operator = b.Operator.SOURCE;
    x:paint()
    return s
end
function j.load_from_shape(D, E, F, G, H, ...)
    d = d or require("my.gears.color")
    local I = b.ImageSurface(b.Format.ARGB32, D, E)
    local x = b.Context(I)
    x:set_source(d(H or "#00000000"))
    x:paint()
    x:set_source(d(G or "#000000"))
    F(x, D, E, ...)
    x:fill()
    return I
end
function j.apply_shape_bounding(J, F, ...)
    local K = J:geometry()
    local I = b.ImageSurface(b.Format.A1, K.width, K.height)
    local x = b.Context(I)
    x:set_operator(b.Operator.CLEAR)
    x:set_source_rgba(0, 0, 0, 1)
    x:paint()
    x:set_operator(b.Operator.SOURCE)
    x:set_source_rgba(1, 1, 1, 1)
    F(x, K.width, K.height, ...)
    x:fill()
    J.shape_bounding = I._native;
    I:finish()
end

return setmetatable(j, j.mt)
