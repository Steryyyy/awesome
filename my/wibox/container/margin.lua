local pairs = pairs;
local setmetatable = setmetatable;
local a = require("my.wibox.widget.base")
local b = require("my.gears.color")
local c = require("lgi").cairo;
local d = require("my.gears.table")
local e = {mt = {}}
function e:draw(f, g, h, i)
    local j = self._private.left;
    local k = self._private.top;
    local l = self._private.right;
    local m = self._private.bottom;
    local n = self._private.color;
    if not self._private.widget or h <= j + l or i <= k + m then return end
    if n then
        g:set_source(n)
        g:rectangle(0, 0, h, i)
        g:rectangle(j, k, h - j - l, i - k - m)
        g:set_fill_rule(c.FillRule.EVEN_ODD)
        g:fill()
    end
end
function e:layout(f, h, i)
    if self._private.widget then
        local j = self._private.left;
        local k = self._private.top;
        local l = self._private.right;
        local m = self._private.bottom;
        local o = h - j - l;
        local p = i - k - m;
        if o >= 0 and p >= 0 then
            return {a.place_widget_at(self._private.widget, j, k, o, p)}
        end
    end
end
function e:fit(q, h, i)
    local r = self._private.left + self._private.right;
    local s = self._private.top + self._private.bottom;
    local l, m = 0, 0;
    if self._private.widget then
        l, m = a.fit_widget(self, q, self._private.widget, h - r, i - s)
    end
    if self._private.draw_empty == false and (l == 0 or m == 0) then
        return 0, 0
    end
    return l + r, m + s
end
e.set_widget = a.set_widget_common;
function e:get_widget() return self._private.widget end
function e:get_children() return {self._private.widget} end
function e:set_children(t) self:set_widget(t[1]) end
function e:set_margins(u)
    if type(u) == "number" or not u then
        if self._private.left == u and self._private.right == u and
            self._private.top == u and self._private.bottom == u then
            return
        end
        self._private.left = u;
        self._private.right = u;
        self._private.top = u;
        self._private.bottom = u
    elseif type(u) == "table" then
        self._private.left = u.left or self._private.left;
        self._private.right = u.right or self._private.right;
        self._private.top = u.top or self._private.top;
        self._private.bottom = u.bottom or self._private.bottom
    end
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::margins")
end
function e:set_color(n)
    self._private.color = n and b(n)
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::color", n)
end
function e:get_color() return self._private.color end
function e:set_draw_empty(v)
    self._private.draw_empty = v;
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::draw_empty", v)
end
function e:get_draw_empty() return self._private.draw_empty end
function e:reset()
    self:set_widget(nil)
    self:set_margins(0)
    self:set_color(nil)
end
for f, w in pairs({"left", "right", "top", "bottom"}) do
    e["set_" .. w] = function(x, u)
        if x._private[w] == u then return end
        x._private[w] = u;
        x:emit_signal("widget::layout_changed")
        x:emit_signal("property::" .. w, u)
    end;
    e["get_" .. w] = function(x) return x._private[w] end
end
local function y(z, A, B, C, D, n, v)
    local E = a.make_widget(nil, nil, {enable_properties = true})
    d.crush(E, e, true)
    E:set_left(A or 0)
    E:set_right(B or 0)
    E:set_top(C or 0)
    E:set_bottom(D or 0)
    E:set_draw_empty(v)
    E:set_color(n)
    if z then E:set_widget(z) end
    return E
end
function e.mt:__call(...) return y(...) end
return setmetatable(e, e.mt)
