local wibox = require("wibox")
local gears = require("gears")
local tcolor = require('tools.colors')
local beautiful = require('beautiful')

return function (screen)

local widget = wibox.layout.flex.horizontal()
widget.spacing = -12
widget.screen = screen
local urgent = {}
local function taglistcolor(self, index)
if not index then return end
	self.bg = tcolor.get_color(index + 1, 'tg')
	local s = widget.screen

if not s.tags or not s.tags[index] then  return end
		if s.tags[index].selected  then
				self.bg = tcolor.get_color(1, 'tgs')


		end

	if urgent[index] then

		self.bg = tcolor.get_color(3, 'tgs')
	end
end

local function update()
	local index = widget.screen.selected_tag
	for i, a in pairs(widget.screen.tags) do
		if i > 5 then return end
		if a then
			local c = widget:get_children()[i]
			if c then taglistcolor(c, i)


			end
		end
	end
end
local function draw()

	for i, a in pairs(widget.screen.tags) do

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

    widge:connect_signal("button::press", function(_,_,_,b)  if b == 1 then widget.screen.tags[i]:view_only()  end  end)
widget:add(widge)
		end

	end
end

function widget.update() update() end
tag.connect_signal("property::selected",function(t) if t and t.selected  then
	if urgent[t.index] then  awesome.emit_signal('u',t.index,widget.screen.index)  end
	update() end end)

awesome.connect_signal("u", function(n,i)
	if i ~= widget.screen.index then
		return
	end
		urgent[n] = not urgent[n]

		if not urgent[n] or widget.screen.selected_tag.index == n then

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

end
