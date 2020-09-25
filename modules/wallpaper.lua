local awful = require("my.awful")
local tcolor = require('tools.colors')
local tshape = require('tools.shapes')
local wibox = require("my.wibox")
local gears = require("my.gears")
local settings = require('settings').wallpaper
local naughty = require('my.naughty')
local home = os.getenv('HOME')
local pos = 1
local max = 0
local wallpaper_dir = home .. '/wallpaper/'
local thumbnail_dir = home .. '/.config/awesome/images/thumbnail/'
local wallpaer_changer = settings.wallpaper_command or "xwallpaper --zoom "
local wallpapers = {}
local item_num = settings.items  or 9
local items = item_num
local middle = math.ceil(item_num / 2)
local clock_timeout = 1
local state = false
local clock = 0
local timeout = (settings.default_timeout or (5*60))
local chosen_dir = 1
local chosen_file = 1
local item_active = '#ff0000'
local sel_box = 1
local SHIFT = 0
local default_time_text =   string.format("%02.f", math.floor(timeout / 60))    .. ':' .. string.format("%02.f", timeout %60  )
local sel_dir = 0

local wallpaper_layout = wibox.layout.fixed.horizontal()
local wallpapers_wibox = wibox {
    width = settings.wallpaper_width,
    height = 145,
    fg = '#000000',
    ontop = true,
    visible = false
}

local time_text = wibox.widget.textbox('')

local find_dir_text = wibox.widget.textbox('')

find_dir_text.align = 'center'
local find_dir_wal = wibox.container.background(find_dir_text, '',
                                                tshape.leftstart)
find_dir_wal.forced_width = 175
local text_dir_wal = wibox.container.background(
                         wibox.container.margin(time_text, 20, 10, 0, 0), '',
                         tshape.startn)


local clock_widget = wibox.widget {
    max_value = 1,

    forced_height = 10,
    background_color = '#000000',
    shape = tshape.taskend,

    widget = wibox.widget.progressbar
}

local clock_layout = wibox.widget {
    layout = wibox.layout.align.horizontal,
    find_dir_wal,
    clock_widget,
    text_dir_wal

}
-- clock_layout:set_spacing(-15)

clock_layout.forced_height = 20
wallpapers_wibox:setup{
    layout = wibox.layout.align.vertical,

    clock_layout,
    wallpaper_layout

}
-- functions
local  function change_wallpaper(dir, file)
    if not wallpapers[dir] or not tonumber(file) then return end

    if wallpapers[dir][2] >= tonumber(file) then
        chosen_dir = dir
        chosen_file = file
        local walpaper = wallpaper_dir .. wallpapers[dir][1] .. '/' .. file ..
                             '.jpg'
        awful.spawn.with_shell(wallpaer_changer .. walpaper)

        tcolor.change_colors(file,dir)
    else

        tcolor.change_colors(1, 1)
    end
end
local function random_wallpaper()

    math.randomseed(os.time())

    local dir =  math.random( #wallpapers)

    if wallpapers[dir][2] then
        local file = math.random( wallpapers[dir][2])
        naughty.notify {
            text = tostring( wallpapers[dir][1] .. '/' .. file .. '.jpg'),
            appname = 'Wllpaper changer',
            title = sel_dir == 0 and 'Random wallpaper' or 'wallpaper from ' ..
                wallpapers[dir][1]
        }
        change_wallpaper(dir, file)
    end
end
local function return_img(po)
    local tab = {}
    for i, a in pairs(wallpapers) do
        if sel_dir == 0 or sel_dir == i then
            if a[2] >= po and #tab < items then
                for h = po, a[2] do table.insert(tab, {a[1], h}) end
                po = 1
            else
                po = po - a[2]
            end

        end
    end
    return tab
end

local function update()
    local maxy = max
    if sel_dir > 0 then
        max = (wallpapers[sel_dir][2] > items and wallpapers[sel_dir][2]) or
                  items
        if pos > wallpapers[sel_dir][2] then pos = wallpapers[sel_dir][2] end
    end
    local po =
        (max - pos < middle and max - items + 1) or pos >= middle and pos -
            middle + 1 or 1

    local t = return_img(po)
SHIFT = po -1
    local sel = (max - pos < middle and items - (max - pos)) or
                    (pos < middle and pos) or middle

	    sel_box = sel
		    for i, a in ipairs(wallpaper_layout:get_children()) do
        if i > #t or i > items then
            a.visible = false
        else
            a:get_children()[1]:get_children()[1].image =
                thumbnail_dir .. t[i][1] ..
                    '/' .. t[i][2] .. '.jpg'

            a.visible = true
        end
        if i == sel then
            a.bg = item_active
        else
            a.bg = '#000000'
        end

    end
    t = nil
    max = maxy
end
local function find_dir(t)
    sel_dir = t == 0 and 0 or t + sel_dir

    if sel_dir < 0 then
        sel_dir = #wallpapers
    elseif sel_dir > #wallpapers then
        sel_dir = 0
    end
    if sel_dir == 0 then

        find_dir_text.text = ' '
    else
        find_dir_text.text = wallpapers[sel_dir][1]

    end
    pos = 1
    update()
end

local function get_time(seconds)
    local sec = tonumber(seconds)

local    mins = string.format("%02.f", math.floor(sec / 60));
   local  secs = string.format("%02.f", math.floor(sec - mins * 60));
    time_text.text = mins .. ':' .. secs .. '/' .. default_time_text

end

local function update_timer()
    get_time(timeout - clock)
    clock_widget.value = (timeout - clock) / timeout
    if timeout - clock <= 0 then
        clock = 0
        random_wallpaper()
    end

end

local clock_timer = gears.timer {timeout = clock_timeout}
clock_timer:connect_signal('start', function()

    clock_widget.color = tcolor.get_color(5, 'w')
end)
clock_timer:connect_signal('stop', function()

    clock_widget.color = tcolor.get_color(6, 'w')
end)
clock_timer:connect_signal('timeout', function()

    clock = clock + clock_timeout

    update_timer()

end)
local public = {}
function public.stop()
    state = false
    if clock_timer.started then
        update_timer()

        clock_timer:stop()
    end

end
local gbbe

local function set_wal(a)

    if sel_dir ~= 0 then
        change_wallpaper(sel_dir, a)
        return
    end
    for i, b in pairs(wallpapers) do
        if b[2] >= a then
            if i ~= chosen_dir or a ~= chosen_file then

                change_wallpaper(i, a)

            end
            return
        else
            a = a - b[2]
        end
    end
end
function public.hide()

    wallpapers_wibox.visible = false
    awful.keygrabber.stop(gbbe)

end
function public.show()
	items = math.floor(mouse.screen.geometry.width / (settings.wallpaper_width / item_num))
	middle = math.ceil(items / 2)
	wallpapers_wibox.visible = true
	wallpapers_wibox.y = 0
	wallpapers_wibox.x = mouse.screen.geometry.x
	wallpapers_wibox.width = mouse.screen.geometry.width
	gbbe = awful.keygrabber.run(function(_, key, event)
		if event == "release" then return end
		if key == 'Left' then
			pos = pos - 1 > 0 and pos - 1 or 1
			update()
		elseif key == 'Right' then
			pos = pos + 1 <= max and pos + 1 or pos
			update()
		elseif key == 'Up' then
			find_dir(-1)

		elseif key == 'Down' then
			find_dir(1)
		elseif key == 'r' then
			public.stop()
			clock = 0
			public.start()
		elseif key == 's' then
			public.stop()

		elseif key == 'p' then
			public.start()
		elseif key == 't' then

			naughty.notify {text = tostring( math.floor(timeout - clock))}

		elseif key == ' ' or key == 'Return' then
			set_wal(pos)
		elseif key == 'x' or key == 'Escape' then
			public.hide()
		elseif tonumber(key) then
			clock = math.floor (timeout *((tonumber(key) ==0 and 0 or (1-tonumber(key)/10)) or 0))

			update_timer()
		end
	end)
	local h = 0
	find_dir(0)
	for i = 1, chosen_dir - 1 do h = h + wallpapers[i][2] end

	pos = h + chosen_file
	update()
end
function public.start()

    state = true
    update_timer()

    clock_timer:start()

end
awesome.connect_signal('color_change', function()

	item_active = tcolor.get_color(1, 'tgs')

wallpaper_layout:get_children()[sel_box].bg = item_active
    wallpaper_layout.item_unselect_color = '#000000'
    find_dir_wal.bg = tcolor.get_color(1, 'w')

    text_dir_wal.bg = tcolor.get_color(3, 'w')
    if clock_timer.started then
        clock_widget.color = tcolor.get_color(5, 'w')
    else
        clock_widget.color = tcolor.get_color(6, 'w')
    end
end)
awesome.connect_signal('exit', function()
    local e =  clock
    local stat = 'false'
    if e >= timeout then e = 0 end
if state then
stat = 'true'
end
    if not chosen_dir then chosen_dir = 1 end
    awful.spawn.with_shell('echo   "return{' .. e .. ',' ..
                                          chosen_file .. ',' .. chosen_dir ..
                                          ',' .. stat ..
                                          '}"  > ~/.config/awesome/config/wallpaper.lua')
end)
local he = {}
local dir = {}
local function get_wallpaers()

local be = require('config.wallpapers')
if be then
	he = be
end

end

local function get_wallpaer()

local be = require('config.wallpaper')
if be then
	dir = be
end

end
local function get_configs()
	pcall(get_wallpaers)
	pcall(get_wallpaer)
	if #he > 0 then
for e, a in pairs(he) do

    table.insert(wallpapers, {a[1], a[2]})
    max = max + a[2]
end
end
if #wallpapers >0 then
gears.timer.start_new(0.2, function()

    for i = 1, item_num do

        local im = wibox.widget {
            {
                wibox.widget.imagebox(
                    thumbnail_dir .. wallpapers[1][1] .. '/' .. i .. '.jpg'),

                left = 5,
                top = 5,
                right = 5,
                widget = wibox.container.margin
            },
            widget = wibox.container.background
        }

        im.forced_width = settings.wallpaper_width / item_num

	im:connect_signal("button::press", function(_,_,_,b)
		if b == 1 then
			set_wal(i+SHIFT)
			pos  =i+SHIFT
			update()
			elseif b ==4 then
			pos = pos + 1 <= max and pos + 1 or pos

				update()
			elseif b ==5 then
			pos = pos - 1 > 0 and pos - 1 or 1
				update()

		end
	end)
        wallpaper_layout:add(im)
    end

end)
if #dir > 0 then
local t = tonumber(dir[1])
local f = tonumber(dir[2])
local d = tonumber(dir[3])
 state = dir[4]
local h = 0
for i = 1, d - 1 do h = h + wallpapers[i][2] end


if d and f then change_wallpaper(d, f) end
if t > 0 then

    clock = t

clock_widget.value = t / timeout
else

    clock = 0
clock_widget.value = 0

end

get_time(timeout - t)

if state == true then
    clock_widget.color = tcolor.get_color(5, 'w')

    public.start()
else
    clock_widget.color = tcolor.get_color(6, 'w')

end

end
else

clock_widget.value = 1

get_time(timeout)
tcolor.change_colors(1, 1)

end

    find_dir_wal.bg = tcolor.get_color(1, 'w')

    text_dir_wal.bg = tcolor.get_color(3, 'w')
end
get_configs()
return public
