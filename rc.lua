pcall(require, "luarocks.loader")

local gears = require("my.gears")
local awful = require("my.awful")

local wibox = require("my.wibox")

local beautiful = require("my.beautiful")

local naughty = require("my.naughty")
local settings = require('settings').rc

beautiful.useless_gap = 5
beautiful.notification_icon_size = 60

beautiful.fg_normal = '#ffffff'
beautiful.font_name = settings.font
beautiful.font = beautiful.font_name .. ' Bold '.. settings.font_size
beautiful.font_icon_name = settings.font_icon
beautiful.font_icon = settings.font_icon .. settings.font_icon_size
local tools = require('tools')
local widgets = require("widgets")

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" ..
            (startup and " during startup!" or "!"),
        message = message
    }
end)

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({

        awful.layout.suit.fair, awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile.right

    })
end)
local widget_spacing = -12
function Power(wi, shape, typ)
    if not typ then typ = 'w' end
    if not shape then shape = tools.shapes.leftpowerline end

    local background = wibox.container.background(
                           wibox.container.margin(wi, 20, 15), '', shape)

    return background
end

local textclock = wibox.widget.textbox('')

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function() textclock.text = os.date("%H:%M:%S") end
}
local clock = Power(textclock, tools.shapes.leftstart, 'tg')
clock.forced_width = 125

local microphone = Power(widgets.volume.microphone, gears.shape.powerline, 'tg')
local coron = Power(wibox.widget {
    font = beautiful.font_name .. ' Bold 10',

    widget = wibox.widget.textbox
}, tools.shapes.taskendleft)
awful.spawn.easy_async_with_shell([[ [ "$(stat -c %y ~/.cache/corona| cut -d ' ' -f1)" = "$(date '+%Y-%m-%d')" ] || curl https://corona-stats.online/]]..settings.country_code  .. [[ | awk 'gsub("\033\\[[0-9]*m","")' > ~/.cache/corona ; awk -F'│' '/]]..settings.country_name..[[/ && gsub("\\s","") && gsub("║","") {{if ($6~"▲"){}else {$6="0▲"}  }{if($4~"▲"){}else {$4="0▲"}} print $3"|"$4"|"$9"⚠|"$5 "☠|"$6  }  ' ~/.cache/corona ]],
function(out) coron:get_children()[1]:get_children()[1].text = out end)
local wwi = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    Power(widgets.player.widget),
    Power(widgets.stats.cpu),
    Power(widgets.stats.mem),
    Power(widgets.battery.widget),
    Power(wibox.widget {
        widgets.net,
        right = 10,
        widget = wibox.container.margin
    }),
    Power(widgets.volume.volume, gears.shape.rectangular_tag),
    spacing = widget_spacing

}
local function getcolor()
    coron.bg = tools.color.get_color(4, 'tg')
    widgets.battery.colors[1] = tools.color.get_color(5, 'w')
    widgets.battery.colors[2] = tools.color.get_color(6, 'w')

    widgets.player.color[1] = tools.color.get_color(5, 'w')
    widgets.battery.update()
    widgets.player.update()
    widgets.taglist.update()
    clock.bg = tools.color.get_color(1, 'tg')
    microphone.bg = tools.color.get_color(3, 'tg')
    local ww = wwi:get_children()
    local f = 1
    for i = #ww, 1, -1 do

        ww[i].bg = tools.color.get_color(f, 'w')
        f = (f > 3 and 1 or f + 1)
    end

    coron.bg = tools.color.get_color(2, 'tg')
    for _, c in pairs(client.get()) do
        if c == client.focus then
            c.border_color = beautiful.border_color_active
        else
            c.border_color = '#000000'
        end
    end

end

local bottom_widget = wibox.widget {

    expand = "none",
    layout = wibox.layout.align.horizontal,
    {
        layout = wibox.layout.fixed.horizontal,
        clock,

        widgets.taglist,
        microphone,
        coron,
        spacing = widget_spacing

    },

    nil,
    wwi

}
local tagnames = {"", "", "", "", "", 'hidden'}
awesome.connect_signal('color_change', function() getcolor() end)
screen.connect_signal("request::desktop_decoration", function(s)

    awful.tag(tagnames, s, awful.layout.layouts[1])

   s.wiboxes = {}
   s.bottom = wibox {
        y = s.geometry.height - 20 + s.geometry.y,
        screen = s,
        height = 20,
        width = s.geometry.width,
        x = s.geometry.x,
        visible = true,

        bg = '#00000000',
        fg = '#000000'
    }
  s.bottom:struts({bottom = 20})

    s.bottom:set_widget(bottom_widget)
end)

require('modules.init')
