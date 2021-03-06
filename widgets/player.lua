local awful = require("awful")

-- Widget and layout library
local wibox = require("wibox")
local gears = require("gears")

local beautiful = require("beautiful")
local settings = require('settings').widgets.player
local max_song_title = settings.max_song_title or 60
local icon_play = ' '
local icon_pause = ' '
local icon_next = ''
local icon_prev = ' '

local icon_spotify = ''
local icon_cmus = ''

local get_vol = "pacmd list-sink-inputs | awk -f ~/.config/awesome/scripts/get_clients.awk  "
-- local getspotufy_album = [[ curl "http://i.scdn.co/image/"$(sp art |  sed -e 's/^.*\///') > ~/.config/awesome/images/album.png ]]
local get_spotify = [[
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.GetAll string:'org.mpris.MediaPlayer2.Player'  | grep -Ev '^method|Metadata' | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)|true|false' | sed '2~2 a |' | tr -d '\n' | sed -e 's/|/\n/g' | sed -e 's/^"//g' -e 's/"$//g' | sed -E 's/"+/|/g' | sed 's/xesam:\|mpris://g'| grep  "PlaybackStatus|\|artUrl|\|title|\|artist|" | awk -F '|' '{switch($1) {case "PlaybackStatus":play=$2; break; case "title": title=$2; break; case "artist": artist=$2; break; case "artUrl": art=$2; break; }  } END{print play"|"artist"|"title"|"art }'
]]
local get_cmus = [[
    cmus-remote -Q | awk '/(status|file)/ {{gsub("^.*\\/","")}  a=a" "$0} END {{$0=a} {$1=""}{$2="|"$2"|"}{$NF=$NF"|"} print $0}'

]]

-- widgets
local song = {artist = '', song = '', cover = '', pos = 0, len = 0}

local widget_state = wibox.widget.textbox(icon_pause)
widget_state.font=beautiful.font_icon

local widget_prev = wibox.widget.textbox(icon_prev)
widget_prev.font=beautiful.font_icon
local widget_next = wibox.widget.textbox(icon_next)
widget_next.font=beautiful.font_icon
local widget_song = wibox.widget.textbox('')
widget_song.font = (settings.player_font or beautiful.font )
local widget_spawn = wibox.widget.textbox(icon_spotify)
widget_spawn.font =beautiful.font_icon

local function to_pulse(vol) return math.floor(65536 * vol / 100) end

local player = {}
player.color = {'#FF8C00','#ff0000'}
player.volume =0
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

    --[[
    elseif player.selected == "musicpv" then
        player.selected = 'spotify'
	else
    --]]
else
        player.selected = 'spotify'
        -- player.selected = 'musicpv'
    end
    player.hidebuton(false)

    player.status()
    awful.spawn.with_shell([[echo "return']] .. player.selected ..
                                    [['" > ~/.config/awesome/config/player.lua]])

end



-- volume functions
local function change_volume(a)

        player.volume = player.volume + a

	if player.volume > 100 then

            player.volume = 100
        elseif player.volume < 0 then
            player.volume = 0
        end
if player.selected ~= "musicpv" then
    if player.id  then


        awful.spawn.with_shell('pacmd set-sink-input-volume ' .. player.id ..
                                   ' ' .. to_pulse(tonumber(player.volume)))

end
else

awful.spawn.with_shell("dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2.musicpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:'org.mpris.MediaPlayer2.Player' string:'Volume' variant:double:"..tostring(player.volume/100))




    end
end
local muted = false
player.inc = function() change_volume(5) end
local last_vol = 0
player.mute = function()
muted = not muted
-- widget_volume.color = muted and player.color[2] or player.color[1]
if player.selected ~= "musicpv" then

	awful.spawn.with_shell('pacmd set-sink-input-mute ' .. player.id ..
                                   ' ' .. tostring(muted))

widget_volume.color = muted and '#ff0000' or player.color[1]
	   else

last_vol = muted and player.volume or last_vol

player.volume = muted and 0 or last_vol
awful.spawn.with_shell("dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2.musicpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:'org.mpris.MediaPlayer2.Player' string:'Volume' variant:double:"..tostring(player.volume/100))
end

end
player.dec = function() change_volume(-5) end
local function get_volume(play)
    awful.spawn.easy_async_with_shell(get_vol .. "| grep -i '" .. play .. "'",
                                      function(out)

        local see = gears.string.split(out, '|')

        if see[2] then

            player.id = tonumber(see[1])

            player.volume = tonumber(see[3])
	muted = see[4] == 'yes' and true or false

widget_volume.color = muted and player.color[2] or player.color[1]
            widget_volume.value = player.volume / 100

        end

    end)
end

-- get player
player.cmus_state = function()
    awful.spawn.easy_async_with_shell(get_cmus, function(out)

        local arr = gears.string.split(out, '|')
	if #arr[2]  > 4  then

            if string.find(arr[2],'playing') then
                widget_state.text = icon_pause
            else
                widget_state.text = icon_play
            end
            if    arr[2] ~='stopped' then
            player.trimsong(arr[3])

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
local get_musicpv_title = [[ dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2.musicpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep "xesam:title"   | sed -e 's/  */ /g ' -e 's/)//g' | cut -f4- -d ' '  ]]

local get_musicpv_volume = [[ dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2.musicpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Volume'  | awk '{print $NF"|"}'  ]]
local function musicpv_get()


            player.hidebuton(true)


    awful.spawn.easy_async_with_shell(get_musicpv_title, function(out)
    local arr = gears.string.split(out,"|")
    if arr[1] then
	    player.trimsong(arr[1])
    end

    end)


    awful.spawn.easy_async_with_shell(get_musicpv_volume, function(out)
    local arr = gears.string.split(out,"|")
    player.id = nil

    if arr[1] then

            player.volume = tonumber(arr[1]) *100
            widget_volume.value = player.volume / 100
    end

    end)
end
local get_musicpv_state = [[ dbus-send --print-reply=literal --dest=org.mpris.MediaPlayer2.musicpv /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' | awk '{print $2"|"}'  ]]

player.musicpv_state  = function()

    awful.spawn.easy_async_with_shell(get_musicpv_state, function(out)

        local arr = gears.string.split(out, '|')
if arr[1] =="Playing" then

                widget_state.text = icon_pause
	musicpv_get()
elseif arr[1] == "Paused" then

	musicpv_get()
                widget_state.text = icon_play
		else

            player.hidebuton(false)
end


    end)
end


player.spotify_state = function()
    awful.spawn.easy_async_with_shell(get_spotify, function(out)
        if out =="" then
	player.hidebuton(false)
	return
	end
	    local arr = gears.string.split(out, '|')
	    if #arr<2 or arr[2] =="" then
		    return
	    end
        if #arr >=3   then
            local stat = arr[1]
            if stat == 'Playing' then
                widget_state.text = icon_pause
            else
                widget_state.text = icon_play
            end

            song.artist = arr[2]
            song.song = arr[3]
	    if #arr >3 then
	    local album = gears.string.split(arr[4],'/')
	    	album = album[#album]
    		end
            --[[
            awful.spawn.easy_async_with_shell(getspotufy_album, function()
                song.cover = '~/.config/awesome/images/album.png'

            end)
            --]]

            get_volume('spotify')

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
    else
        widget_spawn.text = icon_cmus
        player.cmus_state()
--[[
elseif player.selected == "musicpv" then
player.musicpv_state()
--]]
    end
end

player.init = function()

	function chane_player()
        local be = require('config.player')
	player.selected =be

        player.status()
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

local widget_spacer = wibox.widget.textbox()
widget_spacer.forced_width = 10
widget_volume.value = 1

local songwidget = wibox.widget {
    {widget = widget_volume},
    {

        {widget = widget_prev},
        {widget = widget_state},
        {widget = widget_song},

        {widget = widget_spacer},
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
        awful.spawn.with_shell("awesome-client ' dropdown_terminal_open([["..player.selected.."]])'" )
    end
end
end
player.trimsong = function(songname)

    if not songname then return end
	if string.len(songname) > max_song_title then songname = songname:sub(1, max_song_title) end
local ine = string.find(songname,'%.')
if ine then
songname = songname:sub(1,ine-1)
end

   widget_song.text = songname

end
widget_spawn:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
player.spawn()
end
end)
widget_prev:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
player.prev()
end
end)
widget_next:connect_signal("button::press", function(_,_,_,b)
if b == 1 then
player.next()
end
end)
widget_volume:connect_signal("button::press", function(_,_,_,b)

if b == 1 then
player.play()
elseif b == 4 then
player.inc()
elseif b == 5 then
	player.dec()
end
end)

songwidget.visible = false
player.widget = wibox.widget {

    songwidget,

    widget_spawn,

    layout = wibox.layout.fixed.horizontal
}

player.init()

return player
