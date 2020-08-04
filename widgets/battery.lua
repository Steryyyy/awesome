local wibox = require("my.wibox")
local GET_battery_CMD =
    'cat /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status '
local gears = require("my.gears")

local awful = require("my.awful")
local naughty = require("my.naughty")

local battery = {}

battery.colors = {'#8B4513'}

local proc = wibox.widget {
    max_value = 1,
    forced_width = 40,
    color = battery.colors[1],
    forced_height = 20,
    ticks = true,
    ticks_gap = 2,
    background_color = '#000000',

    widget = wibox.widget.progressbar
}

proc.value = 1

local battery_icon = wibox.widget.textbox('')

battery_icon.font = 'Font Awesome 5 Free Solid Bold 15'
local widget = wibox.widget {
    {

        battery_icon,

        {

            {widget = proc},
            bottom = 5,
            top = 5,
            left = 5,
            right = 5,
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal
    },
    left = 5,
    right = 5,
    widget = wibox.container.margin

}

battery.widget = widget

local mes = ''
local noti =false
local function update()
    awful.spawn.easy_async_with_shell(GET_battery_CMD, function(out)
        out = gears.string.split(out, "\n")

        local batteryd = out[1]
        local status = out[2]
        proc.color = battery.colors[1]
        batteryd = tonumber(batteryd)
        battery_icon.text = (batteryd > 90 and '') or
                                (batteryd > 70 and '') or
                                (batteryd > 49 and '') or
                                (batteryd > 24 and '') or ''

        proc.value = batteryd / 100
        mes = batteryd .. "%" .. ' ' .. status
        if string.match(status, "Charging") then

        elseif batteryd < 30 then
            naughty.notify {
                appname = 'Battery widget',
                icon = battery_icon.text,
                title = 'Low battery',
                text = 'Only ' .. batteryd .. '%',
                urgency = 'critical'
            }
            proc.color = battery.colors[2]
    end
    if noti then
 naughty.notify {
        appname = 'Battery widget',
        icon = battery_icon.text,
        title = 'Batery stat',
        text = mes,
        urgency = 'hide'
    }
noti = false
        end


    end)
end


gears.timer {
    timeout   = 300,
    autostart = true,
    callback  = update
}
function battery.update() update() end

function battery.notify()
noti = true
update()
end

return battery

