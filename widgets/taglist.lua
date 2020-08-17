local wibox = require("my.wibox")
local gears = require("my.gears")
local tcolor = require('tools.colors')
local awful = require('my.awful').client
local beautiful = require('my.beautiful')
local widget = wibox.layout.flex.horizontal()
widget.spacing = -12

local function taglistcolor(self, index)

    self.bg = tcolor.get_color(index + 1, 'tg')
local g = false
    for s in screen do

        if s.tags[index].selected  then
if s == mouse.screen then
            self.bg = tcolor.get_color(1, 'tgs')
	    g = true

    elseif g == false  then
    self.bg = tcolor.get_color(2, 'tgs')

end

        end
    end

for _,c in pairs(awful.urgent.get())do
if c.first_tag.index == index then
self.bg = tcolor.get_color(3,'tgs')
awful.urgent.delete(c)
end
end
end

local function update()
    for i, a in pairs(mouse.screen.tags) do
        if i > 5 then return end
        if a then
            local c = widget:get_children()[i]
            if c then taglistcolor(c, i) end
        end
    end
end
local function draw()

    for i, a in pairs(mouse.screen.tags) do

        if i > 5 then return end
        if a then

            local widge = wibox.widget {

                {

                    {
                        id = 'text_role',
                        text = a.name,
			font =beautiful.font_icon,
                        widget = wibox.widget.textbox
                    },

                    left = 20,
                    right = 15,
                    widget = wibox.container.margin
                },
                forced_width = 55,
                widget = wibox.container.background

            }
            widge.shape = gears.shape.powerline
            taglistcolor(widge, i)

            widget:add(widge)
        end

    end
end
function widget.update() update() end
screen.connect_signal("tag::history::update", update)
tag.connect_signal('property::urgent', update)

gears.timer.delayed_call(draw)
return widget
