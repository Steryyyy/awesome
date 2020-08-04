local a = {screen = screen}
local b = require("my.gears.table")
local c = require("my.gears.geometry").rectangle;
local d = require("my.gears.debug")
local e = {}
local f, g = nil, nil;
local h = 25.4;
local i, j;
local function k()
    if not j then
        local l, m = root.size()
        local l, n = root.size_mm()
        j = n ~= 0 and m * h / n
    end
    return j or 96
end
local function o(p, q)
    local r = nil;
    local s = p.geometry;
    if q.mm_width ~= 0 and q.mm_height ~= 0 then
        local t = s.width * h / q.mm_width;
        local u = s.height * h / q.mm_height;
        r = math.min(t, u, r or t)
    elseif f._get_xft_dpi() then
        r = f._get_xft_dpi()
    end
    return r or k()
end
local function v(p)
    local w, x, y, z = 0, math.huge, 0, math.huge;
    for l, A in pairs(p.outputs) do
        local r = o(p, A)
        A.dpi = r;
        w = math.max(w, r)
        x = math.min(x, r)
        if A.mm_width and A.mm_height then
            A.mm_size = math.sqrt(A.mm_width ^ 2 + A.mm_height ^ 2)
            A.inch_size = A.mm_size / h;
            y = math.max(y, A.mm_size)
            z = math.min(z, A.mm_size)
        end
    end
    if x == math.huge then
        x = k()
        w = x
    end
    local B = x;
    p.minimum_dpi = x;
    p.maximum_dpi = w;
    p.preferred_dpi = B;
    if z == math.huge then
        for l, A in pairs(p.outputs) do
            local s = A.geometry;
            if s then
                A.mm_size = math.sqrt(s.width ^ 2 + s.height ^ 2) / A.dpi;
                y = math.max(y, A.mm_size)
                z = math.min(z, A.mm_size)
            end
        end
        if z == math.huge then
            local s = p.geometry;
            local C = math.sqrt(s.width ^ 2 + s.height ^ 2) / w;
            y, z = C, C
        end
    end
    p.mm_minimum_size = z;
    p.mm_maximum_size = y;
    p.inch_minimum_size = z / h;
    p.inch_maximum_size = y / h;
    return w, x, B
end
local function D(E, F)
    b.diff_merge(E.outputs, F.outputs, function(A)
        return A.name or (A.mm_height or -7) * 9999 * (A.mm_width or 5) * 123
    end, b.crush)
end
local function G(H)
    if #f._viewports > 0 and not H then return f._viewports end
    local I = f._get_viewports()
    local l, J, K =
        b.diff_merge(f._viewports, I, function(L) return L.id end, D)
    for l, p in ipairs(f._viewports) do v(p) end
    assert(#f._viewports > 0 or #I == 0)
    return f._viewports, J, K
end
local function M(N)
    local p = N._private.viewport;
    if #f._viewports == 0 then f._viewports = G(false) end
    if not p then
        local O, P = nil, 0;
        for l, L in ipairs(f._viewports) do
            local Q = c.get_intersection(L.geometry, N.geometry)
            if Q.width * Q.height > P then
                O, P = L, Q.width * Q.height
            end
            if P == N.geometry.width * N.geometry.height then break end
        end
        if O then p, N._private.viewport = O, O end
    end
    if not p then
        d.print_warning("Screen " .. tostring(N) ..
                            " doesn't overlap a known physical monitor")
    end
end
function e.create_screen_handler(p)
    local s = p.geometry;
    local N = a.screen.fake_add(s.x, s.y, s.width, s.height, {_managed = true})
    M(N)
    N:emit_signal("request::desktop_decoration")
    N:emit_signal("request::wallpaper")
    N:emit_signal("added")
end
function e.remove_screen_handler(p)
    for N in a.screen do
        if N._private.viewport and N._private.viewport.id == p.id then
            N:fake_remove()
            return
        end
    end
end
function e.resize_screen_handler(E, F)
    for N in a.screen do
        if N._private.viewport and N._private.viewport.id == E.id then
            local R = F.geometry;
            N:fake_resize(R.x, R.y, R.width, R.height)
            N._private.viewport = F;
            return
        end
    end
end
function e._get_xft_dpi()
    if not i then
        i = tonumber(awesome.xrdb_get_value("", "Xft.dpi")) or false
    end
    return i
end
local function S(T)
    local U, V, W, X = math.huge, math.huge, 0, 0;
    for l, Y in ipairs(T) do
        local s = Y.geometry;
        U = math.min(U, s.x)
        W = math.max(W, s.x + s.width)
        V = math.min(V, s.y)
        X = math.max(X, s.y + s.height)
    end
    if #T > 1 then
        for Z, Y in ipairs(T) do
            local s = Y.geometry;
            if s.x == U and s.y == V and s.x + s.width == W and s.y + s.height ==
                X then
                table.remove(T, Z)
                break
            end
        end
    end
    return T
end
function e._get_viewports()
    assert(type(a.screen._viewports()) == "table")
    return S(a.screen._viewports())
end
local function _(N)
    if N._private.dpi or N._private.dpi_cache then
        return N._private.dpi or N._private.dpi_cache
    end
    if not N._private.viewport then M(N) end
    local r = f._get_xft_dpi() or
                  (N._private.viewport and N._private.viewport.preferred_dpi or
                      nil) or k()
    N._private.dpi_cache = g.autodpi and r or f._get_xft_dpi() or k()
    return N._private.dpi_cache
end
local function a0(N, r) N._private.dpi = r end
screen.connect_signal("request::create", e.create_screen_handler)
screen.connect_signal("request::remove", e.remove_screen_handler)
screen.connect_signal("request::resize", e.resize_screen_handler)
a.screen.connect_signal("scanned", function()
    if a.screen.count() == 0 then
        if #f._get_viewports() == 0 then a.screen._scan_quiet() end
        local a1 = f._get_viewports()
        if #a1 > 0 then
            for l, p in ipairs(a1) do e.create_screen_handler(p) end
        else
            a.screen.fake_add(0, 0, 640, 480)
        end
        assert(a.screen.count() > 0, "Creating screens failed")
    end
end)
a.screen.connect_signal("property::_viewports", function(L)
    if a.screen.automatic_factory then return end
    assert(#L > 0)
    local l, a2, a3 = G(true)
    local a4 = {}
    for a5, p in ipairs(a3) do
        local a6, a7, a8 = {}, 0, nil;
        for Z, a9 in ipairs(a2) do
            local Q = c.get_intersection(p.geometry, a9.geometry)
            if Q.width * Q.height > a7 then
                a7, a8, a6 = Q.width * Q.height, Z, a9
            end
        end
        if a6 and a7 > 0 then
            table.insert(a4, {a3[a5], a2[a8]})
            a3[a5] = nil;
            table.remove(a2, a8)
        end
    end
    b.from_sparse(a3)
    for N in a.screen do N._private.dpi_cache = nil end
    a.screen.emit_signal("property::viewports", f._get_viewports())
    for l, p in ipairs(a2) do
        a.screen.emit_signal("request::create", p,
                             {context = "viewports_changed"})
    end
    for l, aa in ipairs(a4) do
        a.screen.emit_signal("request::resize", aa[1], aa[2],
                             {context = "viewports_changed"})
    end
    for l, p in ipairs(a3) do
        a.screen.emit_signal("request::remove", p,
                             {context = "viewports_changed"})
    end
end)
return function(screen, ab)
    f, g = screen, ab;
    f._viewports = {}
    b.crush(f, e, true)
    f.object.set_dpi = a0;
    f.object.get_dpi = _;
    for l, ac in ipairs {
        "minimum_dpi", "maximum_dpi", "mm_maximum_width", "mm_minimum_width",
        "inch_maximum_width", "inch_minimum_width", "preferred_dpi"
    } do
        screen.object["get_" .. ac] = function(N)
            if not N._private.viewport then M(N) end
            local L = N._private.viewport or {}
            return L[ac] or nil
        end
    end
end
