local a = require("my.wibox.widget.base")
local b = require("my.gears.color")
local c = require("my.gears.surface")
local d = require("my.beautiful")
local e = require("lgi").cairo;
local f = require("my.gears.table")
local g = require("my.gears.shape")

local setmetatable = setmetatable;
local type = type;
local unpack = unpack or table.unpack;
local i = {mt = {}}
function i._use_fallback_algorithm()
    i.before_draw_children = function(self, j, k, l, m)
        local n = self._private.shape_border_width or 0;
        local o = self._private.shape or g.rectangle;
        if n > 0 then
            k:translate(n, n)
            l, m = l - 2 * n, m - 2 * n
        end
        o(k, l, m)
        if n > 0 then
            k:save()
            k:set_line_width(n)
            k:set_source(b(self._private.shape_border_color or
                               self._private.foreground or d.fg_normal))
            k:stroke_preserve()
            k:restore()
        end
        if self._private.background then
            k:save()
            k:set_source(self._private.background)
            k:fill_preserve()
            k:restore()
        end
        k:translate(-n, -n)
        k:clip()
        if self._private.foreground then
            k:set_source(self._private.foreground)
        end
    end;
    i.after_draw_children = function(self, j, k, l, m)
        local n = self._private.shape_border_width or 0;
        local o = self._private.shape or g.rectangle;
        if n > 0 then
            k:save()
            k:translate(n, n)
            l, m = l - 2 * n, m - 2 * n;
            o(k, l, m)
            k:set_line_width(n)
            k:set_source(b(self._private.shape_border_color or
                               self._private.foreground or d.fg_normal))
            k:stroke()
            k:restore()
        end
    end
end
local function p(q)
    local r, s = q:get_surface()
    if r == "SUCCESS" then s:finish() end
end
function i:before_draw_children(t, k, l, m)
    local n = self._private.shape_border_width or 0;
    local o = self._private.shape or (n > 0 and g.rectangle or nil)
    if o then k:push_group_with_content(e.Content.COLOR_ALPHA) end
    if self._private.background then
        k:save()
        k:set_source(self._private.background)
        k:rectangle(0, 0, l, m)
        k:fill()
        k:restore()
    end
    if self._private.bgimage then
        k:save()
        if type(self._private.bgimage) == "function" then
            self._private
                .bgimage(t, k, l, m, unpack(self._private.bgimage_args))
        else
            local q = e.Pattern.create_for_surface(self._private.bgimage)
            k:set_source(q)
            k:rectangle(0, 0, l, m)
            k:fill()
        end
        k:restore()
    end
    if self._private.foreground then k:set_source(self._private.foreground) end
end
function i:after_draw_children(j, k, l, m)
    local n = self._private.shape_border_width or 0;
    local o = self._private.shape or (n > 0 and g.rectangle or nil)
    if not o then return end
    k:translate(n, n)
    o(k, l - 2 * n, m - 2 * n, unpack(self._private.shape_args or {}))
    k:translate(-n, -n)
    if n > 0 then
        k:push_group_with_content(e.Content.ALPHA)
        k:set_source_rgba(0, 0, 0, 1)
        k:paint()
        k:set_operator(e.Operator.SOURCE)
        k:set_source_rgba(0, 0, 0, 0)
        k:fill_preserve()
        local u = k:pop_group()
        k:set_source(b(self._private.shape_border_color or
                           self._private.foreground or d.fg_normal))
        k:set_operator(e.Operator.SOURCE)
        k:mask(u)
        p(u)
    end
    k:push_group_with_content(e.Content.ALPHA)
    k.line_width = 2 * n;
    k:set_source_rgba(0, 0, 0, 1)
    k:stroke_preserve()
    k:fill()
    local u = k:pop_group()
    local v = k:pop_group()
    k:set_operator(e.Operator.OVER)
    k:set_source(v)
    k:mask(u)
    p(u)
    p(v)
end
function i:layout(j, l, m)
    if self._private.widget then
        local n = self._private.border_strategy == "inner" and
                      self._private.shape_border_width or 0;
        return {
            a.place_widget_at(self._private.widget, n, n, l - 2 * n, m - 2 * n)
        }
    end
end
function i:fit(t, l, m)
    if not self._private.widget then return 0, 0 end
    local n = self._private.border_strategy == "inner" and
                  self._private.shape_border_width or 0;
    local w, x = a.fit_widget(self, t, self._private.widget, l - 2 * n,
                              m - 2 * n)
    return w + 2 * n, x + 2 * n
end
i.set_widget = a.set_widget_common;
function i:get_widget() return self._private.widget end
function i:get_children() return {self._private.widget} end
function i:set_children(y) self:set_widget(y[1]) end
function i:set_bg(z)
    if z then
        self._private.background = b(z)
    else
        self._private.background = nil
    end
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::bg", z)
end
function i:get_bg() return self._private.background end
function i:set_fg(A)
    if A then
        self._private.foreground = b(A)
    else
        self._private.foreground = nil
    end
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::fg", A)
end
function i:get_fg() return self._private.foreground end
function i:set_shape(o, ...)
    local B = {...}
    if o == self._private.shape and #B == 0 then return end
    self._private.shape = o;
    self._private.shape_args = {...}
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::shape", o)
end
function i:get_shape() return self._private.shape end
function i:set_border_width(l)
    if self._private.shape_border_width == l then return end
    self._private.shape_border_width = l;
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::border_width", l)
end
function i:get_border_width() return self._private.shape_border_width end


function i:set_border_color(A)
    if self._private.shape_border_color == A then return end
    self._private.shape_border_color = A;
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::border_color", A)
end
function i:get_border_color() return self._private.shape_border_color end



function i:set_border_strategy(C)
    self._private.border_strategy = C;
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::border_strategy", C)
end
function i:set_bgimage(D, ...)
    self._private.bgimage = type(D) == "function" and D or c.load(D)
    self._private.bgimage_args = {...}
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::bgimage", D)
end
function i:get_bgimage() return self._private.bgimage end
local function E(F, z, o)
    local G = a.make_widget(nil, nil, {enable_properties = true})
    f.crush(G, i, true)
    G._private.shape = o;
    G:set_widget(F)
    G:set_bg(z)
    return G
end
function i.mt:__call(...) return E(...) end
return setmetatable(i, i.mt)
