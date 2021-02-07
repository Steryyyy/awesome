local wibox = require("wibox")
local gears = require("gears")
local tcolor = require('tools.colors')
local awful = require('awful')

local modkey = 'Mod4'
return function (s)

	local function taglistcolor(self, index,t)
		if not index then return end
		self.bg = tcolor.get_color(index + 1, 'tg')
		if t.selected  then
			self.bg = tcolor.get_color(1, 'tgs')
			t.urgent = false
		elseif t.urgent then
			self.bg = tcolor.get_color(3, 'tgs')
		end


	end
	local widget = awful.widget.taglist {
		screen  = s,
		filter  = function(t) return  t.index < 6  end,
		style = {
			shape = gears.shape.powerline
		},
		layout = {
			spacing = -12,
			layout  = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					id = 'text_role',
					widget = wibox.widget.textbox,
				},
				left  = 20,
				right = 15,
				widget = wibox.container.margin
			},
			forced_width = 55,
			shape = gears.shape.powerline,
			widget = wibox.container.background,
			create_callback = function(self, t, index)
				taglistcolor(self,index,t)
			end,
			update_callback = function(self, t, index)
				taglistcolor(self,index,t)
			end,
		},
		buttons = gears.table.join(
		awful.button({ }, 1, function(t) t:view_only() end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({ }, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end)
		)
	}
	function widget.update()
		for i,a in pairs(widget.children) do
			taglistcolor(a,i,s.tags[i])
		end

	end

	return widget

end
