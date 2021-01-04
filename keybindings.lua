local awful = require("awful")
local beautiful = require("beautiful")
local term = require('settings').terminal
local modkey = 'Mod4'
local altkey = 'Mod1'
local control = 'Control'
local public = {}
public.globals = {
	{{modkey,'Shift'}, "space",{description="Previous layout",group="Tag"}, function() awful.layout.inc(-1) end},
	{{modkey}, "space",{description="Next layout",group="Tag"}, function() awful.layout.inc(1) end},
	{{modkey, "Shift"}, "e",{description="Exit screen module",group="Module"},"exit"},
	{{modkey, control,'Shift'}, "h",{description="Go to hidden tag/workspace",group="Tag"}, function()local tag = mouse.screen.tags[6]if tag then tag:view_only() end end},
	{{modkey}, "h",{description="Decrease client gaps",group="Tag"}, function() awful.tag.incgap(-5) end},
	{{modkey}, "l",{description="Increase client gaps",group="Tag"}, function() awful.tag.incgap(5) end},
	{{modkey}, "u",{description="Go to urgent client",group="Client"}, "to_urgent"},
	{{modkey, "Shift"}, "k",{description="Swap client with previous client",group="Client"},function() awful.client.swap.byidx(-1) end},
	{{modkey, "Shift"}, "j",{description="Swap client with next client",group="Client"},function() awful.client.swap.byidx(1) end},
	{{modkey, control}, "k",{description="Focus previous screen",group="Screen"},function() awful.screen.focus_relative(-1) end},
	{{modkey, control}, "j",{description="Focus next screen",group="Screen"},function() awful.screen.focus_relative(1) end},
	{{modkey, 'Shift'}, "Tab",{description="Focus previous client",group="Client"}, "client_focus_prev"},
	{{modkey}, "Tab",{description="Focus next client",group="Client"}, "client_focus_next"},
	{{modkey}, "k",{description="Move client to previous screen and focus",group="Screen"}, function()local c = client.focus if c then c:move_to_screen(c.screen.index - 1) else awful.screen.focus_relative(-1) end end},
	{{modkey}, "j",{description="Move client to next screen and focus",group="Screen"}, function()local c = client.focus if c then c:move_to_screen() else awful.screen.focus_relative(1)  end end},
	{{modkey}, "q",{description="Toggle dropdown terminal",group="Terminal"}, "dropdown_toggle"},
	{{ 'Shift'}, "XF86AudioLowerVolume",{description="Microphone volume down",group="Volume"}, "menu_mic_down"},
	{{ 'Shift'}, "XF86AudioRaiseVolume",{description="Microphone volume up",group="Volume"}, "menu_mic_up"},
	{{ 'Shift'}, "XF86AudioMute",{description="Togle mute microphone",group="Volume"}, "menu_mic_mute"},
	{{}, "XF86AudioMute",{description="Toggle mute volume",group="Volume"}, "menu_volume_mute"},
	{{}, "XF86AudioLowerVolume",{description="Volume down",group="Volume"}, "menu_volume_down"},
	{{}, "XF86AudioRaiseVolume",{description="Volume up",group="Volume"}, "menu_volume_up"},
	{{altkey}, "XF86AudioMute",{description="Player toogle mute state",group="Player"}, "player_mute"},
	{{altkey}, "XF86AudioLowerVolume",{description="Player decrement volume",group="Player"}, "player_dec"},
	{{altkey}, "XF86AudioRaiseVolume",{description="Player increment volume",group="Player"}, "player_inc"},
	{{}, "XF86AudioStop",{description="Change player",group="Player"}, "player_change"},
	{{}, "XF86AudioPrev",{description="Play previous song",group="Player"}, "player_prev"},
	{{}, "XF86AudioNext",{description="Play next song",group="Player"}, "player_next"},
	{{}, "XF86AudioPlay",{description="Play/pause song",group="Player"}, "player_play"},
	{{}, "XF86Tools",{description="Spawn player",group="Player"}, "player_spawn"},
	{{modkey}, "p",{description="Spawn player",group="Player"}, "player_spawn"},

	{{modkey}, "b",{description="Show battery state",group="Widgets"}, "battery_notify"},
	{{modkey}, "i",{description="Show ip status",group="Widgets"}, "net_notify"},

	{{}, "XF86Search",{description="Startmenu module",group="Module"},"menu_show" },
	{{modkey}, "x",{description="Startmenu module",group="Module"}, "menu_show"},
	{{modkey}, "v",{description="Volume module",group="Module"}, "menu_volume_show"},
	{{modkey}, "n",{description="Notify module",group="Module"}, "menu_notify_show"},
	{{modkey}, "w",{description="Wallpaper module",group ="Module"}, "menu_wallpaper_show"},
	{{modkey},'F1',{description="Show keybindings",group="Module"},"keys"},
	{{modkey},"Left",{description="Move to previous tag",group="Tag"},"tag_prev"},
	{{modkey},"Right",{description="Move to next tag",group="Tag"},"tag_next"},
	{{modkey,control},"Right",{description="Move client to next tag",group="Client"},"client_to_next"},
	{{modkey,control},"Left",{description="Move client to previous tag",group="Client"},"client_to_prev"},


}

if term then
table.insert(public.globals,{{modkey},"Return",{description="Spawn terminal",group="Terminal"},function() awful.spawn.with_shell(term) end})
end
public.wallpaper_keys = {
	{{},'Up',{description="Previous directory",group="Dirs"},"prev_dir"},
	{{},'Down',{description="Next directory",group="Dirs"},"next_dir"},
	{{},'r',{description="Restart timer",group="Timer"},"restart"},
	{{},'p',{description="Start timer",group="Timer"},"start"},
	{{},'s',{description="Stop timer",group="Timer"},"stop"},
	{{},'t',{description="Show timer",group="Timer"},"time"},
	{{},'space',{description="Set chosen wallpaper",group="Wallpaper"},"set"},
	{{},'Left',{description="Previous wallpaper",group="Wallpaper"},"prev_wall"},
	{{},'Right',{description="Next wallpaper",group="Wallpaper"},"next_wall"},
	{{},'Return',{description="Set chosen wallpaper",group="Wallpaper"},"set"},
	{{},'x',{description="Quit module",group="Module"},"quit"},
	{{},'Escape',{description="Quit module",group="Module"},"quit"},
	{{modkey},'F1',{description="Show keybindings",group="Module"},"keys"},
}
public.startmenu_keys = {
	{{modkey},'w',{description="Switch to wallpaper module",group="Module"},'wallpaper_show'},
	{{modkey},'v',{description="Switch to volume module",group="Module"},'volume_show'},
	{{modkey},'e',{description="Switch to exit screen module",group="Module"},'exit_show'},
	{{},'Up',{description="Previous entry",group="Entry"},'prev_entry'},
	{{},'Down',{description="Next entry",group="Entry"},'next_entry'},
	{{},'Escape',{description="Quit module",group="Start menu"},'quit'},
	{{},'Return',{description="Execute entry",group="Entry"},'exec'},
	{{modkey},'F1',{description="Show keybindings",group="Module"},"keys"},
}
public.volume_keys = {
	{{},'Up',{description="Previous entry",group="Entry"},"prev_entry"},
	{{},'Down',{description="Next entry",group="Entry"},"next_entry"},
	{{},'r',{description="Restart module",group="Module"},"restart"},
	{{'Shift'},'K',{description="Kill client",group="Module"},"kill"},
	{{},'Left',{description="Decrease volume",group="Volume"},"dec"},
	{{},'Right',{description="Increase volume",group="Volume"},"inc"},
	{{},'XF86AudioLowerVolume',{description="Decrease volume",group="Volume"},"dec"},
	{{},'XF86AudioRaiseVolume',{description="Increase volume",group="Volume"},"inc"},
	{{},'space',{description="Mute volume",group="Volume"},"mute"},
	{{},'XF86AudioMute',{description="Mute volume",group="Volume"},"mute"},
	{{},'Tab',{description="Change tab",group="Module"},"tab"},
	{{},'c',{description="Change default sink source",group="Module"},"change"},
	{{},'Escape',{description="Quit module",group="Module"},"quit"},
	{{},'x',{description="Quit module",group="Module"},"quit"},
	{{modkey},'F1',{description="Show keybindings",group="Module"},"keys"},

}


public.client_keybinding = {
	{{modkey},"f",{description="Client fullscreen toggle",group="Client"},function(c)
c.fullscreen = not c.fullscreen c:raise() if not c.fullscreen then c.border_width = beautiful.border_width end

end
},
	{{modkey,control},"f",{description="Client floating toggle",group="Client"},function(c) c.floating = not c.floating  end },
	{{modkey,'Shift'},"c",{description="Client kill",group="Client"},function(c) c:kill()  end },
	{{modkey},"m",{description="Client maximize toggle",group="Client"},function(c) c.maximized = not c.maximized c:raise()  end },

}

local aa = {
	"KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin", "KP_Right",
	"KP_Home", "KP_Up", "KP_Prior"
}
public.client_mosebindings = {
	{{},1,{description="Focus client",group="Client mouse"},function(c) c:activate{context = "mouse_click"} end },
	{{modkey},1,{description="Move client",group="Client mouse"},function(c) c.floating = true c:activate{context = "mouse_click",action="mouse_move"} end },
	{{modkey},3,{description="Resize client",group="Client mouse"},function(c) c.floating = true c:activate{context = "mouse_click",action="mouse_resize"} end },
	{{},3,{description="Focus client",group="Client mouse"},function(c) c:activate{context = "mouse_click"} end },

}
public.mouse_globals={
	{{},3,{description="Show exit screen",group="Mouse binding"},'exit'}
}
public.for_keys = {
tagswitch ={{1,5},{modkey}},
move_client_to ={{1,5},{modkey,control}},
numpad = {aa,{modkey} --[[move to position --]],{modkey,control}--[[increase size to position --]],{modkey,'Shift'}--[[move to position and maximize horizontally vertically
--]],{modkey,'Shift',control}--[[descrease size to position--]]}

}
return public
