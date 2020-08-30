local wibox = require("my.wibox")
local gears = require("my.gears")
local tcolor = require('tools.colors')
local beautiful = require('my.beautiful')
local awful = require('my.awful')
local widget = wibox.layout.flex.horizontal()
widget.spacing = -12
local urgent = {}
local function taglistcolor(self, index)

	self.bg = tcolor.get_color(index + 1, 'tg')
	local g = false
	for s in screen do

		if s.tags[index].selected  then
			if s == mouse.screen then
				self.bg = tcolor.get_color(1, 'tgs')
				g = true

			elseif g == false  then
				self.bg = tcolor.get_color(2, 'tgs')

			end

		end
	end

	if urgent[index] then

		self.bg = tcolor.get_color(3, 'tgs')
	end
end

local function update()
	local index = mouse.screen.selected_tag
	for i, a in pairs(mouse.screen.tags) do
		if i > 5 then return end
		if a then
			local c = widget:get_children()[i]
			if c then taglistcolor(c, i)


			end
		end
	end
end
local function draw()

	for i, a in pairs(mouse.screen.tags) do

		if i > 5 then return end
		if a then

			local widge = wibox.widget {

				{

					{
						id = 'text_role',
						text = a.name,
						font =beautiful.font_icon,
						widget = wibox.widget.textbox
					},

					left = 20,
					right = 15,
					widget = wibox.container.margin
				},
				forced_width = 55,
				widget = wibox.container.background

			}
			widge.shape = gears.shape.powerline
			taglistcolor(widge, i)

    widge:connect_signal("button::press", function(_,_,_,b)  if b == 1 then mouse.screen.tags[i]:view_only()  end  end)
widget:add(widge)
		end

	end
end

function widget.update() update() end
tag.connect_signal("property::selected",function(t) if t and t.selected  then
	if urgent[t.index] then awesome.emit_signal("u",t.index) end
	update() end end)

awesome.connect_signal("u", function(n)
		urgent[n] = not urgent[n]

		if not urgent[n] or mouse.screen.selected_tag.index == n then

			return
		end

		local chil = widget:get_children()
		if chil then
			if chil[n] then

				chil[n].bg = tcolor.get_color(3,'tgs')

			end
		end

end)

gears.timer.delayed_call(draw)
return widget
