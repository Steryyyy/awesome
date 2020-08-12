pcall(require, "luarocks.loader")

local gears = require("my.gears")
local awful = require("my.awful")

local wibox = require("my.wibox")

local beautiful = require("my.beautiful")

local naughty = require("my.naughty")

local ruled = require("my.ruled")
local home = os.getenv('HOME')
local country_name = "Poland"

-- country code   https://en.wikipedia.org/wiki/ISO_3166-1
local ISO_3166_1 = "pl"
beautiful.init(home .. "/.config/awesome/theme.lua")
beautiful.notification_icon_size = 60

beautiful.fg_normal = '#ffffff'
beautiful.font_name = 'Source Han Sans JP  Bold '
beautiful.font = beautiful.font_name .. '  14'
beautiful.font_icon = 'Font Awesome 5 Brands 15'
require('modules.exit_screen')
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

        awful.layout.suit.fair, awful.layout.suit.fair.horizontal

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
    font = beautiful.font_name .. ' 10',

    widget = wibox.widget.textbox
}, tools.shapes.taskendleft)
coron.forced_width = 240
awful.spawn.easy_async_with_shell([[
	[ "$(stat -c %y ~/.cache/corona| cut -d ' ' -f1)" = "$(date '+%Y-%m-%d')" ] || curl https://corona-stats.online/]]..ISO_3166_1  .. [[ | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" > ~/.cache/corona ;

	grep  "]].. country_name.. [[" ~/.cache/corona | sed 's/\s*//g'| sed 's/║/ /g' | sed 's/│/:/g' | awk -F':' '{if ($6~"▲"){}else {$6="0▲"}  }{if($4~"▲"){}else {$4="0▲"}}{print $3"|"$4"|"$9"⚠|"$5 "☠|"$6  }'

	]], function(out) coron:get_children()[1]:get_children()[1].text = out end)
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
    s.bottom:connect_signal("button::press", function(_, _, _, b)
        if b == 3 then show_exit() end
    end)
end)

ruled.client.connect_signal("request::rules", function()

    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            size_hints_honor = false,
            screen = awful.screen.preferred,

            border_width = 5,
            minimized = false,
            maximized = false,
            border_color = beautiful.border_color_normal
        }
    }

    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            instance = {"copyq", "pinentry"},
            class = {
                "Blueman-manager", "Gpick", "Kruler", "Sxiv", "Tor Browser",
                "Wpa_gui", "veromix", "xtightvncviewer", 'mpv'
            },

            name = {"Event Tester"},
            role = {"AlarmWindow", "ConfigManager", "pop-up"}
        },
        properties = {floating = true, size_hints_honor = true}
    }

end)
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_color_active

end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_color_normal
end)

require('modules.init')
