local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local tshape = require('tools.shapes')
local tcolor = require('tools.colors')
local naughty = require("my.naughty")
local beautiful = require("beautiful")
local settings = require('settings').volume_con
local keys  = require('keybindings').volume_keys
local pos = 1
local maxitems = settings.items > 5  and settings.items or 5
local hotkeys_popup = require("my.hotkeys_popup")

local client_base = " | awk -f ~/.config/awesome/scripts/get_clients.awk"
local base = " | awk -f ~/.config/awesome/scripts/get_cards.awk"
local pacmd = "LANG=C pacmd "
local list_sinks = pacmd .."list-sinks" .. base
local list_sources = pacmd.. "list-sources" .. base
local list_sinks_inputs = pacmd.. "list-sink-inputs" .. client_base
local list_source_outputs = pacmd.. "list-source-outputs" .. client_base
local colors = {
	'#c6c3c2','#f6e5d9','#f8f4f2','#f8f4f2','#f6bd52','#ff0000',"#000000"
}

local SHIFT = 0

local COLOR = {SELECTED = 5 ,BACKGROUND = 4,MUTED= 6,UNSELECTED = 7}
local TYPES = { SINK = 1, SOURCE = 2,INPUT = 3,OUTPUT = 4}
local TYPES_NAMES= {'sink','source','sink-input','source-output'}

local tabs = {}
local volume_pages = {}
local cards = {}
local clients = {}
local default_card = {}
local volume_wibox = wibox {width = settings.width or   560, height =  settings.height  or 380}
volume_wibox.fg = '#000000'
volume_wibox.ontop = true
volume_wibox.visible = false

local chosen_tab = true
local tab_layout = wibox.layout.flex.horizontal()
tab_layout.spacing = -15
tab_layout.forced_height = 30

local function get_typename(t)
	return (t==TYPES.SINK and 'Sink' ) or (t ==TYPES.SOURCE and 'Source') or t==TYPES.INPUT and 'Input' or 'Output'
end


local function get_vol_text(mute, volume)

	return ((mute == true and '') or (volume > 50 and '') or
	(volume > 20 == true and '') or ''),
	(mute and colors[COLOR.MUTED] or colors[COLOR.SELECTED])

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
		if tonumber(a.id) == tonumber(id) and (t-2 == a.type )  then
			return a
		end

	end
	for _, a in pairs(cards) do
		if tonumber(a.id) == tonumber(id) and (t-2 == a.type )  then
			return a
		end
	end

	return {name == nil}

end



local function update(tru, t)
	local cc = tru and cards or clients
	if #cc ==0 then
		pos = 1
	return
	end
	local childs = volume_pages[tru]:get_children()

	local ce = #cc

	if  tru then ce =  ce +2  end
	if pos >= ce then
		pos = ce
	end
	local shift =ce < maxitems and 0 or (ce-pos < math.ceil(maxitems/2) and ce - maxitems)  or (pos > math.ceil(maxitems/2) and pos -math.ceil(maxitems/2)) or 0
	if  tru then shift =  shift -2  end
	local seel = ce < maxitems and pos or ( ce-pos < math.ceil(maxitems/2) and maxitems-(ce-pos)) or pos < math.ceil(maxitems/2) and pos or math.ceil(maxitems/2)
	SHIFT = shift
	local function update_one(i, a)
		if i == seel then
			a.bg = colors[COLOR.SELECTED]
		else
			a.bg = colors[COLOR.UNSELECTED]
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

	tabs[chosen_tab]:get_children_by_id('bg')[1].bg = colors[COLOR.SELECTED]
	tabs[not chosen_tab]:get_children_by_id('bg')[1].bg = colors[COLOR.BACKGROUND]

	volume_pages[chosen_tab].visible = true
	update(chosen_tab)

end

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
	cce:connect_signal("button::press", function(_,_,_,b)
		if b == 1 then
			change_tab()
		end
	end)


	return cce
end
local function create_page()

	local ge = wibox.layout.fixed.vertical()
	return ge
end

tabs[true] = create_tab('Cards', tshape.leftstart)
tabs[false] = create_tab('Clients', tshape.taskendleft)

tab_layout:add(tabs[true])
tab_layout:add(tabs[false])

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


local function get_volume(vol) return math.floor(65536 * vol / 100) end
local function update_color()

	colors[1] = tcolor.get_color(2, 'w')
	colors[2] = tcolor.get_color(3, 'w')
	colors[3] = tcolor.get_color(4, 'w')
	colors[COLOR.BACKGROUND] = tcolor.get_color(1,'w')
	colors[COLOR.SELECTED] = tcolor.get_color(5,'w')
	-- widgets
	volume_wibox.bg = colors[COLOR.BACKGROUND]

	tabs[true].bg = colors[1]
	tabs[false].bg = colors[2]
	tabs[chosen_tab]:get_children_by_id('bg')[1].bg = colors[COLOR.SELECTED]
	tabs[not chosen_tab]:get_children_by_id('bg')[1].bg = colors[COLOR.BACKGROUND]

	for f, vol in pairs(volume_pages) do
		local cild = vol:get_children()

		for i, a in pairs(cild) do

			a:get_children_by_id('card_bg')[1].bg = colors[1]
			a:get_children_by_id('name_bg')[1].bg = colors[2]
			a:get_children_by_id('volume_bg')[1].bg = colors[3]
			a:get_children_by_id('type_bg')[1].bg = colors[1]
			a:get_children_by_id('volume')[1].color =  ((f and i >3 and cards[i-2].muted ) or (f and i <3 and default_card[i].muted)or (not f and clients[i].muted)) and colors[COLOR.MUTED] or colors[COLOR.SELECTED]
			a:get_children()[1]:get_children()[1].bg = colors[1]
			if i ==pos then a.bg = colors[COLOR.SELECTED] else

			a.bg = colors[COLOR.UNSELECTED]
			end

		end

	end
end
awesome.connect_signal('color_change', function() update_color() end)




local public = {}
local function change_default(id)
	if id < 3 then return end
	id = id - 2
	if not cards[id] or not cards[id].type then
		return
	end
	local i = cards[id].type

	local c = default_card[i]
	default_card[i] = cards[id]
	default_card[i].card = '#' .. default_card[i].card
	c.card = c.card:sub(2)
	cards[id] = c

	awful.spawn.with_shell(
	'pacmd set-default-' .. TYPES_NAMES[ i] .. ' ' ..
	default_card[i].id)
	update(true)

end

function public.change_volume(object, ind, am)
	-- if ind ==0 then return end
	local cc = object and cards or clients


	if object then
		if ind < 3 then
			cc = default_card

		else
			ind = ind - 2
		end
	end
	if not cc[ind] then
	return
	end
	cc[ind].volume = (cc[ind].volume + am > 100 and 100) or( cc[ind].volume +am < 0 and 0 )or cc[ind].volume +am


	awful.spawn.with_shell('pacmd set-' .. TYPES_NAMES [cc[ind].type] .. '-volume ' ..
	cc[ind].id .. ' ' ..
	tostring(get_volume(cc[ind].volume)))
	update(object)

end
local function function_change(pos)

	if not clients[pos] or not clients[pos].type then return end

	local c = {default_card[clients[pos].type-2].id}
	local ce = tonumber(clients[pos].card)
	for _, a in pairs(cards) do
		if ( clients[pos].type-2 == a.type )  then
			table.insert(c, a.id)

		end
	end
	for i=1,#c do

		if ce == c[i] then
			ce = c[ i+1 > #c and 1 or i+1]
			break
		end

	end
	awful.spawn.easy_async_with_shell(
	'pacmd move-' ..  TYPES_NAMES[clients[pos].type] .. ' ' .. clients[pos].id .. ' ' ..
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
	if not ind then  return end
	if object then
		if ind < 3 then
			cc = default_card

		else
			ind = ind - 2
		end
	end

	if not cc[ind] then
	return
	end

	cc[ind].muted = not cc[ind].muted

	awful.spawn.with_shell('pacmd set-' .. TYPES_NAMES[cc[ind].type] .. '-mute ' ..
	cc[ind].id .. ' ' .. tostring(cc[ind].muted))
	update(object)

end

local function widgets_create(tt,te,ind)
	if not tt then return end
	local icon,volume_color = get_vol_text(tt.muted, tt.volume)
	local card = tt.card
	if tt.type  > 2 then
		card = get_card(tt.type, tt.card).name or 'Card dont exist'
	end
	local widg = wibox.widget {
		{
			{
				{
					{       {
						id = 'type',
						text = get_typename(tt.type)..' '.. tt.id ,

						widget = wibox.widget.textbox
					},
					left = 20,
					widget = wibox.container.margin,
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
						left = 20,
						right = 15,

						widget = wibox.container.margin
					},
					bg = colors[2],
					id = 'name_bg',
					forced_width = volume_wibox.width - 75,
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
									forced_height = 10,
									forced_width = 45,
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

		left = 5,
		widget = wibox.container.margin
	},
	bg = colors[COLOR.UNSELECTED],
	forced_height = 60,
	widget = wibox.container.background
}

widg:get_children_by_id('volume_layout')[1]:connect_signal("button::press",function(_,_,_,b)

	local ind = te and ind < 3 and ind or te and ind +SHIFT +2 or ind
	if b == 1 then
		public.mute(te, ind)
	elseif b ==4 then
		public.change_volume(te,ind,5)
	elseif b ==5 then
		public.change_volume(te,ind,-5)
	end


end)
widg:get_children_by_id('card')[1]:connect_signal("button::press",function(_,_,_,b)
	if te  and ind <3 then
		return
	end
	local ind =  te and ind +SHIFT +2 or ind
	if b == 1 then
		if te then
			change_default(ind)
		else
			function_change(ind)
		end

	end
end)


return widg
end
local function create_items(command, arr, typ, calback)

	awful.spawn.easy_async_with_shell(command, function(out)
		for _, a in pairs(gears.string.split(out, "\n")) do

			local ar = gears.string.split(a, "|")

			if ar[2] then
				ar[4] = ar[4] ~= 'no'
				local object = {

					id = tonumber(ar[1]),
					name = ar[5],
					volume =  tonumber(ar[3]),
					muted = ar[4],
					card = ar[2],
					type = typ
				}

				if typ <3 and  ar[6] and ar[6] =='*' then
					object.card = '#' .. object.card
					default_card[typ] = object
				else
					arr[#arr + 1] = object
				end


			end

		end
		calback()
	end)

end
local function get_clients()
	volume_pages[false]:set_children({})
	clients = {}
	create_items(list_sinks_inputs, clients, TYPES.INPUT, function()
		create_items(list_source_outputs, clients, TYPES.OUTPUT, function()

			for i, b in pairs(clients) do
				local a = widgets_create(b,false,i)
				if i >maxitems then
					break
				end
				volume_pages[false]:add(a)
				pos =1
				update(chosen_tab)
			end

		end)
	end)

end
local function get_cards()

	volume_pages[true]:set_children({})
	cards = {}
	create_items(list_sinks, cards, TYPES.SINK, function()

		create_items(list_sources, cards, TYPES.SOURCE, function()


			for i,b in pairs(default_card) do
				local a = widgets_create(b,true ,i)
				awesome.emit_signal('default-' .. TYPES_NAMES[b.type] ..
				'-change', a)
				volume_pages[true]:add(a)
			end

			for i, ab in pairs(cards) do
				local a = widgets_create(ab,true ,i+2)
				if i >maxitems-2 then
					break
				end

				volume_pages[true]:add(a)
			end
			get_clients()
			update_color()
		end)

	end)

end
local function kill(pos)

	if not clients[pos] then
	return
	end
	awful.spawn.easy_async_with_shell(
	'pacmd kill-' .. TYPES_NAMES[ clients[pos].type] .. ' ' .. clients[pos].id,
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

	get_cards()

	gbber = awful.keygrabber.run(function(mod, key, event)
		if event == "release" then return end

		local ind = 0
		key = (key == " " and "space") or key
		ind = require('functions').compare_key(keys,key,mod)
		if ind ~= 0 then
		local opperation = keys[ind][4]
		if opperation =="prev_entry" then
			pos = pos - 1 > 0 and pos - 1 or 1
			update(chosen_tab)
		elseif opperation =="next_entry" then
			pos = pos + 1
			update(chosen_tab)
		elseif opperation =="restart" then
			awful.keygrabber.stop(gbber)
			public.start()
		elseif opperation =="kill" then
			if chosen_tab == false then kill(pos) end
		elseif opperation == "dec" then
			public.change_volume(chosen_tab, pos, -5)
		elseif opperation =="inc" then
			public.change_volume(chosen_tab, pos, 5)
		elseif opperation=="mute" then
			public.mute(chosen_tab, pos)
		elseif opperation =="tab" then
			change_tab()
		elseif opperation =="change" then
			if chosen_tab == false then
				function_change(pos)
			else
				change_default(pos)
			end
		elseif opperation =="quit" then

			public.stop()
		elseif opperation =='keys' then
		hotkeys_popup.show_help("volume")
		end


		end
                --[[
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

                --]]
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
