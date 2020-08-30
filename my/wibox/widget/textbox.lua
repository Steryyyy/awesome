local a = require("my.wibox.widget.base")
local b = require("my.gears.debug")
local c = require("my.beautiful")
local d = require("lgi")
local e = require("my.gears.table")
local f = d.Pango;
local g = d.PangoCairo;
local setmetatable = setmetatable;
local h = {mt = {}}
local function i(j, k)
    assert(k, "No DPI provided")
    if j._private.dpi ~= k then
        j._private.dpi = k;
        j._private.ctx:set_resolution(k)
        j._private.layout:context_changed()
    end
end
local function l(j, m, n, k)
    j._private.layout.width = f.units_from_double(m)
    j._private.layout.height = f.units_from_double(n)
    i(j, k)
end
function h:draw(o, p, m, n)
    l(self, m, n, o.dpi)
    p:update_layout(self._private.layout)
    local q, r = self._private.layout:get_pixel_extents()
    local s = 0;
    if self._private.valign == "center" then
        s = (n - r.height) / 2
    elseif self._private.valign == "bottom" then
        s = n - r.height
    end
    p:move_to(0, s)
    p:show_layout(self._private.layout)
end
local function t(self)
    local q, r = self._private.layout:get_pixel_extents()
    if r.width == 0 or r.height == 0 then return 0, 0 end
    return r.width, r.height
end
function h:fit(o, m, n)
    l(self, m, n, o.dpi)
    return t(self)
end
function h:get_preferred_size(u)
    local k;
    if u then
        k = screen[u].dpi
    else
      
        k = c.xresources.get_dpi()
    end
    return self:get_preferred_size_at_dpi(k)
end
function h:get_height_for_width(m, u)
    local k;
    if u then
        k = screen[u].dpi
    else
     
        k = c.xresources.get_dpi()
    end
    return self:get_height_for_width_at_dpi(m, k)
end
function h:get_preferred_size_at_dpi(k)
    local v = 2 ^ 20;
    i(self, k)
    self._private.layout.width = -1;
    self._private.layout.height = -v;
    return t(self)
end
function h:get_height_for_width_at_dpi(m, k)
    local v = 2 ^ 20;
    i(self, k)
    self._private.layout.width = f.units_from_double(m)
    self._private.layout.height = -v;
    local q, w = t(self)
    return w
end
function h:set_markup_silently(x)
    if self._private.markup == x then return true end
    local y, z = f.parse_markup(x, -1, 0)
    if not y then return false, z.message or tostring(z) end
    self._private.markup = x;
    self._private.layout.text = z;
    self._private.layout.attributes = y;
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::markup", x)
    return true
end
function h:set_markup(x)
    local A, B = self:set_markup_silently(x)
    if not A then b.print_error(B) end
end
function h:get_markup() return self._private.markup end
function h:set_text(x)
    if self._private.layout.text == x and self._private.layout.attributes == nil then
        return
    end
    self._private.markup = nil;
    self._private.layout.text = x;
    self._private.layout.attributes = nil;
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::text", x)
end
function h:get_text() return self._private.layout.text end
function h:set_ellipsize(C)
    local D = {
        none = "NONE",
        start = "START",
        middle = "MIDDLE",
        ["end"] = "END"
    }
    if D[C] then
        if self._private.layout:get_ellipsize() == D[C] then return end
        self._private.layout:set_ellipsize(D[C])
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("widget::layout_changed")
        self:emit_signal("property::ellipsize", C)
    end
end
function h:set_wrap(C)
    local D = {word = "WORD", char = "CHAR", word_char = "WORD_CHAR"}
    if D[C] then
        if self._private.layout:get_wrap() == D[C] then return end
        self._private.layout:set_wrap(D[C])
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("widget::layout_changed")
        self:emit_signal("property::wrap", C)
    end
end
function h:set_valign(C)
    local D = {top = true, center = true, bottom = true}
    if D[C] then
        if self._private.valign == C then return end
        self._private.valign = C;
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("widget::layout_changed")
        self:emit_signal("property::valign", C)
    end
end
function h:set_align(C)
    local D = {left = "LEFT", center = "CENTER", right = "RIGHT"}
    if D[C] then
        if self._private.layout:get_alignment() == D[C] then return end
        self._private.layout:set_alignment(D[C])
        self:emit_signal("widget::redraw_needed")
        self:emit_signal("widget::layout_changed")
        self:emit_signal("property::align", C)
    end
end
function h:set_font(E)
    self._private.layout:set_font_description(c.get_font(E))
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("widget::layout_changed")
    self:emit_signal("property::font", E)
end
local function F(x, G)
    local H = a.make_widget(nil, nil, {enable_properties = true})
    e.crush(H, h, true)
    H._private.dpi = -1;
    H._private.ctx = g.font_map_get_default():create_context()
    H._private.layout = f.Layout.new(H._private.ctx)
    H:set_ellipsize("end")
    H:set_wrap("word_char")
    H:set_valign("center")
    H:set_align("left")
    H:set_font(c and c.font)
    if x then
        if G then
            H:set_text(x)
        else
            H:set_markup(x)
        end
    end
    return H
end
function h.mt.__call(q, ...) return F(...) end
return setmetatable(h, h.mt)
