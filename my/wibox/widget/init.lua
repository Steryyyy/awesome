local cairo = require("lgi").cairo
local hierarchy = require("my.wibox.hierarchy")

local widget = {
    base = require("my.wibox.widget.base"),
    textbox = require("my.wibox.widget.textbox"),
    imagebox = require("my.wibox.widget.imagebox"),

 --   systray = require("my.wibox.widget.systray"),
    --textclock = require("my.wibox.widget.textclock"),
    progressbar = require("my.wibox.widget.progressbar")

}

setmetatable(widget, {
    __call = function(_, args)
        return widget.base.make_widget_declarative(args)
    end
})

function widget.draw_to_cairo_context(wdg, cr, width, height, context)
    local function no_op() end
    context = context or {dpi = 96}
    local h = hierarchy.new(context, wdg, width, height, no_op, no_op, {})
    h:draw(context, cr)
end

function widget.draw_to_image_surface(wdg, width, height, format, context)
    local img = cairo.ImageSurface(format or cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(img)
    widget.draw_to_cairo_context(wdg, cr, width, height, context)
    return img
end

return widget

