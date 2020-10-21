return {
	terminal = 'urxvtc -name dropdown-terminal',
	terminal_get = {
		instance ='dropdown-terminal',
	},

	widgets = {
		internet = {
			interface = "enp9s0",


		},
		player = {
			max_song_title = 80,
			player_font_size = 11,
		},
		battery = "/sys/class/power_supply/BAT1",
	},
	rc = {
		country_name = 'Poland',
		country_code = 'pl',
		font =  'Source Han Sans JP',
		font_icon = 'Font Awesome 5 Free Solid  ',
		font_size = 14,
		font_icon_size = 11,
	},
	wallpaper = {
		items = 9 ,
		wallpaper_width = 2560,
		default_timeout = 60*10,
		wallpaper_command = "xwallpaper --zoom "
	},
	exit_screen = {
		easter_egg = true,
		insults = true,
		cam = "/dev/video0",
		op_margin =150,
		op_height = 100,
		op_font_size = 40,
		username_width = 650,
		username_font = nil,
		username_font_size = 30,
		username_font_size_min = 15,
		clock_font = nil,
		goodbye_margin = 75,
	},

	volume_con = {
		-- 1 item = 70
		items = 8,
		width = 600,
		height = 380+210,
	},
	noti = {
		width = 400,
		height = 300,
		max_size = 800,
		nim_size = 200,

	},
	start_menu = {
		items = 10,
		width = 300,
		height = 550,
		prompt = "Search:",

	}
}
