local pairs = pairs;
local a = {}
local function b(c, d)
    local e;
    if d then
        e = c.geometry
    else
        e = c.workarea
    end
    for f, g in pairs(c.clients) do
        local h = {x = e.x, y = e.y, width = e.width, height = e.height}
        c.geometries[g] = h
    end
end
a.name = "max"
function a.arrange(c) return b(c, false) end
function a.skip_gap(i, j) return true end
a.fullscreen = {}
a.fullscreen.name = "fullscreen"
a.fullscreen.skip_gap = a.skip_gap;
function a.fullscreen.arrange(c) return b(c, true) end
return a
