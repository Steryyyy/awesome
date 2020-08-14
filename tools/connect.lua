local awful = require("my.awful")

local beautiful = require("my.beautiful")
local gears = require("my.gears")
local term_command = [[
urxvtc -name dropdown-terminal %s
]]
local fullhight = false

local terminals = {}
local index = 1

 Request = false
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

function move_and_toggle(c, t)
    if c.first_tag.index ~= t and not  (c.sticky) then
if (not mouse.screen.tags[t].urgent) then
        c.urgent = true
end

        c:move_to_tag(mouse.screen.tags[t])
else
        c.urgent = false
    end
end

local function set_default(c)

    c.focus = awful.client.focus.filter
    if c.floating then
    c.rise = true
    local s = c.screen.workarea
    c.x = (s.width - c.width-30)/2 + s.x
    c.y = (s.height - c.height-30)/2 + s.y

     c:relative_move(0,0,0,0)
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
local function find_class(c)
    set_default(c)
    if c.class == 'firefox' then
        move_and_toggle(c, 2)
        return true

    elseif c.class == "Spotify" then
        move_and_toggle(c, 4)
        c:connect_signal('unmanage',
                         function() require('widgets').player.status() end)
        return true
    elseif c.class == 'discord' then
        move_and_toggle(c, 3)
        return true
    elseif c.class == 'Steam' then
        move_and_toggle(c, 5)
        return true
    end

    return false
end
local dele = false
local function manage(c)

    if c.instance == 'dropdown-terminal' or c.instance == 'dropdown-terminalr' then

        c.size_hints_honor = false
        c.floating = true
        c.index = #terminals + 1
        table.insert(terminals, c)
        c.keys = gears.table.join(awful.key({'Mod4'}, "Return", function()
            Request = true
            awful.spawn.with_shell(string.format(term_command, "", ""))
        end), awful.key({'Mod4'}, "f", function()

	fullhight = not fullhight
            terminals[index].height = (fullhight and
                                          mouse.screen.geometry.height or
                                          mouse.screen.geometry.height / 2)
        end), awful.key({'Mod4'}, "KP_Left", function()
            c.width = c.screen.geometry.width / 2
            c.height = c.screen.geometry.height
            c.x = c.screen.geometry.x
            c.y = c.screen.geometry.y
        end), awful.key({'Mod4'}, "KP_Right", function()
            c.width = c.screen.geometry.width / 2
            c.height = c.screen.geometry.height
            c.x = c.screen.geometry.width - c.width + c.screen.geometry.x
            c.y = c.screen.geometry.y
        end), awful.key({'Mod4'}, "KP_Up", function()
            c.width = c.screen.geometry.width
            c.height = c.screen.geometry.height / 2
            c.x = c.screen.geometry.x
            c.y = c.screen.geometry.y
        end), awful.key({'Mod4'}, "KP_Down", function()
            c.width = c.screen.geometry.width
            c.height = c.screen.geometry.height / 2
            c.x = c.screen.geometry.x
            c.y = c.screen.geometry.height - c.height + c.screen.geometry.y
        end), awful.key({'Mod1'}, "Right", function(c) dropdown(1) end),
                                  awful.key({'Mod1'}, "Left",
                                            function() dropdown(-1) end),
                                  awful.key({'Mod1'}, "q", function(c)

            dele = true
            c:kill()
        end))

        c.sticky = true
        c.border_width = 0
        c.hidden = true
        c:connect_signal('unmanage', function(c)

            table.remove(terminals, c.index)
            for a, b in pairs(terminals) do b.index = a end
            index = 1
            if dele then
                dele = false
                position()
            end
        end)
        c:connect_signal('unfocus', function(c) c.hidden = true end)

        c.ontop = true
        c.y = 0
        c.x = 0
        c.width = c.screen.geometry.width
        c.height = c.screen.geometry.height / 2

        move_and_toggle(c, 6,true)

        if Request or c.instance == 'dropdown-terminalr' then
            c.instance = 'dropdown-termil'
            if #terminals > 1 then terminals[index].hidden = true end
            index = c.index

            position()

            Request = false


        end

        return true
    end
    return false
end
next_floating = false
client.connect_signal("manage", function(c)

    if manage(c) then return end

    if c.class == '' or c.class == nil then
        move_and_toggle(c, 6)
        c.border_width = 3
        c.border_color = beautiful.border_normal
        c:connect_signal('property::class', function(c) find_class(c) end)
        return
    end
    find_class(c)

if c.first_tag.index == mouse.screen.selected_tag.index then
c:activate()
end

    if next_floating then
	    c.floating = true
    end
    if awesome.startup and not c.size_hints.user_position and
        not c.size_hints.program_position then
c:relative_move(0,0,0,0)

    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_color_active
end)
client.connect_signal("unfocus", function(c) c.border_color = '#000000' end)

local function toggle()

    if #terminals == 0 then
        Request = true
        awful.spawn.with_shell(string.format(term_command, "", ""))
        return
    end

    if #terminals >= index and index > 0 then

        position()

    else
        return
    end
end

return toggle
