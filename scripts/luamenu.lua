#!/bin/lua
local term = [[awesome-client  "dropdown_terminal_open('%s')"]]
local c =  io.popen([[(echo /usr/share/pixmaps/* && (echo /usr/share/icons/hicolor/*/*/* /usr/share/app-info/icons/*/*/* |tr " " "\n"| grep "48\|36\|32\|26"))| tr " " "\n" | grep png |awk -F '/' '!seen[$NF]++' ]])
local ico = c:lines()
local icons ={}
for a in ico do
	table.insert(icons,a)
end
c:close()
function readfile(fil)
local f = assert(io.open(fil,'rb'))

local content = f:read('*all')
return content
end

local apps = {}

local file= io.popen('find /usr/share/applications/ -name "*.desktop"'):lines()
for d in  file do

local f = readfile(d)

local name,exec,icon=nil
for token in string.gmatch(f,"[^\n]+") do
	if string.find(token,'Name=') and  token:sub(1,1) =='N' and name ==nil then
 name = string.gsub(token,'Name=','')
	elseif string.find(token,'Exec=') and token:sub(1,1) =='E'  and exec ==nil  then
token =string.gsub(token,'Exec=','')

		local ind = string.find(token,'%%')
if not ind  then ind = #token+1 end
		exec =    token:sub(1,ind-1)
elseif string.find(token,'Terminal=true') and token:sub(1,1) =='T'   then
exec = nil
break
elseif string.find(token,'Icon=') and token:sub(1,1) =='I' and icon==nil  then
local ic = string.gsub(token,'Icon=','')

for i,a in pairs(icons) do
	if string.find(a,ic,1,true) then
icon = a
table.remove(icons,i)
break
end
end
end



end
if name ~= nil and exec ~= nil  then
local no = true
	for _,a in pairs(apps) do
if a[1] == name then
no = false
break
end
end
if no then
	table.insert(apps,{name:lower(),exec,icon})

end
end

end

table.sort(apps,function(a,b) return a[1] < b[1] end   )
if #apps > 0 then
print('return {' )
for _,t in pairs(apps) do
print ('{"'..t[1]..'",[['..t[2]..']]'.. (t[3] and ',"'.. t[3] ..'"' or '') .."},")
end
print('}')
end


