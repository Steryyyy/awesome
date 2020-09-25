local awful = require("my.awful")
local player = require('widgets.player')
local net = require('widgets.net')
local menu = require('modules.startmenu')
local connect= require('tools.connect')
local battery = require('widgets.battery')
local terminal = require('tools.terminal')
local exit = require('modules.exit_screen')
local modkey = 'Mod4'
local altkey = 'Mod1'
local control = 'Control'
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
local  global = {

	awful.key({modkey}, "x", menu.show),
	awful.key({modkey}, "p", player.spawn),
	awful.key({}, "XF86Tools", player.spawn),
	awful.key({modkey}, "w", menu.wallpaper_show),
	awful.key({modkey}, "n", menu.notify_show),
	awful.key({modkey}, "v", menu.volume_show),
	awful.key({modkey}, "i", net.notify),
	awful.key({modkey}, "b", battery.notify),
	awful.key({}, "XF86AudioPlay", player.play),
	awful.key({}, "XF86AudioNext", player.next),
	awful.key({}, "XF86AudioPrev", player.prev),
	awful.key({}, "XF86AudioStop", player.change),
	awful.key({}, "XF86Search", menu.show),
	awful.key({altkey}, "XF86AudioRaiseVolume", player.inc),
	awful.key({altkey}, "XF86AudioLowerVolume", player.dec),

	awful.key({altkey}, "XF86AudioMute", player.mute),
	awful.key({}, "XF86AudioRaiseVolume", volume_up),
	awful.key({}, "XF86AudioLowerVolume", volume_down),
	awful.key({}, "XF86AudioMute", volume_mute),
	awful.key({ 'Shift'}, "XF86AudioMute", mic_mute),
	awful.key({ 'Shift'}, "XF86AudioRaiseVolume", mic_up),
	awful.key({ 'Shift'}, "XF86AudioLowerVolume", mic_down),

	awful.key({modkey}, "q", terminal.toggle),
	awful.key({modkey}, "j", function()local c = client.focus if c then c:move_to_screen() else awful.screen.focus_relative(1)  end end),
	awful.key({modkey}, "k", function()local c = client.focus if c then c:move_to_screen(c.screen.index - 1) else awful.screen.focus_relative(-1) end end),
	awful.key({modkey}, "Tab", function() client_idx(1) end),
	awful.key({modkey, 'Shift'}, "Tab", function() client_idx(-1) end),
	awful.key({modkey, control}, "n", function()local c = awful.client.restore()if c then c:activate{raise = true, context = "key.unminimize"}end end),
	awful.key({modkey, control}, "j",function() awful.screen.focus_relative(1) end),
	awful.key({modkey, control}, "k",function() awful.screen.focus_relative(-1) end),

	awful.key({modkey, "Shift"}, "j",function() awful.client.swap.byidx(1) end),
	awful.key({modkey, "Shift"}, "k",function() awful.client.swap.byidx(-1) end),
	awful.key({modkey}, "u", connect.to_urgent),
	awful.key({modkey}, "l", function() awful.tag.incgap(5) end),
	awful.key({modkey}, "h", function() awful.tag.incgap(-5) end),
	awful.key({modkey, control,'Shift'}, "h", function()local tag = mouse.screen.tags[6]if tag then tag:view_only() end end),
	awful.key({modkey}, "space", function() awful.layout.inc(1) end),
	awful.key({modkey, "Shift"}, "space",function() awful.layout.inc(-1) end),

	awful.key({modkey, "Shift"}, "e",exit),



}

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
	c.width = c.width + w  < g.width-50 and c.width +w or g.width - 50
	c.height = c.height +h < g.height - 50 and c.height + h or g.height - 50
	c.x = (c.x +x + c.width > g.width-50 +g.x +20 and g.x +20) or (c.x +x < g.x+20 and g.x+20) or c.x +x

	c.y = (c.y +y + c.height > g.height-50 +g.y +20 and g.y +20) or (c.y +y < g.y+20 and g.y+20) or c.y +y

end


local function totag(i)
	local   s = mouse.screen
	-- for s in screen do
	local tag = s.tags[i]

	if tag then
		if tag.index == s.selected_tag.index then
			return
		else
			tag:view_only()
		end
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

awful.keyboard.append_client_keybindings(
{
	awful.key({modkey}, "f", function(c) c.fullscreen = not c.fullscreen c:raise() end),
	awful.key({modkey,control}, "f", function(c)c.floating = not c.floating   end),
	awful.key({modkey, "Shift"}, "c", function(c)c:kill()end),
	awful.key({modkey}, "m", function(c)c.maximized = not c.maximized c:raise()end)

}
)


local aa = {
	"KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin", "KP_Right",
	"KP_Home", "KP_Up", "KP_Prior"
}
local cc = {
	'bottom_left', 'bottom', 'bottom_right', 'left', 'centered', 'right',
	'top_left', 'top', 'top_right'
}
for i = 1, #aa do
	awful.keyboard.append_client_keybindings(
	{
		awful.key({modkey, control}, aa[i],
		function() rezide(cc[i], true) end),
		awful.key({modkey, 'Shift', control}, aa[i],
		function() rezide(cc[i], false) end),
		awful.key({modkey}, aa[i], function() client_to(cc[i]) end),
		awful.key({modkey, 'Shift'}, aa[i],
		function() client_to(cc[i], true) end)
	})
end


awful.mouse.append_client_mousebindings(
{
	awful.button({}, 1,function(c)c:activate{context = "mouse_click"}end),
	awful.button({ modkey }, 1, function (c)c.floating = true  c:activate { context = "mouse_click", action = "mouse_move"  }end),
	awful.button({modkey}, 3,function(c)c.floating = true   c:activate{context = "mouse_click",action ="mouse_resize"}end),
	awful.button({}, 3,function(c)c:activate{context = "mouse_click"}end)
}
)

for i = 1, 5 do
	awful.keyboard.append_global_keybindings(
	{

		awful.key({modkey}, "#" .. i + 9, function() totag(i) end),
		awful.key({modkey, control}, "#" .. i + 9, function()

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

awful.keyboard.append_global_keybindings(
{
	awful.key({modkey}, "Left", function() move_tag(-1) end),
	awful.key({modkey}, "Right", function() move_tag(1) end),
	awful.key({modkey, control}, "Left", function() move_client(-1) end),
	awful.key({modkey, control}, "Right", function() move_client(1) end)
})


awful.keyboard.append_global_keybindings(global)
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, exit),
})

