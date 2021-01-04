local beautiful = require("beautiful")
local chosencol = 1
local public = {}
local default_colors  ={
w={'#f8f4f2','#c6c3c2','#f6e5d9','#f8f4f2','#f6bd52'},
tg={'#ab613b','#dd7d4c','#aa7862','#df7443'},
tgs={'#f8f4f2','#c6c3c2',"#4229dc"},}

local color_array ={}

local function init_cols()
local ar = require('tools.colors.create')

if ar then
color_array = ar
end
end
pcall(init_cols)
local chosen_array = 1

function public.get_color(i, name)
	local def_arr = default_colors[name]
	if  color_array[chosen_array] and color_array[chosen_array][chosencol] and color_array[chosen_array][chosencol][name]  then
		def_arr = color_array[chosen_array][chosencol][name]

	end

if i ==6 and name =='w' then return '#ff0000' end
    local ie = i % #def_arr

    if ie == 0 then ie = #def_arr end
    return def_arr[ie]

end

function public.change_colors(new, fol, rand)
	if fol > 0 and fol <= #color_array then

		chosen_array = fol

		if new <= #color_array[chosen_array] and new > 0 then
			chosencol = new
		end
	else
		chosencol = 1
	end

	beautiful.border_color_active = public.get_color(1,'tgs')
	beautiful.snap_bg = public.get_color(1,'tgs')
	awesome.emit_signal('color_change', fol, new)

end
return public
