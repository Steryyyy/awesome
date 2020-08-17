local a = require("my.wibox")
local b = require("my.awful")
local c = require("my.gears")

local beautiful = require("my.beautiful")
local d = {precentage = a.widget.textbox('')}
local cpu_pr = a.widget.textbox('')

local mem_pr = a.widget.textbox('')

local prev_idle = 0
local prev_total = 0
function get_file(fil,num)
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

function d.update()

local cpu = get_file('/proc/stat',1)[1]
local arr = {}
local total = 0

for toke in string.gmatch(cpu,"[^ ]+") do
if type(tonumber(toke)) == 'number' then
	table.insert(arr,toke)

	total = total + tonumber(toke)
end
end
local idle = arr[4]
local total_dif = total - prev_total
local idle_dif = idle - prev_idle
cpu_pr.text =math.floor (((total_dif-idle_dif)*1000/(total_dif+5))/10+0.5)..'%'
prev_total = total
prev_idle = idle

local mem = get_file('/proc/meminfo',7)
local mem_tot = string.match(mem[1],'%d+')

local mem_use = string.match(mem[7],'%d+')
mem_pr.text = math.floor(mem_use*100/mem_tot+0.5) ..'%'
end
d.timer = c.timer {
	call_now = true,
	autostart = true,
    timeout = 6,
    callback = function() pcall(d.update) end
}

cpu_pr.forced_width = 50
mem_pr.forced_width = cpu_pr.forced_width
d.cpu = a.widget {a.widget{text =' ',font =beautiful.font_icon , widget = a.widget.textbox} , cpu_pr, layout = a.layout.fixed.horizontal}
d.mem =a.widget {a.widget{text =' ',font =beautiful.font_icon , widget = a.widget.textbox} , mem_pr, layout = a.layout.fixed.horizontal}

return d
