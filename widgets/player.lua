local awful = require("my.awful")

-- Widget and layout library
local wibox = require("my.wibox")
local gears = require("my.gears")

local icon_play = ' '
local icon_pause = ' '
local icon_next = ''
local icon_prev = ' '
local term_command =[[
urxvtc -name dropdown-terminal  -e cmus
]]
local sp_album = '/home/steryyy/.config/awesome/images/album.png'

local icon_spotify = ''
local icon_cmus = ''

local get_vol = [[
        pacmd list-sink-inputs | grep -e "index"  -e "volume" -e "application.name ="  | sed -E '3~3 a|' | tr -d "\n"   | tr -d "%" | sed -E 's/\|/\n/g' | awk '{print $2"|" $7"|" substr($0,index($0,$20))}' ]]
local getspotufy_album = [[
    wget -O ]] .. sp_album ..
                             [[ "http://i.scdn.co/image/"$(sp art |  sed -e 's/^.*\///')
]]
local get_spotify = [[
    (sp status && sp current-oneline) | tr '\n' ' ' | sed 's/ | /|/g' | awk '{print $1"|"substr($0,index($0,$2))"|" }'

]]
local get_cmus = [[
    cmus-remote -Q | grep "status\|file" |   sed  -e 's/^.*\///' -e 's/\..*$//' | tr '\n' ' ' | awk '{print$2"|"substr($0,index($0,$3)) }'


]]

-- widgets
local song = {artist = '', song = '', cover = '', pos = 0, len = 0}

local widget_state = wibox.widget.textbox(icon_pause)
widget_state.font='Font Awesome 5 Brands 13'

local widget_prev = wibox.widget.textbox(icon_prev)
widget_prev.font='Font Awesome 5 Brands 13'

local widget_next = wibox.widget.textbox(icon_next)
widget_next.font='Font Awesome 5 Brands 13'
local widget_song = wibox.widget.textbox('', false, '#000000')
local widget_spawn = wibox.widget.textbox(icon_spotify)
widget_spawn.font ='Font Awesome 5 Brands 13'
-- Players

-- Mocp

local function get_volume(vol) return math.floor(65536 * vol / 100) end
-- cmus

local player = {}
player.color = {'#FF8C00'}
local widget_volume = wibox.widget {
    max_value = 1,
    color = player.color[1],
    background_color = '#ffff0000',
    forced_width = 50,
    margins = {top = 0, bottom = 0},
    widget = wibox.widget.progressbar
}

player.selected = 'cmus'
-- dbus functions
player.dbus_command = function(command)
awful.spawn.with_shell(
        "dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2." ..
            player.selected ..
            " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command)
end
player.next = function() player.dbus_command('Next') end
player.prev = function() player.dbus_command('Previous') end
player.play = function() player.dbus_command('PlayPause') end
player.pause = function() player.dbus_command('Pause') end

player.change = function()
    player.pause()
    if player.selected == 'spotify' then
        player.selected = 'cmus'

    else
        player.selected = 'spotify'
    end
    player.hidebuton(false)

    player.status()
    awful.spawn.with_shell('echo "return[[' .. player.selected ..
                                    ']]" > ~/.config/awesome/config/player.lua')

end



-- volume functions
local function change_volume(a)

    if player.id and player.volume then

        player.volume = player.volume + a
        if player.volume > 100 then

            player.volume = 100
        elseif player.volume < 0 then
            player.volume = 0
        end

        awful.spawn.with_shell('pacmd set-sink-input-volume ' .. player.id ..
                                   ' ' .. get_volume(tonumber(player.volume)))
    end
end
player.inc = function() change_volume(5) end
player.dec = function() change_volume(-5) end
local function get_volume(play)
    awful.spawn.easy_async_with_shell(get_vol .. "| grep '" .. play .. "'",
                                      function(out)

        see = gears.string.split(out, '|')

        if see[2] then

            player.id = tonumber(see[1])

            player.volume = tonumber(see[2])
            widget_volume.value = player.volume / 100

        end

    end)
end

-- get player
player.cmus_state = function()
    awful.spawn.easy_async_with_shell(get_cmus, function(out)

        local arr = gears.string.split(out, '|')


        if arr[1] ~= 'cmus-remote: cmus is not running' and arr[1] ~=''  then

            local stat = arr[1]
            if stat == 'playing' then
                widget_state.text = icon_pause
            else
                widget_state.text = icon_play
            end
            if   not string.match( arr[2] ,'status stopped') then
            local so = arr[2]
            player.trimsong(so)

            get_volume('C* Music Player')
            else
                player.trimsong('')
        end
            player.hidebuton(true)
        else
            player.hidebuton(false)
        end

    end)
end

player.spotify_state = function()
    awful.spawn.easy_async_with_shell(get_spotify, function(out)

        local arr = gears.string.split(out, '|')

        if arr[1] ~= 'Error:' then
            local stat = arr[1]
            if stat == 'Playing' then
                widget_state.text = icon_pause
            else
                widget_state.text = icon_play
            end

            song.artist = arr[2]
            song.song = arr[3]
            awful.spawn.easy_async_with_shell(getspotufy_album, function(out)
                song.cover = sp_album

            end)

            get_volume('Spotify')

            player.trimsong(arr[3])

            player.hidebuton(true)

        else
            player.hidebuton(false)
        end

    end)
end
player.status = function()

    if player.selected == 'spotify' then
        widget_spawn.text = icon_spotify
        player.spotify_state()
    elseif player.selected == 'cmus' then
        widget_spawn.text = icon_cmus
        player.cmus_state()

    end
end

player.init = function()

        player.status()
	function chane_player()
        local be = require('config.player')
	player.selected =be
	if player.selected ~= 'cmus' and player.selected ~= 'spotify' then
player.selected  = 'spotify'
	end
end
pcall(chane_player)


end

-- Stoping massive notifications
player.wait = gears.timer {
    timeout = 0.5,
    callback = function()
        player.wait:stop()
        player.status()
    end
}

-- Listen to notification
dbus.add_match("session",
               "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties'")
dbus.connect_signal("org.freedesktop.DBus.Properties", function()
    if player.wait.started then return end

    player.wait:start()

end)

player.update = function() widget_volume.color = player.color[1] end

widget_volume.value = 1

local songwidget = wibox.widget {
    {widget = widget_volume},
    {
        {widget = widget_prev},
        {widget = widget_state},
        {widget = widget_song},
        {widget = widget_next},

        layout = wibox.layout.fixed.horizontal
    },

    layout = wibox.layout.stack
}
player.hidebuton = function(te)
    widget_spawn.visible = not te
    songwidget.visible = te

end

player.spawn = function()
    if songwidget.visible == false then
    if player.selected == 'spotify' then
        awful.spawn("spotify", false)
    else
        awful.spawn.with_shell("awesome-client 'Request=true' &&  " .. term_command , false)
    end
end
end
player.trimsong = function(songname)

    if not songname then return end
	if string.len(songname) > 50 then songname = songname:sub(1, 50) end

    widget_song.text = songname

end
songwidget.visible = false
player.widget = wibox.widget {

    songwidget,

    widget_spawn,

    layout = wibox.layout.fixed.horizontal
}

player.init()

return player