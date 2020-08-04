local awful = require("my.awful")
local gears = require("my.gears")
local wibox = require("my.wibox")
local tshape = require('tools.shapes')

local tcolor = require('tools.colors')

local password = 'awesomeWm'
local icon_font = "Font Awesome 5 Free 60"
local poweroff_text_icon = ""
local reboot_text_icon = ""
local restart_awesome_icon = ""
local exit_text_icon = ""
local lock_text_icon = ""


local function bgg(w, shape)
    if shape == nil then shape = gears.shape.powerline end
    return wibox.widget {
        {
            {
                text = tostring(w),
                font = icon_font,
                widget = wibox.widget.textbox,
                forced_height = 150
            },

            left = 100,
            right = 100,
            widget = wibox.container.margin
        },

        shape = shape,
        widget = wibox.container.background
    }
end
local username = os.getenv("USER")

local usericon =  os.getenv('HOME')..'/.config/awesome/images/profile.jpg'
local prompt = wibox.widget.textbox('dwadwa')
local function ss(w, s)
    if s == nil then s = tshape.leftpowerline end
    return wibox.widget {
        {
            w,
            left = 200,
            top = 20,
            bottom = 20,
            right = 150,
            widget = wibox.container.margin
        },

        shape = s,
        widget = wibox.container.background
    }
end

local goodbye_widget = wibox.widget {
    ss(wibox.widget {
        {image = usericon, widget = wibox.widget.imagebox, forced_height = 200},
        {font = "sans 50", text = username, widget = wibox.widget.textbox},
        spacing = 50,
        layout = wibox.layout.fixed.horizontal
    }),
    ss(prompt,gears.shape.rectangular_tag),
    layout = wibox.layout.align.horizontal

}
goodbye_widget:set_spacing(-125)
prompt.font = "sans 50"

local comm = {}

local comme = {'Power off', 'Reboot',  'Reload', 'Exit', 'Lock'}
table.insert(comm, bgg(poweroff_text_icon))

table.insert(comm, bgg(reboot_text_icon))

table.insert(comm, bgg(restart_awesome_icon))
table.insert(comm, bgg(exit_text_icon))

table.insert(comm, bgg(lock_text_icon, tshape.taskendleft))

local index = #comm
local timeout = 5

local s = 0
local locked = false
local pass = ''
local clock = gears.timer {
    timeout = 1,

    callback = function(e)
        s = s + 1
        prompt.text = comme[index] .. ': ' .. timeout - s
        if s == timeout then
            if index == 1 then
                awful.spawn.with_shell("poweroff")
            elseif index == 2 then
                awful.spawn.with_shell("reboot")

            else
                awesome.quit()
            end
            e:stop()
        end

    end
}

clock:connect_signal('start', function()
    s = 0
    prompt.text = comme[index] .. ': ' .. timeout - s
end)

local exit_screens = {}
for s in screen do
table.insert(exit_screens, wibox({
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = s.geometry.height,
    visible = false,
    ontop = true,
screen = s,
    fg = '#000000',
    bg = '#000000AA'
}))
end
local exit_screen_grabber

local function change(i)
    if i == index then return end
    if i > #comm then
        i = 1
    elseif i < 1 then
        i = #comm
    end
    if not locked then
        local ine = (index - 1)%4+2
	ine = ine > 4 and 1 or ine
	    comm[index].bg = tcolor.get_color(ine, 'tg')
clock:stop()
        index = i

        comm[index].bg = tcolor.get_color(1, 'tgs')
        prompt.text = comme[index]
    end
end
function exit_screen_hide()
    if locked  then
	    return
    end
if clock.started then
           clock:stop()

                prompt.text = comme[index]
return
end
    awful.keygrabber.stop(exit_screen_grabber)
  for _,a in pairs(exit_screens) do
    a.visible = false
    end
end
local function rotate(i) change(index + i) end
function show_exit()
    comm[index].bg = tcolor.get_color(1, 'tgs')
    prompt.text = comme[index]
    exit_screen_grabber = awful.keygrabber.run(
                              function(_, key, event)
            if event == "release" then return end
if key == "XF86AudioRaiseVolume" then
volume_up()
elseif key =="XF86AudioLowerVolume" then
	volume_down()
elseif key == "XF86AudioMute" then
	volume_mute()

end
	    if clock.started then
                clock:stop()

                prompt.text = comme[index]
                return
            end
            if locked then
                if #key == 1 then
                    pass = pass .. key
                    prompt.text = 'Password:' .. pass:gsub('.', '*')
                elseif key == 'BackSpace' then
                    pass = pass:sub(1, #pass - 1)
                    prompt.text = 'Password:' .. pass:gsub('.', '*')
                elseif key == 'Return' then

                    if pass ~= password then

                        awful.spawn.easy_async_with_shell(
                            '	ffmpeg -f video4linux2 -s 800x600 -i /dev/video0 -ss 0:0:10 -frames 10 /tmp/intruder.gif',
                            function() end)
                    else
                        locked = false

                        prompt.text = comme[index]

                    end
                    pass = ''
                end
                return
            end
            if key == 'Left' then

                rotate(-1)

            elseif key == 'Right' then

                rotate(1)

		elseif key == 'Return' or key == ' ' then
                if index == #comm then
                    locked = true
                    prompt.text = 'Password:'
                elseif index == 3 then
                    awesome.restart()
                else
                    clock:start()
                end
            elseif key == 'Escape' or key == 'q' or key == 'x' then

                exit_screen_hide()

            end
        end)
    for _,a in pairs(exit_screens) do
    a.visible = true
    end
end
  for _,a in pairs(exit_screens) do

a:buttons(gears.table.join(
awful.button({}, 1, function()
    if index == #comm then
        locked = true
        prompt.text = 'Password:'
    elseif index == 3 then
        awesome.restart()
    else
        clock:start()
    end
end),
awful.button({}, 2, function()  exit_screen_hide() end),

awful.button({}, 4, function()  rotate(1) end),

awful.button({}, 5, function()  rotate(-1) end),
awful.button({},3,function()  exit_screen_hide() end)
))

end
local sett = wibox.widget {

    spacing = -80,
    layout = wibox.layout.fixed.horizontal
}
local textclock = wibox.widget.textbox('')
textclock.font = 'Sans 75'
textclock.align = 'center'
gears.timer {
    timeout   = 60,
    call_now  = true,
    autostart = true,
    callback  = function()
        textclock.text = os.date("%H:%M")
    end
}

sett:add(wibox.widget {
    textclock,
    shape = tshape.leftstart,
    forced_width = 505,
    widget = wibox.container.background
})

for i, a in pairs(comm) do
    a:connect_signal('mouse::enter', function() change(i) end)

    sett:add(a)
end
local widgett = wibox.widget{
    sett,

    {goodbye_widget, spacing = 30, layout = wibox.layout.fixed.vertical},
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical

}
for _,a in  pairs(exit_screens) do
	a:set_widget(widgett)

end
awesome.connect_signal('color_change', function()
    for i, a in pairs(sett:get_children()) do
 i = i -1
        a.bg = tcolor.get_color(i % 4 + 1, 'tg')
end
    for i, a in pairs(goodbye_widget:get_children()) do
        a.bg = tcolor.get_color(i, 'w')
    end
end)

