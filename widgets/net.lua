local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require('beautiful')
local naughty = require("my.naughty")

local widget = wibox.widget.textbox("睊")
widget.font = beautiful.font_icon

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
local has = false
		awful.spawn.easy_async_with_shell("ip addr | awk -f ~/.config/awesome/scripts/ip.awk",
		function(out)

			for _,a in  ipairs( gears.string.split(out, "\n")) do

			local array = gears.string.split(a, "|")
			if #array > 1 then
			local interface = array[1]
			mac = array[2]

			if  #array  >2  then
			inet = array[3]
			has = true
			else
				inet = "N/A"
			end
			if msg ~="" then
			msg = msg .."\n"
			end

			msg =msg.. "┌[" .. interface .. "]\n" .. "├IP:  " .. inet .. "\n" ..
			"└MAC: " .. mac
			end

			end
				if has then
					widget.text = ""
				else
				widget.text = "睊"
				end

			if nott  then
				nott = false
				_notify()

			end
		end)

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
