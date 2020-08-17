local beautiful = require("my.beautiful")
local chosencol = 1
local public = {}
local color_array  =
{{
	{
	w={'#5128aa','#6833dc','#b551dc','#7047ae','#6094a5'},
	tg={'#dca19f','#f0cbc5','#f7e4f0','#d8c1da'},
	tgs={"#b551dc", "#3f19aa",'#e1a705'},
	tks={'#aa0302'}
	},
}
}
function init_cols()
local ar = require('tools.colors.create')

if ar then
color_array = ar
end
end
pcall(init_cols)
local chosen_array = 1

function public.get_color(i, name)

if i ==6 and name =='w' then return '#ff0000' end
    local ie = i % #color_array[chosen_array][chosencol][name]

    if ie == 0 then ie = #color_array[chosen_array][chosencol][name] end
    return color_array[chosen_array][chosencol][name][ie]

end

function public.change_colors(new, fol, rand)
if fol > 0 and fol <= #color_array then

chosen_array = fol

if new <= #color_array[chosen_array] and new > 0 then
    chosencol = new
    end
end

    beautiful.border_color_active = color_array[chosen_array] [chosencol]['tgs'][1]
    beautiful.snap_bg = color_array[chosen_array] [chosencol]['tgs'][1]
    awesome.emit_signal('color_change', fol, new)

end
return public
