local hotkeys_popup = require("my.hotkeys_popup")
local awful = require('awful')
local player = require('widgets.player')
local menu = require('modules.startmenu')
local keys =  require('keybindings')

local exit = require('modules.exit_screen')
local net = require('widgets.net')
local connect= require('tools.connect')
local battery = require('widgets.battery')
local dropdown = require('tools.terminal_dropdown')

local function totag(i)
	local   s = mouse.screen
	-- for s in screen do
	local tag = s.tags[i]

	if tag then
			tag:view_only()
	end
	-- end
end

function to_hidden() totag(6) end

local function move_tag(d)
	local screen = awful.screen.focused()
	local tag = screen.selected_tag
	if tag then
		local i = tag.index + d
		if i > 5 then
			i = 1
		elseif i < 1 then
			i = 5
		end
		totag(i)
		return i
	end

end

local function move_client(d)

	local c = client.focus
	local i = move_tag(d)
	if c then
	local tag = c.screen.tags[i]
	if tag then  c:move_to_tag(tag)  end
	 end

end

local function filter(i)
if i.type == "desktop" or i.type == "dock" or i.type == "splash" or
	not i.focusable or i.hidden then return nil end
	return i
end
local function client_idx(i)
	local c = client.focus
	local x = {}
	local nex = nil
	for s in screen do
		for _, n in ipairs(s.selected_tag:clients()) do

			if filter(n) or n == c then table.insert(x, n) end

		end
	end
	if c then
		for y, n in ipairs(x) do
			if n == c then
				y = y + i
				if y > #x then
					y = 1
				elseif y < 1 then
					y = #x
				end
				nex = y
				break
			end
		end
	else
		nex =1
	end
	if nex then
		local nc = x[nex]

		if nc then
			nc:emit_signal("request::activate", "client.focus.byidx",
			{raise = true})
		end
	end

end

local functions = {
menu_show = menu.show,
menu_volume_show = menu.volume_show,
menu_notify_show = menu.notify_show,
menu_wallpaper_show = menu.wallpaper_show,
menu_volume_mute = volume_mute,
menu_volume_up =volume_up,
menu_volume_down = volume_down,
menu_mic_mute = mic_mute,
menu_mic_down = mic_down,
menu_mic_up = mic_up,
keys = function() hotkeys_popup.show_help("global") end,
player_spawn = player.spawn,
player_change = player.change,
player_prev = player.prev,
player_next = player.next,
player_play = player.play,
player_mute = player.mute,
player_dec = player.dec,
player_inc = player.inc,

dropdown_toggle = dropdown.toggle,

battery_notify = battery.notify,
net_notify = net.notify,

exit = exit.show,
to_urgent = connect.to_urgent,
tag_prev = function() move_tag(-1) end,
tag_next = function() move_tag(1) end,
client_to_next = function() move_client(1) end,
client_to_prev =function() move_client(-1) end,
client_focus_next = function() client_idx(1) end,
client_focus_prev = function() client_idx(-1) end,



}

local empty_function = function() end
for _,a in pairs(keys.globals)do

	if type(a[4]) == "string" then
	if functions[a[4]] then
	a[4] = functions[a[4]]

	else
		a[4] = empty_function
	end

	end

awful.keyboard.append_global_keybindings({awful.key(a[1],a[2], a[4])})
a[4] = nil
end
local mouse_button_name = {
[1] = "LMB",
[2] ="MMB",
[3] = "RMB",
[4] = "Scroll down",
[5] = "Scroll up"


}
for _,a in pairs(keys.mouse_globals)do

	if type(a[4]) == "string" then
	if functions[a[4]] then
	a[4] = functions[a[4]]

	else
		a[4] = empty_function
	end

	end

awful.mouse.append_global_mousebindings({
    awful.button(a[1], a[2], a[4]),
})
a[4] = nil
a[2] = mouse_button_name[a[2]]
table.insert(keys.globals,a)

end


local function client_to(p, f)
	local c = client.focus

	if not c then return end
	if c.fullscreen then return end
	if c.floating then

		if c.width > c.screen.workarea.width - 50 then c.width = c.screen.workarea.width - 50 end

		if c.height > c.screen.workarea.height - 50 then c.width = c.screen.workarea.height - 50 end
		local x, y = c.screen.workarea.x, c.screen.workarea.y
		x, y = (c.screen.workarea.width - c.width  -10 ) / 2 + x,
		(c.screen.workarea.height - c.height -10) / 2  + y
		if f then

			c.height = c.screen.workarea.height - 50
			c.width = c.screen.workarea.width - 50
			y = c.screen.workarea.y + 20
			x = c.screen.workarea.x + 20

			if string.find(p, 'right') or string.find(p, 'left') then

				c.width = c.screen.workarea.width / 2 - 25
			end
			if string.find(p, 'bottom') or string.find(p, 'top') then
				c.height = (c.screen.workarea.height ) / 2 - 25

			end
		end
		if p ~= 'centered' then
			if string.find(p, 'right') then
				x = c.screen.workarea.width - c.width - 30 + c.screen.workarea.x
			elseif string.find(p, 'left') then
				x = c.screen.workarea.x + 20
			else
				y = c.y
			end
			if string.find(p, 'top') then
				y = c.screen.workarea.y + 20
			elseif string.find(p, 'bottom') then
				y = c.screen.workarea.height - c.height - 30
			end
		end
		if x < c.screen.workarea.x + 10 then x = c.screen.workarea.x + 20 end
		if y < c.screen.workarea.y + 10 then y = c.screen.workarea.y + 20 end
		c.x = x
		c.y = y
	end

end
local re = 20
local  function rezide(e, r)
	local c = client.focus
	res = r and re or -re

	if not c then return end
	if not c.floating then return end
	if c.fullscreen then return end

	local w, h = 0, 0
	local x, y = 0, 0
	if e == 'centered' then
		h = res * 2
		y = -res
		w = res * 2
		x = -res
	end

	if string.match(e, 'bottom') then
		h = res
	elseif string.match(e, 'top') then
		y = -res
		h = res

	end

	if string.match(e, 'right') then
		w = res
	elseif string.match(e, 'left') then
		x = -res
		w = res

	end


	local g = c.screen.workarea
	c.width = c.width > 300 and c.width or 300
	c.height = c.height > 300 and c.height or 300
	c.width = c.width + w  < g.width-50 and c.width +w or g.width - 50
	c.height = c.height +h < g.height - 50 and c.height + h or g.height - 50

	c.x = (c.x +x + c.width > g.width-50 +g.x +20 and g.x +20) or (c.x +x < g.x+20 and g.x+20) or c.x +x

	c.y = (c.y +y + c.height > g.height-50 +g.y +20 and g.y +20) or (c.y +y < g.y+20 and g.y+20) or c.y +y

end

local cc = {
	'bottom_left', 'bottom', 'bottom_right', 'left', 'centered', 'right',
	'top_left', 'top', 'top_right'
}

local np = keys.for_keys.numpad
for i,a in pairs(np[1])do

	awful.keyboard.append_client_keybindings(
	{
		awful.key(np[3], a,
		function() rezide(cc[i], true) end),
		awful.key(np[5], a,
		function() rezide(cc[i], false) end),
		awful.key(np[2], a, function() client_to(cc[i]) end),
		awful.key(np[4], a,
		function() client_to(cc[i], true) end)
	})

end


local ts = keys.for_keys.tagswitch

for i=ts[1][1], ts[1][2] do

	awful.keyboard.append_global_keybindings(
	{

		awful.key(ts[2], "#" .. i + 9, function()  local s = mouse.screen local t = s.tags[i] if t then  t:view_only()  end end),
	})
end


local mct = keys.for_keys.move_client_to

for i=mct[1][1], mct[1][2] do

	awful.keyboard.append_global_keybindings(
	{

		awful.key(mct[2], "#" .. i + 9, function()

			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			local c =  client.focus
			if tag then
				tag:view_only()

				if c then
					c:move_to_tag(tag)
				end

			end

		end)
	})
end



table.insert(keys.globals,{ts[2],tostring(ts[1][1]..".."..ts[1][2]),{description="Switch to tag",group="Tag"}})

table.insert(keys.globals,{mct[2],tostring(mct[1][1]..".."..mct[1][2]),{description="Move client to tag",group="Tag"}})
local desc = {"Move client to position","Increase client size to","Move client to position and maximize","Descrease client size to"}
for i=2,#np do
table.insert(keys.globals,{np[i],tostring(np[1][1]..".."..np[1][#np[1]]),{description=desc[i-1],group="Floating"}})
end


for _,a in pairs(keys.client_keybinding) do


awful.keyboard.append_client_keybindings({awful.key(a[1],a[2], a[4])})
a[4] = nil

table.insert(keys.globals,a)
end

for _,a in pairs(keys.client_mosebindings) do


awful.mouse.append_client_mousebindings({awful.button(a[1],a[2],a[4])})
a[4] = nil
a[2] = mouse_button_name[a[2]]
table.insert(keys.globals,a)
end
keys.client_mosebindings = nil
keys.client_keybinding = nil
mouse_button_name = nil
desc = nil
keys.for_keys = nil
keys.mouse_globals = nil
empty_function = nil
functions = nil
mouse_button_name = nil
hotkeys_popup.init()
