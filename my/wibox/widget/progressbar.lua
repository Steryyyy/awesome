local setmetatable = setmetatable;
local ipairs = ipairs;
local math = math;

local b = require("my.wibox.widget.base")
local c = require("my.gears.color")
local d = require("my.beautiful")
local e = require("my.gears.shape")
local f = require("my.gears.table")
local g = {mt = {}}
local h = {
    "border_color", "color", "background_color", "value", "max_value", "ticks",
    "ticks_gap", "ticks_size", "border_width", "shape", "bar_shape",
    "bar_border_width", "clip", "margins", "bar_border_color", "paddings"
}
function g.draw(i, j, k, l, m)
    local n = i._private.ticks_gap or 1;
    local o = i._private.ticks_size or 4;
    k:set_line_width(1)
    local p = i._private.max_value;
    local q = math.min(p, math.max(0, i._private.value))
    if q >= 0 then q = q / p end
    local r = i._private.border_width or d.progressbar_border_width or 0;
    local s = i._private.border_color or d.progressbar_border_color;
    r = s and r or 0;
    local t = i._private.background_color or d.progressbar_bg or "#ff0000aa"
    local u, v = l, m;
    local w = i._private.clip ~= false and d.progressbar_clip ~= false;
    local x = i._private.margins or d.progressbar_margins;
    if x then
        if type(x) == "number" then
            k:translate(x, x)
            u, v = u - 2 * x, v - 2 * x
        else
            k:translate(x.left or 0, x.top or 0)
            v = v - (x.top or 0) - (x.bottom or 0)
            u = u - (x.left or 0) - (x.right or 0)
        end
    end
    if r > 0 then
        k:translate(r / 2, r / 2)
        u, v = u - r, v - r;
        k:set_line_width(r)
    end
    local y = i._private.shape or d.progressbar_shape or e.rectangle;
    y(k, u, v)
    k:set_source(c(t))
    local z = u + r;
    local A = v + r;
    if r > 0 then
        k:fill_preserve()
        k:set_source(c(s))
        k:stroke()
        z = z - 2 * r;
        A = A - 2 * r
    else
        k:fill()
    end
    k:translate(-r / 2, -r / 2)
    if w then
        y(k, u, v)
        k:clip()
        k:translate(r, r)
    else
        if type(x) == "number" then
            k:translate(-x, -x)
        else
            k:translate(-(x.left or 0), -(x.top or 0))
        end
        A = m;
        z = l
    end
    local B = i._private.paddings or d.progressbar_paddings;
    if B then
        if type(B) == "number" then
            k:translate(B, B)
            A = A - 2 * B;
            z = z - 2 * B
        else
            k:translate(B.left or 0, B.top or 0)
            A = A - (B.top or 0) - (B.bottom or 0)
            z = z - (B.left or 0) - (B.right or 0)
        end
    end
    z = math.max(z, 0)
    A = math.max(A, 0)
    local C = z * q;
    local D = i._private.bar_shape or d.progressbar_bar_shape or e.rectangle;
    local E = i._private.bar_border_width or d.progressbar_bar_border_width or
                  i._private.border_width or d.progressbar_border_width or 0;
    local F = i._private.bar_border_color or d.progressbar_bar_border_color;
    E = F and E or 0;
    z = z - E;
    A = A - E;
    k:translate(E / 2, E / 2)
    D(k, C, A)
    k:set_source(c(i._private.color or d.progressbar_fg or "#ff0000"))
    if E > 0 then
        k:fill_preserve()
        k:set_source(c(F))
        k:set_line_width(E)
        k:stroke()
    else
        k:fill()
    end
    if i._private.ticks then
        for G = 0, l / (o + n) - r do
            local H = z / 1 - (o + n) * G;
            if H <= C then k:rectangle(H, r, n, A) end
        end
        k:set_source(c(i._private.background_color or "#000000aa"))
        k:fill()
    end
end
function g:fit(j, l, m) return l, m end
function g:set_value(q)
    q = q or 0;
    self._private.value = q;
    self:emit_signal("widget::redraw_needed")
    return self
end
function g:set_max_value(p)
    self._private.max_value = p;
    self:emit_signal("widget::redraw_needed")
end


for j, I in ipairs(h) do
    if not g["set_" .. I] then
        g["set_" .. I] = function(i, q)
            i._private[I] = q;
            i:emit_signal("widget::redraw_needed")
            i:emit_signal("property::" .. I, q)
            return i
        end
    end
    if not g["get_" .. I] then
        g["get_" .. I] = function(i) return i._private[I] end
    end
end

function g.new(J)
    J = J or {}
    local i = b.make_widget(nil, nil, {enable_properties = true})
    i._private.width = J.width or 100;
    i._private.height = J.height or 20;
    i._private.value = 0;
    i._private.max_value = 1;
    f.crush(i, g, true)
    return i
end
function g.mt:__call(...) return g.new(...) end
return setmetatable(g, g.mt)
