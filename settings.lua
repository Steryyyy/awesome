local settings =require('default_settings')
local function change(array,categories ,value_name,value )
	local cat = categories[1] or ''
	table.remove(categories,1)
	for i,a in pairs(array) do
		if i == cat then
			change(a,categories,value_name,value)
			return
		else if value_name ==i then
			array[i] = value
			break
		end
	end
end
if #categories ==0 then
	array[value_name] = value
end

end
--example of changing settings
change(settings,{"widgets"},"battery", "/sys/class/power_supply/BAT1")

return settings
