local naughty = require("my.naughty.core")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")
local tcolor = require('tools.colors')
local settings = require('settings').noti
local lay = wibox.layout.fixed.vertical()
local no = wibox.widget.textbox('')
local suspend = false

local dpi = beautiful.xresources.apply_dpi
local menus =  wibox.layout.fixed.vertical()
menus.forced_height = 280
lay:add(menus)
no.forced_height = 20
lay:add(no)
local list = wibox {
	x = mouse.screen.geometry.width - settings.width,
	width = settings.width,
	height = settings.height,
	ontop = true,
	fg = '#000000'

}
menus.item_unselect_color = "#000000"
local last_not = wibox {width = 600, height = 100, ontop = true, fg = '#000000'}

last_not:connect_signal("button::press", function(_,_,_,b)
	if b == 1 then
		last_not.visible = false
	end
end)

local function color_update()

	last_not.bg = tcolor.get_color(2, 'w')

	list.bg = tcolor.get_color(1, 'w')
	menus.bg = tcolor.get_color(1, 'w')
	menus.item_active_color = tcolor.get_color(5, 'w')
	-- menus.item_unselect_color = tcolor.get_color(3, 'w')

	for i, c in pairs(menus:get_children()) do
		--c.bg = tcolor.get_color(3, 'w')
		if i ~=1 then
		c.bg = menus.item_unselect_color
	else
		c.bg =menus.item_active_color
	end
		c:get_children()[1]:get_children()[1].bg = tcolor.get_color(2,'w')

	end


end

color_update()


awesome.connect_signal('color_change', function()
	color_update()

end)
list:set_widget(lay)
local last_timer = timer({
	timeout = 3,
	callback = function(e)

		last_not.visible = false
		e:stop()

	end
})

pcall(function()
	local su = require('config.notify')
	suspend = su
	no.text = not suspend and '' or ''
end)
local function notify(widget,urgency)
	last_not:set_widget(widget)
	last_not.screen = mouse.screen
	last_not.x = mouse.screen.geometry.x + (mouse.screen.geometry.width - last_not.width) / 2
	last_not.visible = true

end
local lock = false

local now_time = 'now'
local function disp_time(time)

	if time > 60 then
		now_time = tostring(math.floor(time/60))..'m'
	end
	return now_time
end


function naughty.default_notification_handler(args)

	local title = args.title
	local text = args.text or args.message
	local urgency = args.urgency or'normal'
	local icon = args.image
	local textic = args.icon
	local app = args.appname
	local iconbox = wibox.widget.textbox(tostring(textic or ""))

iconbox.forced_width = 25
	local top = wibox.layout.fixed.horizontal()
	top.spacing = dpi(5)

	if icon then
		iconbox = wibox.widget {
			{
				id = 'icon',
				resize = true,
				image = icon,
				forced_height = dpi(25),
				forced_width = dpi(25),
				widget = wibox.widget.imagebox
			},
			layout = wibox.layout.fixed.horizontal
		}


	end
	if app then
		top:add(wibox.widget {
			markup = app,
			font = beautiful.font,
			align = 'left',
			valign = 'center',
			widget = wibox.widget.textbox
		})
	end

	local actionslayout = wibox.layout.fixed.vertical()
	top.forced_height = 40
	if title then actionslayout:add(wibox.widget.textbox(title)) end

	if text then actionslayout:add(wibox.widget.textbox(text)) end

	local completelayout = wibox.layout.fixed.horizontal()
	completelayout:add(top)
	completelayout:add(actionslayout)

	local notifbox_template = wibox.widget {{
		{
			{

				layout = wibox.layout.fixed.vertical,
				spacing = 5,

				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 5,
					iconbox ,

					wibox.widget {
						text = tostring(app or ""),
						font = beautiful.font,
						align = 'left',
						valign = 'center',
						forced_width = list.width - 100,
						widget = wibox.widget.textbox
					},
					wibox.widget{
						id= 'time',
						font =beautiful.font,
						text = tostring(now_time),
						align = 'left',
						valign = 'center',
						widget = wibox.widget.textbox

					}
				},

				{
					wibox.widget {
						text = title,
						font = beautiful.font,
						align = 'left',
						valign = 'center',
						widget = wibox.widget.textbox
					},
					wibox.widget {
						text = text,
						font = beautiful.font,
						align = 'left',
						valign = 'center',
						widget = wibox.widget.textbox
					},
					layout = wibox.layout.fixed.vertical
				}

			},
			margins = 5,
			widget = wibox.container.margin
		},
		bg = tcolor.get_color(2, 'w'),
		widget = wibox.container.background
	},
	left = 5,
	widget = wibox.container.margin

}
notifbox_template.time = os.time()
local w, h = wibox.widget.base.fit_widget(notifbox_template,
{dpi = mouse.screen.dpi},
notifbox_template, settings.max_width or 800, settings.max_height or 400)
last_not.height = h
last_not.width = w

if args.urgency == 'uwu' then

	notify(notifbox_template,args.urgency)

	last_timer:again()
	return
end

if args.urgency == "critical" then
	lock = true

	last_timer:stop()
	notify(notifbox_template,args.urgency)

else
	if  urgency ~='hide'then
		local men = menus:get_children()
		if #men > 0 then
			men[1].bg = menus.item_unselect_color
		end


		table.insert(men,1,wibox.widget {
			notifbox_template,

			bg = menus.item_active_color,

			widget = wibox.container.background
		})
		menus:set_children(men)

	end
	if not suspend or args.urgency =='urgent' or   args.urgency =='hide'  then
		if not lock   then
			notify(notifbox_template,args.urgency)

			last_timer:again()
		end

	end
end
end

naughty.connect_signal("request::display", naughty.default_notification_handler)
local public = {}
local gbber
function public.stop()
	list.visible = false
	if gbber then awful.keygrabber.stop(gbber) end

end
function public.start()
	list.visible = true

	list.x = mouse.screen.geometry.width - settings.width + mouse.screen.geometry.x
	local time = os.time()

	for i,a in pairs(menus:get_children())do
		a:get_children()[1]:get_children()[1]:get_children()[1]:get_children()[1]:get_children()[1]:get_children()[3].text = tostring(disp_time(tonumber(time-a:get_children()[1].time)))
		if i == 1 then
			a.bg = menus.item_active_color
		else
			a.bg = menus.item_unselect_color
		end
	end
	gbber = awful.keygrabber.run(function(mod, key, event)
		if event == "release" then return end

		if key == 't' then
			suspend = not suspend
			no.text = not suspend and '' or ''
			awful.spawn.with_shell('echo "return ' .. tostring(suspend) ..'" > ~/.config/awesome/config/notify.lua')

		elseif key == ' ' or key == 'Return' then
			menus:remove_widgets(menus:get_children()[1])
			local c = menus:get_children()[1]
			if c then
				c.bg = menus.item_active_color
			end
		elseif key == 'x' or key == 'Escape' then

			public.stop()

		end

	end)

end

return public
