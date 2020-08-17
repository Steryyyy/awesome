local wibox = require("my.wibox")
local gears = require("my.gears")

local awful = require("my.awful")
local beautiful = require('my.beautiful')
local naughty = require("my.naughty")

local widget = wibox.widget.textbox("睊")
widget.font = beautiful.font_icon

local interface = "enp9s0"
local msg = "Wired network is disconnected"

local mac = "N/A"
local inet = "N/A"

local function net_update()

    mac = "N/A"
    inet = "N/A"
    awful.spawn.easy_async_with_shell("ip addr show " .. interface ..
                                          [[| grep "inet \|link/ether"  | awk '{print $2}']],
                                      function(out)
        local a = gears.string.split(out, "\n")

        inet = a[2] or inet

        mac = a[1] or mac
        msg = "┌[" .. interface .. "]\n" .. "├IP:  " .. inet .. "\n" ..
                  "└MAC: " .. mac

        if inet ~= "N/A" then
            widget.text = ""

        else
            widget.text = "睊"

            msg = "Wired network is disconnected</span>"
        end
    end)
end
gears.timer {
    timeout   = 530,
    call_now  = true,
    autostart = true,
    callback  = net_update
}

function widget.notify()
    naughty.notify {
        appname = 'Internet widget',
        icon = widget.text,
        text = msg,
        title = 'Internet state',
        urgency = 'hide'
    }
end
return widget
