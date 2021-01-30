local awful = require("awful")
local tcolor = require('tools.colors')
local tshape = require('tools.shapes')
local vole = require('modules.volcontrol')
local show_exit  = require('modules.exit_screen')
local wallpaper = require('modules.wallpaper')
local wibox = require("wibox")
local gears = require("gears")
local settings = require('settings').start_menu
local notd = require('modules.notif')
local beautiful = require("beautiful")
local my_align = require('my.align')
local user = os.getenv('USER')
local starmenu = wibox {
	width = settings.width > 300 and settings.width or 490,
	height = settings.height  > 300 and settings.height or  550,
	fg = '#000000',
	ontop = true,
	visible = false
}
local pos = 1
local SHIFT = 0
local maxitm = settings.items > 2 and settings.items or 10
local colors = {'#ff0000', '#ffff00'}
local selcolor = '#ffffff'
local unselect = '#000000'
local prompt = settings.prompt or 'Search'
local keys = require('keybindings').startmenu_keys
local hotkeys_popup = require("my.hotkeys_popup")
local search_str =''
local last = ''
local menu_items = {}
local menus = wibox.layout.flex.vertical()
local search = wibox.widget.textbox('')
local uptime_time = wibox.widget.textbox('')
uptime_time.align = 'center'
local user_image = os.getenv('HOME')..'/.config/awesome/images/profile.jpg'
local distro_name = wibox.widget.textbox('')
local kernel_version = wibox.widget.textbox('')
local function add_bor(w)
	return wibox.container.background(wibox.container.margin(w, 5, 5, 5, 5))
end
local user_widget = wibox.widget {

	{
		wibox.container.margin(wibox.widget {
			wibox.widget.imagebox(user_image),
			wibox.widget.textbox(user),
			spacing = 10,
			layout = wibox.layout.fixed.horizontal
		}, 5, 20, 5, 5),
		shape = tshape.start_right_powerline,
		widget = wibox.container.background

	},

	wibox.container.background(
	wibox.container.margin(uptime_time, 25, 10, 5, 5), '',
	gears.shape.powerline),
	wibox.container.background(
	wibox.container.margin(distro_name, 25, 20, 5, 5), '',
	tshape.finish_right_powerline),

	layout = my_align.horizontal

}
user_widget:set_spacing(-20)
user_widget.forced_height = 35


local function readfile(fil)
	local f = io.open(fil,'rb')
	if f then
		local content = f:read()
		f:close()
		return content
	end
	return ""

end
local function get_dirsto()
	local d = readfile('/etc/os-release')
	if d then
		distro_name.text = d:sub(7)
		distro_name.text = distro_name.text:sub(1,#distro_name.text -1)
	end
end
pcall(get_dirsto)
get_dirsto = nil
awful.spawn.easy_async_with_shell('uname -r', function(out)

	kernel_version.text = out:gsub('%\n', '')

end)

local function update_uptime ()
	local d = readfile('/proc/uptime')
	if d then
		local t  = math.floor(string.match(d, "[%d]+"))
		local h = math.floor(t/3600)
		local m = math.floor((t%3600)/60)
		if m <10 then
			m = "0"..m
		end
		if h <10 then
			h = "0"..h
		end
		uptime_time.text =os.date('%d/%m/%Y ')..  h..':'..m
	end
end
local function get_menu()
	local be = nil
	if settings.auto_menu then
	be = require('scripts.luamenu')
	else
	be = require('config.menu')
	end
	if be and type(be) =="table" then

		menu_items = be
	end
end
pcall(get_menu)
get_menu = nil
local filtered = menu_items
local search_bg = wibox.container.background(
wibox.container.margin(
wibox.container.background(
wibox.container.margin(search, 10, 10, 2), ''), 5,
5, 10, 10))
search_bg.forced_width = 350
search_bg.forced_height = 50
menus.forced_width = settings.width> 300 and settings.width or 490
menus.forced_height = settings.height > 300 and settings.height or 500
local menu = add_bor(wibox.widget {
	search_bg,
	menus,
	layout = wibox.layout.fixed.vertical
})

local function update()
	local max = maxitm
	maxitm = maxitm +1
	local items= #filtered +1
	if maxitm >items then
		maxitm = items
	end

	if pos > items then
		pos = items
	end
	local r =(items -pos < math.ceil(maxitm/2))and items-maxitm or  (pos >  math.ceil(maxitm/2)and pos - math.ceil(maxitm/2)) or 0
	r = r - 1
	local ne = (items - pos < math.ceil(maxitm/2))and maxitm-(items-pos) or pos < math.ceil(maxitm/2) and pos or math.ceil(maxitm/2)
	SHIFT = r +1
	for i,b in ipairs(menus:get_children())do
		if i == ne then
			b.bg = selcolor
		else b.bg = unselect end
		if i > 1 then
			if i+r <= #filtered then
				b.visible = true
				local g = b:get_children()[1]:get_children()[1]
				g:get_children()[1]:get_children()[1]:get_children()[1].image = filtered[r+i][3]

				g:get_children()[2]:get_children()[1]:get_children()[1].text = filtered[i+r][1]
			else
				b.visible = false
			end
		end
	end
	maxitm =max
end
local function clear()

	pos = 1
	last = ''
	filtered = menu_items
	update()
end



local function add(k)
	pos = 1
	if k == '' then
		clear()
		return
	end
	last = k
	filtered = {}
	for _,a in ipairs(menu_items) do
		if string.find(a[1],last) then
			table.insert(filtered,a)
		end
	end
	update()
end

starmenu:setup{user_widget, menu, layout = wibox.layout.fixed.vertical}

local function create_spacer(e)
	return wibox.widget {
		{
			{
				{text = e, align = 'center', widget = wibox.widget.textbox},
				widget = wibox.container.background
			},
			margins = 5,
			widget = wibox.container.margin
		},
		forced_height = 45,
		widget = wibox.container.background
	}
end

local public = {}


local gbb

function public.hide()
	starmenu.visible = false
	clear()
	search_str = ''
	if gbb then
		awful.keygrabber.stop(gbb)
	end

end

local function run_program(pos)

			local command = nil
			if pos > 0 then
				command = filtered[pos][2]


			else
				command =  search_str
			end

			if command then
				awful.spawn.with_shell(command)

			end

			search_str = ''

			clear()
			search.text = prompt
			--
			public.hide()
end

local spacer = create_spacer('Run')
spacer:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
run_program(0)
end
end)

menus:add(spacer)
for i=1,maxitm do


	local namee = ''
	local image = ''
	if menu_items[i] then
		if #menu_items[i]> 0 then
			image = menu_items[i][3]

			namee = menu_items[i][1]
		end
	end
	local name = wibox.widget {
		{
			{text = namee, widget = wibox.widget.textbox},
			right = 10,
			left = 25,
			widget = wibox.container.margin
		},
		shape = tshape.finish_right_powerline,
		bg = '',

		widget = wibox.container.background
	}
	name.forced_width = starmenu.width + 10
	local imbox = wibox.container.background(
	wibox.container.margin(wibox.widget.imagebox(image), 5,
	20, 5, 5), '', tshape.start_right_powerline)
	imbox.forced_width = 50
	local widget = wibox.widget {
		{
			{
				spacing = -20,
				layout = wibox.layout.fixed.horizontal,
				imbox,
				name
			},
			margins = 5,
			widget = wibox.container.margin
		},
		forced_height = 45,
		widget = wibox.container.background
	}
	if (namee == '') then
		widget.visible = false

	end
	widget:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
run_program(i+SHIFT)
end
end)

	menus:add(widget)
end

local function update_color()
	for i = 1, 4 do colors[i] = tcolor.get_color(i, 'tg') end
	selcolor = tcolor.get_color(1, 'tgs')
	unselect = colors[1]
	search_bg.bg = unselect
	starmenu.bg = '#ff0000'
	search_bg:get_children()[1]:get_children()[1].bg = colors[2]
	menus.bg = colors[1]

	beautiful.prompt_fg_cursor = colors[2]
	beautiful.prompt_bg_cursor = colors[1]
	user_widget:get_children()[1].bg = colors[3]
	user_widget:get_children()[2].bg = colors[2]
	user_widget:get_children()[3].bg = colors[1]
	menus.item_active_color = selcolor
	menus.item_unselect_color = unselect
	menu.bg = unselect
	local itm = menus:get_children()



	for i=1,#itm do
		if i == 1 then
			itm[i].bg = selcolor
		else
			itm[i].bg = unselect
		end
		if i > 1 then

			itm[i]:get_children()[1]:get_children()[1]:get_children()[1].bg =
			colors[4]
			itm[i]:get_children()[1]:get_children()[1]:get_children()[2].bg =
			colors[2]
		else
			itm[i]:get_children()[1]:get_children()[1].bg = colors[2]

		end
	end
end

update_color()

awesome.connect_signal('color_change', function() update_color() end)

function public.volume_show()
	public.hide()
	vole.start()

end
function public.wallpaper_show()
	public.hide()

	wallpaper.show()
end
function public.exit_show()
	show_exit.show()

	public.hide()
end
function public.notify_show()
	public.hide()
	notd.start()
end
function volume_up()
	vole.change_volume(true,1, 10)
end
function volume_down()
	vole.change_volume(true,1, -10)
end
function volume_mute()
	vole.mute(true,1)
end
function mic_up()
	vole.change_volume(true,2, 10)
end
function mic_down()
	vole.change_volume(true,2, -10)
end
function mic_mute()
	vole.mute(true,2)
end
local cur_pos = 1
local gstring = gears.string
local function prompt_text_with_cursor()
	local char, spacer, text_start, text_end, ret
	local text = search_str


	if cur_pos <0 then cur_pos = 0  end
	cur_pos = (cur_pos<2 and 2) or (cur_pos > #text+2 and  #text+1) or cur_pos

	if #text <cur_pos then
		char = " "
		spacer = ""
		text_start = gstring.xml_escape(text)
		text_end = ""
	else
		char = gstring.xml_escape(text:sub(cur_pos, cur_pos))
		spacer = " "
		text_start = gstring.xml_escape(text:sub(1,cur_pos - 1))
		text_end = gstring.xml_escape(text:sub(cur_pos + 1))
	end





	search.markup = prompt .. text_start .. "<span background=\"" ..  colors[1] .. "\">" .. char .. "</span>" .. text_end .. spacer
	return ret
end
starmenu:connect_signal("button::press", function(_,_,_,b)
if b == 4 then

			pos = pos -1>0 and pos-1 or 1
			update()
		elseif b == 5 then

			pos = pos +1
			update()
		end
end)


function public.show()
	pcall(update_uptime)
	starmenu.x = mouse.screen.geometry.x
	starmenu.y = mouse.screen.geometry.height - starmenu.height -20

	prompt_text_with_cursor()


	gbb = awful.keygrabber.run(function(mod, key, event)
		if event == "release" then return end

		local ind = 0
		key = (key == " " and "space") or key

		ind = require('functions').compare_key(keys,key,mod)
		if ind ~=0 then

			local opperation = keys[ind][4]
			if opperation == 'wallpaper_show' then
				public.wallpaper_show()
			elseif opperation =='volume_show' then
				public.volume_show()
			elseif opperation =='exit_show' then
				public.exit_show()
			elseif opperation =='prev_entry' then
				pos = pos -1>0 and pos-1 or 1
				update()
			elseif opperation =='next_entry' then
				pos = pos +1
				update()
			elseif opperation =='exec' then
				run_program(pos-1)
			elseif opperation =='quit'then
				public.hide()
			elseif opperation =='keys' then
				hotkeys_popup.show_help("startmenu")
			end

		else
			if key:wlen() == 1 then

				key = key:lower()
				search_str =  search_str:sub(1, cur_pos - 1) .. key ..
				search_str:sub(cur_pos)
				cur_pos = cur_pos + #key



			elseif key == 'BackSpace' then
				if cur_pos > #search_str then
					search_str = search_str:sub(1, #search_str-1)
				else
					search_str = search_str:sub(1, cur_pos - 2) ..search_str:sub(cur_pos  )
					cur_pos = cur_pos -1
				end


			end
			add(search_str)


			prompt_text_with_cursor()
		end
	end)
	--]]


	starmenu.visible = true
end

return public
