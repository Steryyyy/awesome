local wibox = require("my.wibox")
local awful = require("my.awful")
local gears = require("my.gears")
local tshape = require('tools.shapes')
local tcolor = require('tools.colors')
local naughty = require("my.naughty")
local beautiful = require("my.beautiful")
local settings = require('settings').volume_con
local pos = 1
local maxitems = settings.items > 5  and settings.items or 5

local client_base = " | awk -f ~/.config/awesome/scripts/get_clients.awk"
local base = " | awk -f ~/.config/awesome/scripts/get_cards.awk"
local pacmd = "LANG=C pacmd "
local list_sinks = pacmd .."list-sinks" .. base
local list_sources = pacmd.. "list-sources" .. base
local list_sinks_inputs = pacmd.. "list-sink-inputs" .. client_base
local list_source_outputs = pacmd.. "list-source-outputs" .. client_base
local colors = {
    '#ff0000', '#ff0000', '#ff0000', '#ff0000', '#ff0000', '#ff0000', '#ff0000',
    '#ff0000', '#ff0000'
}

local function create_tab(name, shape)

    local cce = wibox.widget {
        {
            {
                layout = wibox.layout.fixed.vertical,
                {text = name, align = 'center', widget = wibox.widget.textbox},
                {
                    wibox.widget.base.make_widget(),

                    forced_height = 5,

                    id = 'bg',
                    widget = wibox.container.background
                }
            },
            left = 20,
            right = 20,
            widget = wibox.container.margin
        },

        shape = shape,
        widget = wibox.container.background
    }

    return cce
end
local sel = ''
local unsel = ''
local muted = ''
local function create_page()

    local ge = wibox.layout.fixed.vertical()
    return ge
end

local volume_wibox = wibox {width = settings.width or   560, height =  settings.height  or 380}
volume_wibox.fg = '#000000'
volume_wibox.ontop = true
volume_wibox.visible = false

local chosen_tab = true
local tabs = {}
local tab_layout = wibox.layout.flex.horizontal()
tab_layout.spacing = -15
tab_layout.forced_height = 30
tabs[true] = create_tab('Cards', tshape.leftstart)
tabs[false] = create_tab('Clients', tshape.taskendleft)

tab_layout:add(tabs[true])
tab_layout:add(tabs[false])

local volume_pages = {}
volume_pages[true] = create_page()
volume_pages[false] = create_page()

volume_pages[true].visible = true

volume_pages[false].forced_height = settings.height or 380
volume_pages[true].forced_height = volume_pages[false].forced_height
local bord = wibox.widget {
            layout = wibox.layout.fixed.vertical,
            volume_pages[true],
            volume_pages[false]

}

volume_wibox:setup{layout = wibox.layout.fixed.vertical, tab_layout, bord}
local cards = {}
local clients = {}
local default_card = {}

    muted = '#ff0000'

local function get_volume(vol) return math.floor(65536 * vol / 100) end
local function update_color()

    unsel = tcolor.get_color(1, 'w')
    colors[1] = tcolor.get_color(2, 'w')
    colors[2] = tcolor.get_color(3, 'w')
    colors[3] = tcolor.get_color(4, 'w')
    -- widgets
    volume_wibox.bg = unsel
    sel = tcolor.get_color(5, 'w')

    tabs[true].bg = colors[1]
    tabs[false].bg = colors[2]
    tabs[chosen_tab]:get_children_by_id('bg')[1].bg = sel
    tabs[not chosen_tab]:get_children_by_id('bg')[1].bg = unsel

    for _, vol in pairs(volume_pages) do
        local cild = vol:get_children()

        for i, a in pairs(cild) do

                a:get_children_by_id('card_bg')[1].bg = colors[1]
                a:get_children_by_id('name_bg')[1].bg = colors[2]
                a:get_children_by_id('volume_bg')[1].bg = colors[3]
                a.bg = unsel
a:get_children_by_id('type_bg')[1].bg = colors[1]
                if i < 3 then

if default_card[i] then

                local col = sel
	if default_card[i].muted then
col = "#ff0000"
end
	a:get_children_by_id('volume')[1].color = col
		end
		end

                a:get_children()[1]:get_children()[1].bg = colors[1]
if i ==pos then a.bg = sel else
		a.bg = unsel
	end

end

    end
end
awesome.connect_signal('color_change', function() update_color() end)




local function get_vol_text(mute, volume)

    return ((mute == true and '') or (volume > 50 and '') or
               (volume > 20 == true and '') or ''),
           (mute and "#ff0000" or sel)

end

local public = {}
local function get_typename(t)
    return (t=='sink' and 'Sink' ) or (t =='source' and 'Source') or t=='sink-input' and 'Input' or 'Output'
end

local function wid_update(w, tab, nam)
    local h, c = get_vol_text(tab.muted, tab.volume)
    w:get_children_by_id('volume_text')[1].markup = h

    w:get_children_by_id('volume')[1].color = c
    w:get_children_by_id('volume')[1].value = tab.volume
    w:get_children_by_id('type')[1].text =  get_typename(tab.type) ..' '..tab.id
    w:get_children_by_id('card')[1].text = nam

    w:get_children_by_id('name')[1].text = tab.name
end
local function get_card(t, id)
    for _, a in pairs(default_card) do
        if (t == 'sink-input' and a.type == 'sink' and tonumber(a.id) ==
            tonumber(id)) or
            (t == 'source-ouput' and a.type == 'source' and tonumber(a.id) ==
                tonumber(id)) then return a end
    end
    for _, a in pairs(cards) do
        if (t == 'sink-input' and a.type == 'sink' and tonumber(a.id) ==
            tonumber(id)) or
            (t == 'source-ouput' and a.type == 'source' and tonumber(a.id) ==
                tonumber(id)) then return a end
    end

    return {name == nil}

end

local function update(tru, t)
    local cc = tru and cards or clients
    local childs = volume_pages[tru]:get_children()

    local ce = #cc

    if  tru then ce =  ce +2  end
    if pos >= ce then
        pos = ce
        end
 local shift =ce < maxitems and 0 or (ce-pos < math.ceil(maxitems/2) and ce - maxitems)  or (pos > math.ceil(maxitems/2) and pos -math.ceil(maxitems/2)) or 0
 if  tru then shift =  shift -2  end
 local seel = ce < maxitems and pos or ( ce-pos < math.ceil(maxitems/2) and maxitems-(ce-pos)) or pos < math.ceil(maxitems/2) and pos or math.ceil(maxitems/2)

    local function update_one(i, a)
        if i == seel then
                a.bg = sel
        else
            a.bg = unsel
        end

        if tru then
            if i > 2 then
                if i +shift > #cc or i + shift < 1 then
                    naughty.notify{text = tostring(i..'  '..  #cc)}
                   return
                end
                wid_update(a, cc[i + shift], cc[i +shift].card)
            else
                wid_update(a, default_card[i], default_card[i].card)

            end
        else

            if i +shift > #cc or i + shift < 1 then
                naughty.notify{text = tostring(i..'  '..  #cc)}
                return
             end
            wid_update(a, cc[i+shift], get_card(cc[i +shift].type, cc[i +shift].card).name or
                           'Card dont exist')
        end
    end
    if t then
        for _, i in ipairs(t) do update_one(i, childs[i]) end
    else

        for i = 1, #childs do update_one(i, childs[i]) end
    end

end
local function change_tab()
    pos = 1
    chosen_tab = not chosen_tab

    volume_pages[not chosen_tab].visible = false

    tabs[chosen_tab]:get_children_by_id('bg')[1].bg = sel
    tabs[not chosen_tab]:get_children_by_id('bg')[1].bg = unsel

    volume_pages[chosen_tab].visible = true
    update(chosen_tab)

end
local function change_default(id)
    if id < 3 then return end
    id = id - 2
    local i = cards[id].type == 'sink' and 1 or 2

    local c = default_card[i]
    default_card[i] = cards[id]
    default_card[i].card = '#' .. default_card[i].card
    c.card = c.card:sub(2)
    cards[id] = c

    awful.spawn.with_shell(
        'pacmd set-default-' .. default_card[i].type .. ' ' ..
            default_card[i].id)
  update(true)

end

function public.change_volume(object, ind, am)
    local cc = object and cards or clients
    if object then
        if ind < 3 then
            cc = default_card

        else
            ind = ind - 2
        end
    end
    cc[ind].volume = cc[ind].volume + am

    if cc[ind].volume < 0 then
        cc[ind].volume = 0
    elseif cc[ind].volume > 100 then
        cc[ind].volume = 100
    end

    awful.spawn.with_shell('pacmd set-' .. cc[ind].type .. '-volume ' ..
                               cc[ind].id .. ' ' ..
                               tostring(get_volume(cc[ind].volume)))
    update(object)

end
local function function_change(pos)

    if not clients[pos] then return end
    local i = clients[pos].type == 'sink-input' and 1 or 2

    local c = {default_card[i].id}
    local ce = clients[pos].card
    for _, a in pairs(cards) do
        if (i == 1 and a.type == 'sink') or i == 2 and a.type == 'source' then
            table.insert(c, a.id)

        end
    end

    for i, a in ipairs(c) do

        if ce == a then
            local ind = i + 1 <= #c and i + 1 or 1
            ce = c[ind]
            break
        end

    end

    awful.spawn.easy_async_with_shell(
        'pacmd move-' .. clients[pos].type .. ' ' .. clients[pos].id .. ' ' ..
            ce, function(out)

            if out ~= "" then
                naughty.notify {text = tostring(out .. '' .. ce)}
            else
                clients[pos].card = ce
                update(false)
            end

        end)

end
function public.mute(object, ind)
    local cc = object and cards or clients
    if object then
        if ind < 3 then
            cc = default_card

        else
            ind = ind - 2
        end
    end
    cc[ind].muted = not cc[ind].muted

    awful.spawn.with_shell('pacmd set-' .. cc[ind].type .. '-mute ' ..
                               cc[ind].id .. ' ' .. tostring(cc[ind].muted))
    update(object)

end

local function widgets_create(tt)
    local icon,volume_color = get_vol_text(tt.muted, tt.volume)
    local card = tt.card
    if tt.type == 'sink-input' or tt.type == 'source-ontput' then
        card = get_card(tt.type, tt.card).name or 'Card dont exist'
    end
    return wibox.widget {
        {
            {
                {
                    {
                    id = 'type',
                        text = get_typename(tt.type)..' '.. tt.id ,

                        widget = wibox.widget.textbox
                    },
id ='type_bg',
                    bg = colors[1],
                    widget = wibox.container.background
                },
                {
                    {
                        {
                            {
                                id = 'name',
                                text = tt.name,

                                widget = wibox.widget.textbox
                            },
                            left = 15,
                            right = 15,

                            widget = wibox.container.margin
                        },
                        bg = colors[2],
                        id = 'name_bg',
                        forced_width = volume_wibox.width - 80,
                        widget = wibox.container.background

                    },
                    {
                        {
                            {
                                {
                                    id = 'volume_text',
                                    forced_width = 20,
                                    font = beautiful.font_icon,
                                    text = icon,

                                    widget = wibox.widget.textbox
                                },
                                {
                                    {
                                        id = 'volume',
                                        max_value = 100,
                                        color = volume_color,
                                        value = tt.volume,
                                        forced_height = 20,
                                        forced_width = 40,
                                        ticks = true,
                                        ticks_gap = 2,
                                        background_color = '#000000',

                                        widget = wibox.widget.progressbar
                                    },
                                    left = 5,
                                    right = 10,
                                    top = 5,
                                    bottom = 5,
                                    widget = wibox.container.margin
                                },
                                id = 'volume_layout',
                                layout = wibox.layout.fixed.horizontal

                            },
                            left = 10,
                            widget = wibox.container.margin
                        },
                        shape = tshape.startn,
                        forced_width = 80,
                        bg = colors[3],
                        id = 'volume_bg',
                        widget = wibox.container.background
                    },

                    spacing = -10,
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    {
                        id = 'card',
                        align = 'center',
                        text = card,

                        widget = wibox.widget.textbox
                    },
                    id = 'card_bg',
                    bg = colors[1],
                    widget = wibox.container.background
                },

                layout = wibox.layout.flex.vertical
            },

            margins = 5,
            widget = wibox.container.margin
        },
        bg = unsel,
        forced_height = 70,
        widget = wibox.container.background
    }

end
local function create_items(command, arr, typ, calback)

    awful.spawn.easy_async_with_shell(command, function(out)

        for i, a in pairs(gears.string.split(out, "\n")) do

            local ar = gears.string.split(a, "|")

            if ar[2] then

                if ar[4] == 'no' then
                    ar[4] = false
                else
                    ar[4] = true
                end

                ar[3] = tonumber(ar[3])

                arr[#arr + 1] = {
                    id = ar[1],
                    name = ar[5],
                    volume = ar[3],
                    muted = ar[4],
                    card = ar[2],
                    type = typ

                }

                if ar[6] then
                    if ar[6] == '*' then
                        arr[#arr].card = '#' .. arr[#arr].card

                    end

                end

            end

        end
        calback()
    end)

end
local function get_clients()
    volume_pages[false]:set_children({})
    clients = {}
    create_items(list_sinks_inputs, clients, 'sink-input', function()
        create_items(list_source_outputs, clients, 'source-output', function()

            for i, a in pairs(clients) do
                local a = widgets_create(a)
                if i >maxitems then
                    break
                end
                volume_pages[false]:add(a)
                update(chosen_tab)
            end

        end)
    end)

end
local function get_cards()

    volume_pages[true]:set_children({})

    create_items(list_sinks, cards, 'sink', function()
        create_items(list_sources, cards, 'source', function()

            for i, a in ipairs(cards) do
                if string.find(a.card, '#') then
                    table.remove(cards, i)
                    if a.type == 'sink' then
                        default_card[1] = a
                    else
                        default_card[2] = a
                    end
                end
            end

            for i = 1, 2 do
                local a = widgets_create(default_card[i])
                awesome.emit_signal('default-' .. default_card[i].type ..
                                        '-change', a)
                volume_pages[true]:add(a)
            end

            for i, ab in pairs(cards) do
                local a = widgets_create(ab)
                if i >maxitems-2 then
                    break
                end

                volume_pages[true]:add(a)
            end

            update_color()
        end)

    end)

end
local function kill(pos)

    awful.spawn.easy_async_with_shell(
        'pacmd kill-' .. clients[pos].type .. ' ' .. clients[pos].id,
        function(c) if c == '' then get_clients() end end)
end
get_cards()

local gbber
function public.stop()
    volume_wibox.visible = false
    awful.keygrabber.stop(gbber)

end

function public.start()
    volume_wibox.x = mouse.screen.geometry.x + mouse.screen.geometry.width - volume_wibox.width
    volume_wibox.y = mouse.screen.geometry.y+ mouse.screen.geometry.height - volume_wibox.height - 20

    get_clients()


    gbber = awful.keygrabber.run(function(mod, key, event)
        if event == "release" then return end

        if key == 'Up' then
            pos = pos - 1 > 0 and pos - 1 or 1
            update(chosen_tab)
        elseif key == 'Down' then
            pos = pos + 1
            update(chosen_tab)
        elseif key == 'r' then
            awful.keygrabber.stop(gbber)
            public.start()
        elseif key == 'K' then
            if chosen_tab == false then kill(pos) end
        elseif key == ' ' or key == 'XF86AudioMute' then
            public.mute(chosen_tab, pos)

        elseif key == 'Left' or key == 'XF86AudioLowerVolume' then

            public.change_volume(chosen_tab, pos, -5)

        elseif key == 'Right' or key =='XF86AudioRaiseVolume' then
            public.change_volume(chosen_tab, pos, 5)
        elseif key == 'Tab' then
            change_tab()
        elseif key == 'c' then

            if chosen_tab == false then
                function_change(pos)
            else
                change_default(pos)
            end

        elseif key == 'x' or key == 'Escape' or key =='X' then

            public.stop()

        end

    end)

    volume_wibox.visible = true
end
function public.toggle()
    if volume_wibox.visible == false then
        public.start()
    else

        public.stop()
    end
end

return public
