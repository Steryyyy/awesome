local wibox = require("wibox")
local gears = require("gears")
local settings = require('settings').widgets.internet
local awful = require("awful")
local beautiful = require('beautiful')
local naughty = require("my.naughty")

local widget = wibox.widget.textbox("睊")
widget.font = beautiful.font_icon

local interfaces =   settings.interface  or {"enp9s0"}
local msg = "Wired network is disconnected"

local mac = "N/A"
local inet = "N/A"
local nott = false
local function net_update()
	local function _notify ()

		naughty.notify {
			appname = 'Internet widget',
			icon = widget.text,
			text = msg,
			title = 'Internet state',
			urgency = 'hide'
		}

	end
	mac = "N/A"
	inet = "N/A"
	msg = ""
	local was = false
	for i,interface in pairs(interfaces) do
		awful.spawn.easy_async_with_shell("ip addr show " .. interface ..
		[[| awk '/(inet |link\/ether)/ {print $2}' ]],
		function(out)
			local a = gears.string.split(out, "\n")
			a[2] = a[2] or ""
			a[1] = a[1] or ""
			inet = a[2] ~="" and a[2] or "N/A"

			mac = a[1] ~="" and a[1] or "N/A"
			msg =msg.. "┌[" .. interface .. "]\n" .. "├IP:  " .. inet .. "\n" ..
			"└MAC: " .. mac .."\n"

			if not has then
				if inet ~= "N/A" then
					widget.text = ""
					has = true
				else
					widget.text = "睊"

				end
			end
			if nott and i == #interfaces then
				nott = false
				_notify()

			end
		end)

	end
end
gears.timer {
    timeout   = 300,
    call_now  = true,
    autostart = true,
    callback  = net_update
}

function widget.notify()
	nott = true
	net_update()
end

widget:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
widget.notify()
end
end)
return widget
