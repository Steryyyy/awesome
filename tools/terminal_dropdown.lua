local term_com = require('settings').terminal_dropdown
local get_term = require('settings').terminal_dropdown_get
local fullhight = false
local terminals = {}
local index = 1
local gears = require('gears')
local awful = require("awful")

local dele = false
local function position()
	if terminals[index] == nil then return end

	terminals[index].hidden = not terminals[index].hidden
	terminals[index].height = (fullhight and mouse.screen.geometry.height or
	mouse.screen.geometry.height / 2)
	terminals[index].x = mouse.screen.geometry.x
	terminals[index].y = mouse.screen.geometry.y
	terminals[index].width = mouse.screen.geometry.width
	if not terminals[index].hidden then


		terminals[index]:emit_signal("request::activate", "mouse_click",
		{raise = false})
	end

end


local function dropdown(i)
	if #terminals <= 1 then return end
	terminals[index].hidden = true
	index = index + i
	if index > #terminals then
		index = 1
	elseif index < 1 then
		index = #terminals
	end
	position()
end

local function manage(c)

	c.border_width = false
	c.size_hints_honor = false
	c.floating = true
	c.index = #terminals + 1
	c.sticky = true
	c.border_width = 0
	c.hidden = true
	c.ontop = true
	c.y = 0
	c.x = 0
	c.width = c.screen.geometry.width
	c.height = c.screen.geometry.height / 2
	table.insert(terminals, c)
	c.keys = gears.table.join(
		awful.key({'Mod1'}, "Return", function()Request = true awful.spawn.with_shell(term_com) end),
		awful.key({'Mod1'}, "f", function()fullhight = not fullhight terminals[index].height = (fullhight and mouse.screen.geometry.height or mouse.screen.geometry.height / 2) c.y = fullhight and mouse.screen.geometry.y  or c.y  end),
		awful.key({'Mod4'}, "f", function()fullhight = not fullhight terminals[index].height = (fullhight and mouse.screen.geometry.height or mouse.screen.geometry.height / 2) c.y = fullhight and mouse.screen.geometry.y  or c.y  end),
		awful.key({'Mod1'}, "KP_Left", function() c.width = c.screen.geometry.width / 2 c.height = fullhight and  c.screen.geometry.height or c.screen.geometry.height/2  c.x = c.screen.geometry.x c.y = c.screen.geometry.y end),
		awful.key({'Mod1'}, "KP_Right", function()c.width = c.screen.geometry.width / 2 c.height = fullhight and  c.screen.geometry.height or c.screen.geometry.height/2 c.x = c.screen.geometry.width - c.width + c.screen.geometry.x c.y = c.screen.geometry.y end),
		awful.key({'Mod1'}, "KP_Up", function()c.width = c.screen.geometry.width c.height = fullhight and  c.screen.geometry.height or c.screen.geometry.height/2 c.x = c.screen.geometry.x c.y = c.screen.geometry.y end),
		awful.key({'Mod1'}, "KP_Down", function() c.width = c.screen.geometry.width c.height = c.screen.geometry.height / 2 c.x = c.screen.geometry.x c.y = c.screen.geometry.height - c.height + c.screen.geometry.y end),
		awful.key({'Mod1'}, "Right", function() dropdown(1) end),
		awful.key({'Mod1'}, "Left", function() dropdown(-1) end),
		awful.key({'Mod1'}, "q", function(c) dele = true c:kill() end)
	)
	c:connect_signal('unfocus', function(c) c.hidden = true end)
	c:connect_signal('unmanage', function(c)
		table.remove(terminals, c.index)
		for a, b in pairs(terminals) do b.index = a end
		index = 1
		if dele then
			dele = false
			position()
		end
	end)


		c:move_to_tag(mouse.screen.tags[6])
awful.client.urgent.delete(c)

	if Request  then
		if #terminals > 1 then terminals[index].hidden = true end
		index = c.index

		position()

		Request = false


	end

end


client.connect_signal("manage", function(c)

for a,b in pairs (get_term) do
if c[a] ==b then

	manage(c)
	-- return
end
end



end)
local public = {}

function dropdown_terminal_open(st)
	if st then
		Request = true
		awful.spawn.with_shell(term_com ..' -e '.. st)
	end
end
function  public.toggle()

	if #terminals == 0 then
		Request = true
		awful.spawn.with_shell(term_com)
		return
	end

	if #terminals >= index and index > 0 then

		position()

	else
		return
	end
end

return public

