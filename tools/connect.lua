local awful = require("awful")
local beautiful = require("beautiful")
local get_term_dropdown = require('settings').terminal_dropdown_get
local client_settings = require('settings').client
local settings = require('settings').connect 
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
for s in screen do
urgent[s.index] = {}
end

local function move_and_toggle(c, t)
	if (c.first_tag.index ~= t and not  (c.sticky) ) or c.screen ~= mouse.screen then
		c:tags{c.screen.tags[t]}
		awesome.emit_signal('u',t,c.screen.index)
	end
end
local function set_default(c)
	c.width = c.size_hints and  (c.size_hints.program_size and c.size_hints.program_size.width or 500) or c.width
	c.height= c.size_hints and ( c.size_hints.program_size and c.size_hints.program_size.height or 500) or c.height
	c.rise = true
	local s = c.screen.workarea
	c.x =  (s.width - c.width-10)/2 + s.x
	c.y = (s.height - c.height-10)/2 + s.y
	c:relative_move(0,0,0,0)
end
local function find_class(c)
	if string.find( string.lower(c.class),string.lower(settings.browser)) then
		move_and_toggle(c, 2)
		return true
	elseif string.find(string.lower(c.class),"spotify") then
		move_and_toggle(c, 4)
		c:connect_signal('unmanage',
		function() require('widgets').player.status() end)
		return true
	elseif string.find(string.lower(c.class),'discord') then
		move_and_toggle(c, 3)
		return true
	elseif string.find(string.lower(c.class),'steam') then
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
	c.raise = false
	c.minimized = false
	c.maximized = false
	c.keys = awful.keyboard._get_client_keybindings()
	c.buttons = awful.mouse._get_client_mousebindings()

end)




client.connect_signal("manage", function(c)
	for a,b in pairs (get_term_dropdown) do
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
	if client_settings.titlebars and c.type == "normal"  then
		c:emit_signal("request::titlebars")
	end

	if c.first_tag and c.first_tag.index == mouse.screen.selected_tag.index  then
		c:emit_signal('request::activate', "manage",{raise = true})
	end

	c.size_hints_honor = false
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
	-- awful.client.urgent.jumpto()
	for s in screen do
		if s == mouse.screen then
			if urgent[s.index] then

				for i,t in pairs(s.tags) do
					if urgent[s.index][i] then
						t:view_only()
						urgent[s.index][i] = nil
						return
					end
				end

			end
		end
	end
end
awesome.connect_signal("u", function(n,i)
	if not urgent[i]  then
		return
	end
	urgent[i][n] = not  urgent[i][n]
end)
local wibox = require('wibox')
local gears = require ('gears')
client.connect_signal('property::fullscreen',function(c)

if c.titlebars_enabled and not c.fullscreen  then
	c.shape = client_settings.titlebars_shape
elseif  not c.fullscreen then
	c.shape = client_settings.shape
else
		c.shape = nil
end
end )

client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
c.titlebars_enabled = true
local top = awful.titlebar(c,{size = 20 , position = "top"})
  local buttons = gears.table.join(
        awful.button({ }, 1, function()
		c.floating = true
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 2, function() c:kill() end),
        awful.button({ }, 3, function()

		c.floating = true
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )


    top.widget = wibox.widget{{
	    {
		     { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
		    { -- Right
		    awful.titlebar.widget.floatingbutton (c),
		    awful.titlebar.widget.maximizedbutton(c),
		    awful.titlebar.widget.closebutton    (c),
		    spacing = 10,
		    layout = wibox.layout.fixed.horizontal()

	    },
	    layout = wibox.layout.align.horizontal,
    },
    widget = wibox.container.margin,
    top = 3,
    bottom = 5,
    right = 10,
},
widget = wibox.container.background,
bg = beautiful.border_color_active,
    }

awesome.connect_signal('color_change', function() top.widget.bg = beautiful.border_color_active end)
	c.shape = client_settings.titlebars_shape
end)

return public
