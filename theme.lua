local theme = {}
local settings = require('settings').rc
local images =  os.getenv("HOME") .. "/.config/awesome/images"
theme.useless_gap = 5
theme.border_width = 5
-- theme.notification_icon_size = 60
theme.fg_normal = '#ffffff'
theme.font_name = settings.font
theme.font = theme.font_name .. ' Bold '.. settings.font_size
theme.font_icon_name = settings.font_icon
theme.font_icon = settings.font_icon .. settings.font_icon_size
theme.titlebar_close_button_normal = images.."/theme/blank.svg"
theme.titlebar_close_button_focus = images.."/theme/blank.svg"
theme.titlebar_close_button_normal_hover   =  images.."/theme/close_hover.svg"
theme.titlebar_close_button_focus_hover   =   images.."/theme/close_hover.svg"
theme.titlebar_floating_button_normal_inactive = images.."/theme/blank.svg"

theme.titlebar_floating_button_focus_inactive = images.."/theme/blank.svg"

theme.titlebar_floating_button_focus_active = images.."/theme/floating_active.svg"
theme.titlebar_floating_button_normal_active = images.."/theme/floating_active.svg"
theme.titlebar_maximized_button_normal_inactive =images.."/theme/blank.svg"

theme.titlebar_maximized_button_focus_inactive  = images.."/theme/blank.svg"
theme.titlebar_maximized_button_normal_active = images.."/theme/maximized_active.svg"
theme.titlebar_maximized_button_focus_active  = images.."/theme/maximized_active.svg"
return theme
