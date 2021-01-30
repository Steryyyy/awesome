return {
	terminal_dropdown = 'urxvtc -name dropdown-terminal',

	terminal_dropdown_get = {
		instance ='dropdown-terminal',
	},
	terminal = 'urxvt',
	widgets = {
		player = {
			max_song_title = 80,
			player_font = "Source Han Sans JP Bold 12",
		},
	},
	connect = {
	browser = "firefox",
	},
	rc = {
		country_name = 'USA',
		country_code = 'usa',
		font =  'Source Han Sans JP Bold 14',
		font_icon = 'Font Awesome 5 Free Solid 10 ',
		font_coron = "Source Han Sans JP Bold 10",
	},
	wallpaper = {

		items = 10 ,
		wallpaper_width = 1920,
		wallpaper_height = 1080,
		default_timeout = 60*10,
		wallpaper_command = "xwallpaper --zoom "
	},
	exit_screen = {
		insults = false,
		cam = "/dev/video0",
		op_margin =75, --75
		op_height = 100,
		op_font = "Font Awesome 5 Free Solid 30",
		username_width = 400,
		clock_width = 350,
		username_font = "Source Han Sans JP  ",
		username_font_size = 30,
		username_font_size_min = 10,
		clock_font = "Source Han Sans JP  50",
		goodbye_margin = 100,
		icon_height = 100,
	},

	volume_con = {
		-- 1 item = 70
		items = 8,
		width = 600,
		height = 480+30+90,
		font_icon = 'Font Awesome 5 Free Solid 10',
		font_type =  'Source Han Sans JP Bold 13',
		font_name =  'Source Han Sans JP Bold 12',
		font_card =  'Source Han Sans JP Bold 10',
	},
	noti = {
		width = 400,
		height = 300,
		max_width = 800,
		max_height = 400,

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
