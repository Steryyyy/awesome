local a = require("wibox")
local c = require("gears")

local beautiful = require("beautiful")
local d = {precentage = a.widget.textbox('')}
local cpu_pr = a.widget.textbox('')

local mem_pr = a.widget.textbox('')

local prev_idle = 0
local prev_total = 0

local function get_file(fil,num)
	num = num or 1
	local f = assert(io.open(fil,'r'))
	local tab = {}
	if f then
		for i = 1, num do
			tab[i] = f:read()
		end
		f:close()
	end
	return tab
end

local function update()

	local cpu = get_file('/proc/stat',1)
	local arr = {}
	local total = 0
if cpu[1] then
	for toke in string.gmatch(cpu[1],"[^ ]+") do
		if type(tonumber(toke)) == 'number' then
			table.insert(arr,toke)

			total = total + tonumber(toke)
		end
	end
	local idle = arr[4]
	local total_dif = total - prev_total
	local idle_dif = idle - prev_idle
	cpu_pr.text = math.floor (((total_dif-idle_dif)*1000/(total_dif+5))/10+0.5)..'%'
	prev_total = total
	prev_idle = idle
end
	local mem = get_file('/proc/meminfo',7)
	if mem[1] then
	local mem_tot = string.match(mem[1],'%d+')

	local mem_use =mem_tot -string.match(mem[2],'%d+') - string.match(mem[4],'%d+') - string.match(mem[5],'%d+')
	mem_pr.text = math.floor((mem_use*100/mem_tot)+0.5) ..'%'
end
end
 c.timer {
	call_now = true,
	autostart = true,
	timeout = 10,
	callback = function() pcall(update) end
}

cpu_pr.forced_width = 60
mem_pr.forced_width = cpu_pr.forced_width
d.cpu = a.widget {a.widget{text =' ',font =beautiful.font_icon , widget = a.widget.textbox} , cpu_pr, layout = a.layout.fixed.horizontal}
d.mem =a.widget {a.widget{text =' ',font =beautiful.font_icon , widget = a.widget.textbox} , mem_pr, layout = a.layout.fixed.horizontal}

return d
