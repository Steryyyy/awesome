
local b = require("my.awful.screen")
local c = require("my.beautiful")
local d = require("my.gears.math")
local e = require("my.gears.object")
local f = require("my.gears.timer")
local g = require("my.gears.table")
local h = nil;
local pairs = pairs;
local ipairs = ipairs;
local table = table;
local setmetatable = setmetatable;
local i = {
    tag = tag,
    screen = screen,
    mouse = mouse,
    client = client,
    root = root
}
local function j(k) return k and i.screen[k] end
local tag = {object = {}, mt = {}}


local m = {}
m.gap = 0;
m.gap_single_client = true;
m.master_fill_policy = "expand"
m.master_width_factor = 0.5;
m.master_count = 1;
m.column_count = 1;
local function n(o)
    local p = {}
    for q, r in ipairs(root.tags()) do
        if j(r.screen) == o then table.insert(p, r) end
    end
    return p
end
local function s(self)
    local t = tag.getproperty(self, "_custom_layouts")
    if not t then
        t = {}
        tag.setproperty(self, "_custom_layouts", t)
    end
    return t
end
local function u(self, v, w)
    if not w then return end
    h = h or require("my.awful.layout")
    local x = tag.getproperty(self, "_layouts")
    local y = v and g.hasitem(x or {}, v) or nil;
    if x and y and v ~= w then
        assert(type(y) == 'number')
        x[y] = w;
        self:emit_signal("property::layouts")
        return
    end
    if x and not y then
        table.insert(x, w)
        self:emit_signal("property::layouts")
        return
    end
    y = v and g.hasitem(h.layouts, v) or nil;
    local t = s(self)
    if y and v ~= w then
        local z = g.clone(h.layouts, false)
        z[y] = w;
        g.merge(z, t)
        self.layouts = z;
        return
    end
    if y then return end
    if g.hasitem(t, w) then return end
    table.insert(t, w)
    self:emit_signal("property::layouts")
end
function tag.object.set_index(self, A)
    local o = j(tag.getproperty(self, "screen"))
    local p = n(o)
    table.sort(p, function(B, C)
        local D, E = tag.getproperty(B, "index"), tag.getproperty(C, "index")
        return (D or math.huge) < (E or math.huge)
    end)
    if not A or A < 1 or A > #p then return end
    local F = nil;
    for G, r in ipairs(p) do
        if r == self then
            table.remove(p, G)
            F = G;
            break
        end
    end
    table.insert(p, A, self)
    for G = A < F and A or F, #p do
        local H = p[G]
        tag.object.set_screen(H, o)
        tag.setproperty(H, "index", G)
    end
end
function tag.object.get_index(I)
    local A = tag.getproperty(I, "index")
    if A then return A end
    local J = n(I.screen)
    for G, r in ipairs(J) do
        if r == I then
            tag.setproperty(r, "index", G)
            return G
        end
    end
end


function tag.add(S, T)
    local U = T or {}
    U.index = U.index or #n(U.screen) + 1;
    local V = i.tag {name = S}
    V._private.awful_tag_properties = {screen = U.screen, index = U.index}
    V.activated = true;
    for W, X in pairs(U) do
        if W == "clients" or tag.object[W] then
            V[W](V, X)
        else
            V[W] = X
        end
    end
    return V
end
function tag.new(Y, screen, Z)
    screen = j(screen or 1)
    local _ = not Z or Z.arrange and Z.name;
    local J = {}
    for a0, S in ipairs(Y) do
        local a1 = Z;
        if not _ then a1 = Z[a0] or Z[1] end
        table.insert(J, a0, tag.add(S, {screen = screen, layout = a1}))
        if a0 == 1 then J[a0].selected = true end
    end
    return J
end
function tag.find_fallback(screen, a2)
    local o = screen or b.focused()
    local r = a2 or o.selected_tags;
    for q, X in pairs(o.tags) do if not g.hasitem(r, X) then return X end end
end





function tag.find_by_name(k, S)
    local J = k and k.tags or root.tags()
    for q, r in ipairs(J) do if S == r.name then return r end end
end
function tag.object.set_screen(r, k)
    k = j(k or b.focused())
    local af = r.selected;
    local ag = j(tag.getproperty(r, "screen"))
    if k == ag then return end
    tag.setproperty(r, "index", nil)
    tag.setproperty(r, "screen", k)
    if k then tag.setproperty(r, "index", #k:get_tags(true)) end
    for q, a8 in ipairs(r:clients()) do
        a8.screen = k;
        a8:tags({r})
    end
    if ag then
        for G, ah in ipairs(ag.tags) do tag.setproperty(ah, "index", G) end

    end
end




function tag.object.set_master_width_factor(r, aj)
    if aj >= 0 and aj <= 1 then
        tag.setproperty(r, "mwfact", aj)
        tag.setproperty(r, "master_width_factor", aj)
    end
end
function tag.object.get_master_width_factor(r)
    return tag.getproperty(r, "master_width_factor") or c.master_width_factor or
               m.master_width_factor
end

function tag.incmwfact(ak, r)
    r = r or r or b.focused().selected_tag;
    tag.object.set_master_width_factor(r,
                                       tag.object.get_master_width_factor(r) +
                                           ak)
end

function tag.object.set_layout(r, Z)
    local al = nil;
    if type(Z) == "function" or type(Z) == "table" and getmetatable(Z) and
        getmetatable(Z).__call then
        if not r.dynamic_layout_cache then r.dynamic_layout_cache = {} end
        local am = r.dynamic_layout_cache[Z] or Z(r)
        if tag.getproperty(r, "screen").selected_tag == r and am.wake_up then
            am:wake_up()
        end
        if am.is_dynamic then r.dynamic_layout_cache[Z] = am end
        al = Z;
        Z = am
    end
    tag.setproperty(r, "layout", Z)
    u(r, al or Z, Z)
    return Z
end
function tag.object.get_layouts(self)
    local x = tag.getproperty(self, "_layouts")
    if x then return x end
    h = h or require("my.awful.layout")
    local t = s(self)
    if #t == 0 and not tag.getproperty(self, "_layouts_requested") then
        tag.setproperty(self, "_layouts_requested", true)
        local an = #t;
        self:emit_signal("request::layouts", "my.awful", {})
        if #t > an then
            tag.setproperty(self, "_layouts", g.clone(t, false))
            return tag.getproperty(self, "_layouts")
        end
        return tag.object.get_layouts(self)
    end
    return #t > 0 and g.merge(g.clone(t, false), h.layouts) or h.layouts
end
function tag.object.set_layouts(self, ao)
    tag.setproperty(self, "_custom_layouts", {})
    tag.setproperty(self, "_layouts", g.clone(ao, false))
    local ap = tag.getproperty(self, "layout")
    u(self, ap, ap)
    self:emit_signal("property::layouts")
end
function tag.object.append_layout(self, Z)
    tag.setproperty(self, "_layouts_requested", true)
    local t = tag.getproperty(self, "_layouts")
    if not t then t = s(self) end
    table.insert(t, Z)
    self:emit_signal("property::layouts")
end
function tag.object.append_layouts(self, ao)
    tag.setproperty(self, "_layouts_requested", true)
    local t = tag.getproperty(self, "_layouts")
    if not t then t = s(self) end
    for q, a1 in ipairs(ao) do table.insert(t, a1) end
    self:emit_signal("property::layouts")
end
function tag.object.remove_layout(self, Z)
    local t = tag.getproperty(self, "_layouts")
    if not t then t = s(self) end
    local y = {}
    for W, a1 in ipairs(t) do if a1 == Z then table.insert(y, W) end end
    if #y > 0 then
        for G = #y, 1, -1 do table.remove(t, G) end
        self:emit_signal("property::layouts")
    end
    return #y > 0
end
function tag.object.get_layout(r)
    local a1 = tag.getproperty(r, "layout")
    if a1 then return a1 end
    local ao = tag.getproperty(r, "_layouts")
    return ao and ao[1] or require("my.awful.layout.suit.floating")
end

function tag.object.set_gap(r, ar)
    if ar >= 0 then tag.setproperty(r, "useless_gap", ar) end
end
function tag.object.get_gap(r)
    return tag.getproperty(r, "useless_gap") or c.useless_gap or m.gap
end

function tag.incgap(ak, r)
    r = r or r or b.focused().selected_tag;
    tag.object.set_gap(r, tag.object.get_gap(r) + ak)
end
function tag.object.set_gap_single_client(r, as)
    tag.setproperty(r, "gap_single_client", as == true)
end
function tag.object.get_gap_single_client(r)
    local at = tag.getproperty(r, "gap_single_client")
    if at ~= nil then return at end
    at = c.gap_single_client;
    if at ~= nil then return at end
    return m.gap_single_client
end
function tag.object.get_master_fill_policy(r)
    return tag.getproperty(r, "master_fill_policy") or c.master_fill_policy or
               m.master_fill_policy
end

function tag.togglemfpol(r)
    r = r or b.focused().selected_tag;
    if tag.getmfpol(r) == "expand" then
        tag.setproperty(r, "master_fill_policy", "master_width_factor")
    else
        tag.setproperty(r, "master_fill_policy", "expand")
    end
end

function tag.object.set_master_count(r, aw)
    if aw >= 0 then
        tag.setproperty(r, "nmaster", aw)
        tag.setproperty(r, "master_count", aw)
    end
end
function tag.object.get_master_count(r)
    return tag.getproperty(r, "master_count") or c.master_count or
               m.master_count
end


function tag.incnmaster(ak, r, ax)
    r = r or b.focused().selected_tag;
    if ax then
        local screen = j(tag.getproperty(r, "screen"))
        local ay = #screen.tiled_clients;
        local aw = tag.object.get_master_count(r)
        if aw > ay then aw = ay end
        local az = aw + ak;
        if az > ay then az = ay end
        tag.object.set_master_count(r, az)
    else
        tag.object.set_master_count(r, tag.object.get_master_count(r) + ak)
    end
end

function tag.object.set_column_count(r, aB)
    if aB >= 1 then
        tag.setproperty(r, "ncol", aB)
        tag.setproperty(r, "column_count", aB)
    end
end
function tag.object.get_column_count(r)
    return tag.getproperty(r, "column_count") or c.column_count or
               m.column_count
end

function tag.incncol(ak, r, ax)
    r = r or b.focused().selected_tag;
    if ax then
        local screen = j(tag.getproperty(r, "screen"))
        local ay = #screen.tiled_clients;
        local aw = tag.object.get_master_count(r)
        local aC = ay - aw;
        local aB = tag.object.get_column_count(r)
        if aB > aC then aB = aC end
        local aD = aB + ak;
        if aD > aC then aD = aC end
        tag.object.set_column_count(r, aD)
    else
        tag.object.set_column_count(r, tag.object.get_column_count(r) + ak)
    end
end
function tag.viewnone(screen)
    screen = screen or b.focused()
    local J = screen.tags;
    for q, r in pairs(J) do r.selected = false end
end

function tag.object.view_only(self)
    local J = self.screen.tags;
    for q, ae in pairs(J) do if ae ~= self then ae.selected = false end end
    self.selected = true;
    i.screen[self.screen]:emit_signal("tag::history::update")
end

function tag.viewmore(J, screen, aF)
    aF = aF or #J;
    local aG = 0;
    screen = j(screen or b.focused())
    local aH = screen.tags;
    for q, ae in ipairs(aH) do
        if not g.hasitem(J, ae) then
            ae.selected = false
        elseif ae.selected then
            aG = aG + 1
        end
    end
    for q, ae in ipairs(J) do
        if aG == 0 and aF == 0 then
            ae.selected = true;
            break
        end
        if aG >= aF then break end
        if not ae.selected then
            aG = aG + 1;
            ae.selected = true
        end
    end
    screen:emit_signal("tag::history::update")
end
function tag.viewtoggle(r)
    r.selected = not r.selected;
    i.screen[tag.getproperty(r, "screen")]:emit_signal("tag::history::update")
end
function tag.getdata(ae) return ae._private.awful_tag_properties end
function tag.getproperty(ae, ai)
    if not ae then return end
    if ae._private.awful_tag_properties then
        return ae._private.awful_tag_properties[ai]
    end
end
function tag.setproperty(ae, ai, aI)
    if not ae._private.awful_tag_properties then
        ae._private.awful_tag_properties = {}
    end
    if ae._private.awful_tag_properties[ai] ~= aI then
        ae._private.awful_tag_properties[ai] = aI;
        ae:emit_signal("property::" .. ai)
    end
end

local function aJ(screen, aK, aL)
    screen = j(screen)
    i.tag.connect_signal(aK, function(ae)
        if j(tag.getproperty(ae, "screen")) == screen then aL(ae) end
    end)
end
function tag.attached_connect_signal(screen, ...)
    if screen then
        aJ(screen, ...)
    else
        i.tag.connect_signal(...)
    end
end
i.client.connect_signal("property::screen", function(a8)
    f.delayed_call(function()
        if not a8.valid then return end
        local J, aM = a8:tags(), {}
        for q, r in ipairs(J) do
            if r.screen == a8.screen then table.insert(aM, r) end
        end
        if #aM == 0 then
            a8:emit_signal("request::tag", nil, {reason = "screen"})
        elseif #aM < #J then
            a8:tags(aM)
        end
    end)
end)
i.tag.connect_signal("request::select", tag.object.view_only)

f.delayed_call(function()
    for k in i.screen do k:emit_signal("tag::history::update") end
end)
i.screen.connect_signal("removed", function(k)
    for q, r in pairs(k.tags) do r:emit_signal("request::screen", "removed") end
    for q, r in pairs(k.tags) do r:emit_signal("removal-pending") end
    for q, a8 in pairs(i.client.get(k)) do
        a8:emit_signal("request::tag", nil, {reason = "screen-removed"})
    end
    local aT = nil;
    for aU in i.screen do
        if #aU.tags > 0 then
            aT = aU.tags[1]
            break
        end
    end

    for q, r in pairs(k.tags) do
        r.activated = false;
        if r._private.awful_tag_properties then
            r._private.awful_tag_properties.screen = nil
        end
    end

end)
function tag.mt:__call(...) return tag.new(...) end
e.properties(i.tag, {
    getter_class = tag.object,
    setter_class = tag.object,
    getter_fallback = tag.getproperty,
    setter_fallback = tag.setproperty
})
return setmetatable(tag, tag.mt)
