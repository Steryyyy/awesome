return {
	terminal_dropdown = 'urxvtc -name dropdown-terminal',

	terminal_dropdown_get = {
		instance ='dropdown-terminal',
	},
	terminal = 'urxvt',
	widgets = {
		internet = {
			interface = "enp9s0",


		},
		player = {
			max_song_title = 80,
			player_font_size = 11,
		},
		--comment battery if you dont have one
		--battery = "/sys/class/power_supply/BAT1",
		battery = nil,
	},
	rc = {
		country_name = 'USA',
		country_code = 'usa',
		font =  'Source Han Sans JP',
		font_icon = 'Font Awesome 5 Free Solid  ',
		font_size = 14,
		font_icon_size = 11,
	},
	wallpaper = {

		items = 10 ,
		wallpaper_width = 1920,
		wallpaper_height = 1080,
		default_timeout = 60*10,
		wallpaper_command = "xwallpaper --zoom "
	},
	exit_screen = {
		insults = true,
		cam = "/dev/video0",
		op_margin =75, --75
		op_height = 100,
		op_font_size = 30,
		username_width = 400,
		clock_width = 350,
		username_font = nil,
		username_font_size = 30,
		username_font_size_min = 10,
		clock_font = nil,
		goodbye_margin = 100,
		icon_height = 100,
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
		auto_menu = false,

	},
	client = {
	titlebars = false,
	titlebars_shape = nil,
	shape = nil,
	},
}
