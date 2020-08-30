local a = {
    mouse = mouse,
    screen = screen,
    client = client,
    awesome = awesome,
    root = root
}
local b = require("my.gears.debug")
local c = require("my.gears.math")
local d = require("my.gears.object")
local e = require("my.gears.geometry").rectangle;
local function f(g) return g and a.screen[g] end
local client;
local screen = {object = {}}
local h = {}
h.padding = {}
local function i(j, k)
    return {
        x = j.x + (k.left or 0),
        y = j.y + (k.top or 0),
        width = j.width - (k.left or 0) - (k.right or 0),
        height = j.height - (k.top or 0) - (k.bottom or 0)
    }
end

function screen.object.get_square_distance(self, l, m)
    return e.get_square_distance(f(self).geometry, l, m)
end
function screen.getbycoord(l, m)
    local g, n = a.screen.primary, {}
    for o in a.screen do n[o] = o.geometry end
    g = e.get_closest_by_coord(n, l, m) or g;
    return g and g.index
end
local function filter(i)
if i.hidden or i.sticky or not i.focusable then return nil else return i end
end
function screen.focus(p)
    client = client or require("my.awful.client")
    if type(p) == "number" and p > a.screen.count() then p = screen.focused() end
    p = f(p)

    if p ~= screen.focused() then
a.mouse.coords({x = p.geometry.width/2 + p.geometry.x , y = p.geometry.height/2 + p.geometry.y })
    end
    local te =  {}
    for _,c in pairs(p.selected_tag:clients()
) do
    if te.fullscreen then
   te = {c}
   break
    end
    table.insert(te,filter(c))
    end

    local t = te[1]
    if t then
	    t:emit_signal("request::activate", "screen.focus", {raise = false})
    end
    return true
end

function screen.focus_relative(y)
    return screen.focus(c.cycle(a.screen.count(), screen.focused().index + y))
end
function screen.object.get_tiling_area(g)
    return g:get_bounding_geometry{honor_padding = true, honor_workarea = true}
end

function screen.object.get_padding(self)
    local A = h.padding[self] or {}
    return {
        left = A.left or 0,
        right = A.right or 0,
        top = A.top or 0,
        bottom = A.bottom or 0
    }
end
function screen.object.set_padding(self, z)
    if type(z) == "number" then
        z = {left = z, right = z, top = z, bottom = z}
    end
    self = f(self)
    if z then
        h.padding[self] = z;
        self:emit_signal("padding")
    end
end
function screen.object.get_outputs(g)
    local B = {}
    local C = g._custom_outputs or
                  (g._private.viewport and g._private.viewport.outputs or
                      g._outputs)
    for D, E in ipairs(C) do B[E.name or D] = E end
    return B
end
function screen.object.set_outputs(self, C)
    self._custom_outputs = C;
    self:emit_signal("property::outputs", screen.object.get_outputs(self))
end
a.screen.connect_signal("property::_outputs", function(g)
    if not g._custom_outputs then
        g:emit_signal("property::outputs", screen.object.get_outputs(g))
    end
end)
function screen.preferred(t)
    return a.awesome.startup and t.screen or screen.focused()
end
function screen.focused(F)
    F = F or screen.default_focused_args or {}
    return f(F.client and a.client.focus and a.client.focus.screen or
                 a.mouse.screen)
end
function screen.object.get_bounding_geometry(self, F)
    F = F or {}
    if F.tag then self = F.tag.screen end
    self = f(self or a.mouse.screen)
    local j = F.bounding_rect or F.parent and F.parent:geometry() or
                  self[F.honor_workarea and "workarea" or "geometry"]
    if not F.parent and not F.bounding_rect and F.honor_padding then
        local z = self.padding;
        j = i(j, z)
    end
    if F.margins then
        j = i(j, type(F.margins) == "table" and F.margins or
                  {
                left = F.margins,
                right = F.margins,
                top = F.margins,
                bottom = F.margins
            })
    end
    return j
end
function screen.object.get_clients(g, G)
    local H = a.client.get(g, G == nil and true or G)
    local I = {}
    for J, t in pairs(H) do if t:isvisible() then table.insert(I, t) end end
    return I
end
function screen.object.get_hidden_clients(g)
    local H = a.client.get(g, true)
    local I = {}
    for J, t in pairs(H) do if not t:isvisible() then table.insert(I, t) end end
    return I
end
function screen.object.get_all_clients(g, G)
    return a.client.get(g, G == nil and true or G)
end
function screen.object.get_tiled_clients(g, G)
    local K = g:get_clients(G)
    local L = {}
    for J, t in pairs(K) do
        if not t.floating and not t.fullscreen and not t.maximized_vertical and
            not t.maximized_horizontal then table.insert(L, t) end
    end
    return L
end
function screen.connect_for_each_screen(M)
    for g in a.screen do M(g) end
    a.screen.connect_signal("added", M)
end

function screen.object.get_tags(g, N)
    local O = {}
    for J, P in ipairs(a.root.tags()) do
        if f(P.screen) == g then table.insert(O, P) end
    end
    if not N then
        table.sort(O, function(Q, R)
            return (Q.index or math.huge) < (R.index or math.huge)
        end)
    end
    return O
end
function screen.object.get_selected_tags(g)
    local O = screen.object.get_tags(g, true)
    local S = {}
    for J, P in pairs(O) do if P.selected then S[#S + 1] = P end end
    return S
end
function screen.object.get_selected_tag(g)
    return screen.object.get_selected_tags(g)[1]
end
--[[
local function T(U, V)
    local W = 0;
    for J, X in ipairs(U) do W = W + X end
    local B = {}
    local Y = 0;
    for D, X in ipairs(U) do
        B[D] = X * 100 / W;
        B[D] = math.floor(V * B[D] * 0.01)
        Y = Y + B[D]
    end
    B[#B] = B[#B] + V - Y;
    return B
end
function screen.object.split(g, U, Z, _)
    g = f(g)
    _ = _ or g.geometry;
    U = U or {50, 50}
    Z = Z or (_.height > _.width and "vertical" or "horizontal")
    assert(Z == "horizontal" or Z == "vertical")
    assert(not g or g.valid)
    assert(#U >= 2)
    local a0, B = T(U, Z == "horizontal" and _.width or _.height), {}
    assert(#a0 >= 2)
    if g then
        if Z == "horizontal" then
            g:fake_resize(_.x, _.y, a0[1], _.height)
        else
            g:fake_resize(_.x, _.y, _.width, a0[1])
        end
        table.insert(B, g)
    end
    local q = _[Z == "horizontal" and "x" or "y"] + (g and a0[1] or 0)
    for D = 2, #a0 do
        local a1;
        if Z == "horizontal" then
            a1 = a.screen.fake_add(q, _.y, a0[D], _.height)
        else
            a1 = a.screen.fake_add(_.x, q, _.width, a0[D])
        end
        table.insert(B, a1)
        if g then
            a1._private.viewport = g._private.viewport;
            if not a1._private.viewport then a1.outputs = g.outputs end
        end
        q = q + a0[D]
    end
    return B
end--]]
function screen.set_auto_dpi_enabled(a2)
    for g in a.screen do g._private.dpi_cache = nil end
    h.autodpi = a2
end
require("my.awful.screen.dpi")(screen, h)
a.screen.connect_signal("_added", function(g)
    if g._managed ~= "Lua" then
        g:emit_signal("added")


    end
end)

a.screen.connect_signal("request::desktop_decoration::connected", function(a4)
    if a.screen.automatic_factory then for g in a.screen do a4(g) end end
end)

d.properties(a.screen, {
    getter_class = screen.object,
    setter_class = screen.object,
    auto_emit = true
})
return screen
