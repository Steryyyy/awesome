local ipairs = ipairs;
local math = math;
local a = {}
local function b(c, d)
    local e = c.workarea;
    local f = c.clients;
    if d == 'east' then
        e.width, e.height = e.height, e.width;
        e.x, e.y = e.y, e.x
    end
    if #f > 0 then
        local g, h;
        if #f == 2 then
            g, h = 1, 2
        else
            g = math.ceil(math.sqrt(#f))
            h = math.ceil(#f / g)
        end
        for i, j in ipairs(f) do
            i = i - 1;
            local k = {}
            local l, m;
            l = i % g;
            m = math.floor(i / g)
            local n, o;
            if i >= g * h - g then
                n = #f - (g * h - g)
                o = h
            else
                n = g;
                o = h
            end
            if l == n - 1 then
                k.height = e.height - math.ceil(e.height / n) * l;
                k.y = e.height - k.height
            else
                k.height = math.ceil(e.height / n)
                k.y = k.height * l
            end
            if m == o - 1 then
                k.width = e.width - math.ceil(e.width / o) * m;
                k.x = e.width - k.width
            else
                k.width = math.ceil(e.width / o)
                k.x = k.width * m
            end
            k.y = k.y + e.y;
            k.x = k.x + e.x;
            if d == 'east' then
                k.width, k.height = k.height, k.width;
                k.x, k.y = k.y, k.x
            end
            c.geometries[j] = k
        end
    end
end
a.horizontal = {}
a.horizontal.name = "fairh"
function a.horizontal.arrange(c) return b(c, "east") end
a.name = "fairv"
function a.arrange(c) return b(c, "south") end
return a
