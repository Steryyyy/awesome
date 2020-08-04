local a = require("my.gears.surface")
local b = require("lgi").cairo;
local c = {client = client}
local d = {}
d.update = {}
function d.get_transformed(e, f)
    local g = f == "bounding" and e.border_width or 0;
    local h = a.load_silently(e["client_shape_" .. f], false)
    local i = e._shape;
    if not (h or i) then return end
    local j = e:geometry()
    local k = j.width + 2 * g;
    local l = j.height + 2 * g;
    local m = b.ImageSurface(b.Format.A1, k, l)
    local n = b.Context(m)
    n:paint()
    if h then
        n:set_operator(b.Operator.SOURCE)
        n:set_source_surface(h, g, g)
        n:rectangle(g, g, j.width, j.height)
        n:fill()
        h:finish()
    end
    if i then
        n:push_group()
        if f == "clip" then n:translate(-e.border_width, -e.border_width) end
        i(n, j.width + 2 * e.border_width, j.height + 2 * e.border_width)
        n:set_operator(b.Operator.SOURCE)
        n:set_source_rgba(1, 1, 1, 1)
        n:fill_preserve()
        if f == "clip" then
            n:set_source_rgba(0, 0, 0, 0)
            n:set_line_width(2 * e.border_width)
            n:stroke()
        end
        n:pop_group_to_source()
        n:set_operator(b.Operator.IN)
        n:paint()
        n:set_source_rgba(0, 0, 0, 0)
    end
    return m
end
function d.update.all(e)
    d.update.bounding(e)
    d.update.clip(e)
end
function d.update.bounding(e)
    local o = d.get_transformed(e, "bounding")
    e.shape_bounding = o and o._native;
    if o then o:finish() end
end
function d.update.clip(e)
    local o = d.get_transformed(e, "clip")
    e.shape_clip = o and o._native;
    if o then o:finish() end
end
c.client.connect_signal("property::shape_client_bounding", d.update.bounding)
c.client.connect_signal("property::shape_client_clip", d.update.clip)
c.client.connect_signal("property::size", d.update.all)
c.client.connect_signal("property::border_width", d.update.all)
return d
