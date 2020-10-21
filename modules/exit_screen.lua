local awful = require("my.awful")
local gears = require("my.gears")
local wibox = require("my.wibox")
local tshape = require('tools.shapes')

local beautiful = require("my.beautiful")
local tcolor = require('tools.colors')
local settings = require('settings').exit_screen

local password = 'awesomeWm'
local op_margin = settings.op_margin or 150
local op_height = settings.op_height or 100
local op_font_size =settings.op_font_size or 40
local username_width = settings.username_width or 650
local username_font = settings.username_font or beautiful.font_name ..' '
local username_font_size =  settings.username_font_size or 30
local username_font_size_min = settings.username_font_size_min or 15
local goodbye_margin = settings.goodbye_margin or 75
local clock_font = settings.clock_font or beautiful.font_name ..' ' .. 50
local poweroff_text_icon = ""
local reboot_text_icon = ""
local restart_awesome_icon = ""
local exit_text_icon = ""
local lock_text_icon = ""
local function check_password(pass)
	local pam = nil -- require("liblua_pam")
	if pam then
		local auth = pam.auth_current_user(pass)
		if auth then
			return true
		end
		return false
	end
	if pass == password then
		return true
	end

	return false
end

local min_width = screen[1].geometry.width
for i=2,#screen do
if screen[i].geometry.width < min_width then
min_width = screen[i].geometry.width
end
end


local icon_font = beautiful.font_icon_name ..' '.. op_font_size

local function bgg(w, shape)
	if shape == nil then shape = gears.shape.powerline end
	return wibox.widget {
		{
			{
				text = tostring(w),
				font = icon_font,
				widget = wibox.widget.textbox,
				forced_height = op_height
			},

			left = op_margin,
			right = op_margin,
			widget = wibox.container.margin
		},

		shape = shape,
		widget = wibox.container.background
	}
end



local prompt = wibox.widget.textbox('dwadwa')
local username = os.getenv("USER") or 'Anon'
local username_widget = wibox.widget.textbox(username)
username_widget.font =username_font.. username_font_size
username_widget.forced_width = username_width

prompt.font = username_font.. username_font_size
local usericon = os.getenv('HOME')..'/.config/awesome/images/profile.jpg'
local usericon_widget =wibox.widget.imagebox  (usericon)
usericon_widget.forced_height  = math.ceil(min_width/30)
local function ss(w, s)
	if s == nil then s = tshape.leftpowerline end
	return wibox.widget {
		{
			w,
			left = goodbye_margin,
			top = 20,
			bottom = 20,
			right = goodbye_margin,
			widget = wibox.container.margin
		},

		shape = s,
		widget = wibox.container.background
	}
end

local goodbye_widget = wibox.widget {
	ss(wibox.widget {
		usericon_widget,
		username_widget,
		spacing = 50,
		layout = wibox.layout.fixed.horizontal
	}),
	ss(prompt,gears.shape.rectangular_tag),
	layout = wibox.layout.align.horizontal

}
goodbye_widget.forced_height = 150
goodbye_widget:set_spacing(-90)

local comm = {}

local comme = {'Power off', 'Reboot',  'Reload', 'Exit', 'Lock'}
table.insert(comm, bgg(poweroff_text_icon))

table.insert(comm, bgg(reboot_text_icon))

table.insert(comm, bgg(restart_awesome_icon))
table.insert(comm, bgg(exit_text_icon))

table.insert(comm, bgg(lock_text_icon, tshape.taskendleft))

local index = #comm
local timeout = 3

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
		bg = '#000000CC'
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
local function exit_screen_hide()
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
for _,a in pairs(exit_screens) do

	a:connect_signal("button::press",function(_,_,_,b)
		if b == 1 then

			if index == #comm then
				locked = true
				prompt.text = 'Password:'
			elseif index == 3 then
				awesome.restart()
			else
				clock:start()
			end
		elseif b ==3 then

			exit_screen_hide()
		else

			rotate( b ==4 and 1 or -1)
		end
	end)



end
local sett = wibox.widget {

	spacing = -80,
	layout = wibox.layout.fixed.horizontal
}
local textclock = wibox.widget.textbox('')
textclock.font = clock_font
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
	forced_width = math.ceil(min_width/6),
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
local dictionary = {
	" ugwy bastawd ",
	" mowon ",
	" u awe thief ",
	" diws yyou mwisws speawwewd  ? ",
	" moshi moshi keisatsu desu ka? ",
	" this iz nyot seewch enginye ",
	" wat iz dat ? wat awe u wwiting? ",
	"Sempai i wwewyy sowwyy twhat iws wnot wiwndowws (◕︿◕✿) ",
	"(╯°□°）╯︵ ┻━┻",
	"\\_(ツ)_/¯",
	"OwO Wat iz dis?? Wat awe you wwiting?",
	"Hewwo??",
	"A most nyotabwe cowawd, an infinyite an endwess wiaw, an houwwy pwomise bweekew, te ownyew of nyo onye good kwawity.",
	"away, u stawvewwing, u ewf-skin, u dwied nyeet's-tongue, buww's-pizzwe, u stock-fish (・`ω´・) ",
	"away, u thwee-inch foow (・`ω´・)  ",
	"come, come, u fwowawd an unyabwe wowms \n(・`ω´・) ",
	"go, pwick thy face, an uvw-wed thy feew, thou wiwy-wivew’d boy.",
	"his wit's as thick as a tewkesbuwy mustawd.",
	"i am pigeon-wivew'd an wack gaww.",
	"i am sick when I do wook on thee ",
	"i must teww u fwiendwy in youw eew, seww when u can, u awe nyot fow aww mawkets.",
	"if thou wiwt nyeeds mawwy, mawwy a foow; fow wise men knyow weww enyough wat monstews u make of them.",
	"i'ww beet thee, but I wouwd infect my hands.",
	"i scown u, scuwvy companyion. ",
	"methink'st thou awt a genyewaw offence an evewy man shouwd beet thee.",
	"mowe of youw convewsation wouwd infect my bwain.",
	"my wife's a hobby howse (・`ω´・) ",
	"peece, ye fat guts (・`ω´・) ",
	"poisonyous bunch-backed toad (・`ω´・)  ",
	"the wankest compound of viwwainyous smeww dat evew offended nyostwiw",
	"the tawtnyess of his face souws wipe gwapes.",
	"thewe's nyo mowe faith in thee than in a stewed pwunye.",
	"thinye fowwawd voice, nyow, iz to speek weww of thinye fwiend; thinye backwawd voice iz to uttew foww speeches an to detwact.",
	"thinye face iz nyot wowth sunbuwnying.",
	"this woman's an eesy gwuv, my wowd, she goes off an on at pweesuwe.",
	"thou awt a boiw, a pwague sowe.",
	"was te duke a fwesh-mongew, a foow an a cowawd?",
	"thou awt as fat as buttew.",
	"hewe iz te babe, as woathsome as a toad.",
	"wike te toad; ugwy an venyomous.",
	"thou awt unfit fow any pwace but heww.",
	"thou cweem faced woon",
	"thou cway-bwainyed guts, thou knyotty-pated foow, thou whoweson obscenye gweesy tawwow-catch (・`ω´・) ",
	"thou damnyed an wuxuwious mountain goat.",
	"thou ewvish-mawk'd, abowtive, wooting hog (・`ω´・) ",
	"thou weethewn-jewkin, cwystaw-button, knyot-pated, agatewing, puke-stocking, caddis-gawtew, smooth-tongue, spanyish pouch (・`ω´・) ",
	"thou wump of foww defowmity",
	"that poisonyous bunch-back'd toad (・`ω´・) ",
	"thou sodden-witted wowd (・`ω´・)  thou hast nyo mowe bwain than I hav in minye ewbows ",
	"thou subtwe, pewjuw'd, fawse, diswoyaw man (・`ω´・) ",
	"thou whoweson zed , thou unnyecessawy wettew (・`ω´・) ",
	"thy sin’s nyot accidentaw, but a twade.",
	"thy tongue outvenyoms aww te wowms of nyiwe.",
	"wouwd thou wewt cween enyough to spit upon",
	"wouwd thou wouwdst buwst (・`ω´・) ",
	"you poow, base, wascawwy, cheeting wack-winyen mate (・`ω´・)  ",
	"you awe as a candwe, te bettew buwnt out.",
	"you scuwwion \n (・`ω´・)  u wampawwian (・`ω´・)  u fustiwawian (・`ω´・)  i’ww tickwe youw catastwophe (・`ω´・) ",
	"you stawvewwing, u eew-skin, u dwied nyeet's-tongue, u buww's-pizzwe, u stock-fish-o fow bweeth to uttew wat iz wike thee (・`ω´・) -you taiwow's-yawd, u sheeth, u bow-case, u viwe standing tuck (・`ω´・) ",
	"youw bwain iz as dwy as te wemaindew biscwit aftew voyage.",
	"viwginyity bweeds mites, much wike a cheese.",
	"viwwain, I hav donye thy mothew",
}
local function take_picture()
	if settings.cam then
		local file = '/tmp/intruder'.. tostring(os.time())..'.jpg'
		awful.spawn.easy_async_with_shell(
		'	ffmpeg -f video4linux2 -s 800x600 -i '..settings.cam .. ' -ss 0:0:01 -frames 1 '.. file,
		function()
			usericon_widget.image = file



		end)
	end
end

return  function ()
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


				if check_password(pass) then

					username_widget.text = username
				username_widget.font = username_font .. username_font_size
					usericon_widget.image = usericon
					locked = false

					prompt.text =  comme[index]

					pass = ''
				else
					prompt.text = comme[index]
					if settings.easter_egg and( string.lower(pass) == "uwu" or string.lower(pass) == "owo") then

						prompt.text = "locked"

				username_widget.font = username_font .. username_font_size
						username_widget.text = username

						usericon_widget.image = usericon
						require('my.naughty').notify{text = tostring("Cowngwatuwatiown yyou weceiwwewd eastew egg （＾ω＾）\\wn\n i wiww teww yyou  (♥ω♥*) passwowwd iws (≧∀≦)  "), urgency ='uwu'}
						gears.timer.start_new(3, function()

							require('my.naughty').notify{text = tostring("Pweaws wait i wiww check passwowwd (´ω｀*)") , urgency ='uwu'}
							gears.timer.start_new(3, function()

				username_widget.font = username_font .. username_font_size_min
								username_widget.text = "I awm wweawyy sowwyy but i cawnt teww yyou passwowwd (ToT) pwease use yyouw mwiwnwd to fiwnwd passwowwd （◞‸◟） "
								require('my.naughty').notify{text = tostring("I awm wwewyy sowwyy i awm to excitewd to teww yyou sempai ≧ω≦ \n I wiww take pictuwe of yyou\n Yowu awe weawwyy hawndsome") , urgency ='uwu'}
								take_picture()

								prompt.text = "Password:"
							end)
						end)

					else

						take_picture()
						if settings.insults then

				username_widget.font = username_font .. username_font_size_min
							username_widget.text = settings.insults and dictionary[math.random(#dictionary)]
						end

						prompt.text = 'Password:'
					end

					pass = ''

				end
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
