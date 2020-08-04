local a = require("my.awful.tag")

local ipairs = ipairs;
local math = math;
local c = {mouse = mouse, screen = screen}
local d = {}
d.resize_jump_to_corner = true;
local function e(f, g, h, i)
    local j = f.border_width;
    g, h = g - 2 * j - i, h - 2 * j - i;
    g, h = f:apply_size_hints(math.max(1, g), math.max(1, h))
    return g + 2 * j + i, h + 2 * j + i
end
local function k(l, m, n, o, p, q, i)
    local h = "height"
    local g = "width"
    local r = "x"
    local s = "y"
    if o == "top" or o == "bottom" then
        h = "width"
        g = "height"
        r = "y"
        s = "x"
    end
    local t = n[g] - (q.coord - n[r])
    local u = 0;
    local v = 1;
    local w = q.size;
    for f = q.first, q.last do
        local x = f - q.first + 1;
        local y = m[f].size_hints;
        local z = y["min_" .. g] or y["base_" .. g] or 0;
        w = math.max(z, w)
        if not p[x] then
            p[x] = v
        else
            v = math.min(p[x], v)
        end
        u = u + p[x]
    end
    w = math.max(1, math.min(w, t))
    local A = n[s]
    local B = 0;
    local C = n[h]
    for f = q.first, q.last do
        local D = {}
        local E = {}
        local x = f - q.first + 1;
        D[g] = w;
        D[h] = math.max(1, math.floor(C * p[x] / u))
        D[r] = q.coord;
        D[s] = A;
        l[m[f]] = D;
        E.width, E.height = e(m[f], D.width, D.height, i)
        A = A + E[h]
        C = C - E[h]
        u = u - p[x]
        B = math.max(B, E[g])
    end
    return B
end
local function F(G, o)
    local H = G.tag or c.screen[G.screen].selected_tag;
    o = o or "right"
    local g = "width"
    local r = "x"
    if o == "top" or o == "bottom" then
        g = "height"
        r = "y"
    end
    local l = G.geometries;
    local m = G.clients;
    local i = G.useless_gap;
    local I = math.min(H.master_count, #m)
    local J = math.max(#m - I, 0)
    local K = H.master_width_factor;
    local n = G.workarea;
    local L = H.column_count;
    local M = a.getdata(H).windowfact;
    if not M then
        M = {}
        a.getdata(H).windowfact = M
    end
    local A = n[r]
    local N = true;
    if o == "left" or o == "top" then N = false end
    local O = H.master_fill_policy == "expand"
    for P = 1, 2 do
        if N and I > 0 then
            local w = n[g]
            if J > 0 or not O then
                w = math.min(n[g] * K, n[g] - (A - n[r]))
            end
            if J == 0 and not O then A = A + (n[g] - w) / 2 end
            if not M[0] then M[0] = {} end
            A = A +
                    k(l, m, n, o, M[0],
                      {first = 1, last = I, coord = A, size = w}, i)
        end
        if not N and J > 0 then
            local Q = I;
            local R = n[g]
            if I > 0 and (o == "left" or o == "top") then
                R = n[g] - n[g] * K
            end
            for x = 1, L do
                local w = math.min((R - (A - n[r])) / (L - x + 1))
                local S = Q + 1;
                Q = Q + math.floor((#m - Q) / (L - x + 1))
                if not M[x] then M[x] = {} end
                A = A +
                        k(l, m, n, o, M[x],
                          {first = S, last = Q, coord = A, size = w}, i)
            end
        end
        N = not N
    end
end
function d.skip_gap(T, H) return T == 1 and H.master_fill_policy == "expand" end
d.right = {}
d.right.name = "tile"
d.right.arrange = F;
d.right.skip_gap = d.skip_gap;
d.left = {}
d.left.name = "tileleft"
d.left.skip_gap = d.skip_gap;
function d.left.arrange(U) return F(U, "left") end
d.bottom = {}
d.bottom.name = "tilebottom"
d.bottom.skip_gap = d.skip_gap;
function d.bottom.arrange(U) return F(U, "bottom") end
d.top = {}
d.top.name = "tiletop"
d.top.skip_gap = d.skip_gap;
function d.top.arrange(U) return F(U, "top") end
d.arrange = d.right.arrange;
d.name = d.right.name;
return d
