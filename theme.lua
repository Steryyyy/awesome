


local themes_path = os.getenv('HOME') .. '/.config/awesome/images/icons'

local theme = {}

theme.font = "sans 8"

theme.bg_normal = "#222222"



theme.fg_normal = "#ffffff"

theme.icon_theme = 'tuxcursor'

theme.border_color_normal = "#000000"
theme.border_color_active = "#535d6c"
theme.border_marked = "#91231c"
theme.border_color_normal ='#000000'
theme.layout_fairh = themes_path .. "/layouts/fairh.png"
theme.layout_fairv = themes_path .. "/layouts/fairv.png"
theme.layout_floating = themes_path .. "/layouts/floating.png"
theme.layout_magnifier = themes_path .. "/layouts/magnifier.png"
theme.layout_max = themes_path .. "/layouts/max.png"
theme.layout_fullscreen = themes_path .. "/layouts/fullscreen.png"
theme.layout_tilebottom = themes_path .. "/layouts/tilebottom.png"
theme.layout_tileleft = themes_path .. "/layouts/tileleft.png"
theme.layout_tile = themes_path .. "/layouts/tile.png"
theme.layout_tiletop = themes_path .. "/layouts/tiletop.png"

theme.useless_gap = 5

theme.icon_theme = nil

return theme

