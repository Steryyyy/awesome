local awful = require("my.awful")
local beautiful = require("my.beautiful")
local get_term = require('settings').terminal_get
local urgent = {}
local floating_table = {
	instance = {"copyq", "pinentry"},
	class = {
		"Blueman-manager", "Gpick", "Kruler", "Sxiv", "Tor Browser",
		"Wpa_gui", "veromix", "xtightvncviewer", 'mpv'
	},
	name = {"Event Tester"},
	role = {"AlarmWindow", "ConfigManager", "pop-up"}
}
next_floating = false
local function move_and_toggle(c, t)
	if c.first_tag.index ~= t and not  (c.sticky) then
		if not urgent[t] then
			awesome.emit_signal("u",t)
		end
		c:tags{mouse.screen.tags[t]}
	end
end
local function set_default(c)
	-- if c.size_hints  then
	c.width = c.size_hints and  (c.size_hints.program_size and c.size_hints.program_size.width or 500) or c.width
	c.height= c.size_hints and ( c.size_hints.program_size and c.size_hints.program_size.height or 500) or c.height
	-- end
	c.rise = true
	local s = c.screen.workarea
	c.x =  (s.width - c.width-10)/2 + s.x
	c.y = (s.height - c.height-10)/2 + s.y
	c:relative_move(0,0,0,0)
end
local function find_class(c)
	if c.class == 'firefox' then
		move_and_toggle(c, 2)
		return true
	elseif c.class == "Spotify" then
		move_and_toggle(c, 4)
		c:connect_signal('unmanage',
		function() require('widgets').player.status() end)
		return true
	elseif c.class == 'discord' then
		move_and_toggle(c, 3)
		return true
	elseif c.class == 'Steam' then
		move_and_toggle(c, 5)
		return true
	end
	return false
end
client.connect_signal("request::manage",function(c)
	c.screen = awesome.startup and c.screen or mouse.screen
	c:tags  {awesome.startup and c.first_tag or mouse.screen.selected_tag}
	c.border_width = (c.fullscreen or c.sticky ) and 0 or 5
	c.border_color = "#000000"
	c.size_hints_honor = false
	c.raise = false
	c.minimized = false
	c.maximized = false
	c.keys = awful.keyboard._get_client_keybindings()
	c.buttons = awful.mouse._get_client_mousebindings()
end)
client.connect_signal("manage", function(c)
	-- terminal is managed in tools/terminal.lua
	for a,b in pairs (get_term) do
		if c[a] ==b then
			return
		end
	end
	if c.class == '' or c.class == nil then
		move_and_toggle(c, 6)
		c:connect_signal('property::class', function(c) find_class(c) end)
		return
	end
	if next_floating then
		c.floating = true
	else
		for i,a in pairs(floating_table) do
			for _,b in pairs(a) do
				if c[i] ==b then
					c.floating = true
					break
				end
			end
		end
	end
	find_class(c)
	if c.floating then
		c.size_hints_honor = true
		set_default(c)
	end
	if c.first_tag and c.first_tag.index == mouse.screen.selected_tag.index  then
		c:emit_signal('request::activate', "manage",{raise = true})
	end
	if awesome.startup and not c.size_hints.user_position and
		not c.size_hints.program_position then
		c:relative_move(0,0,0,0)
	end
end)
client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_color_active
end)
client.connect_signal("unfocus", function(c)
	c.border_color = '#000000'
end)
local public ={}
function public.to_urgent()
	for i=1,5 do
		if urgent[i] then
			if mouse.screen.tags then
				mouse.screen.tags[i]:view_only()
			end
			urgent[i]= nil
			break
		end
	end
end
awesome.connect_signal("u", function(n)
	urgent[n] = not  urgent[n]
end)
return public
