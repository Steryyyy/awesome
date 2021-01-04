

<!-- <img src="https://github.com/Steryyyy/awesome/blob/master/screenshots/alll.jpg" width="100%"> -->

<!-- vim-markdown-toc GitLab -->

* [Configuration file structure](#configuration-file-structure)
	* [modules](#modules)
	* [widgets](#widgets)
	* [tools](#tools)
* [Dependencies](#dependencies)
	* [Required](#required)
	* [Optional](#optional)
* [Customization](#customization)
	* [Changins settings.lua](#changins-settingslua)
	* [Changing corona virus tracker](#changing-corona-virus-tracker)
	* [Wallpaper module / wallpapers](#wallpaper-module-wallpapers)
	* [Changing / adding colors](#changing-adding-colors)
	* [Start menu](#start-menu)
		* [Manually generated](#manually-generated)
		* [Auto generated](#auto-generated)
	* [Profile picture](#profile-picture)
	* [Change terminal](#change-terminal)
	* [Change clients "rules"](#change-clients-rules)
	* [Change password](#change-password)
	* [Further customisation](#further-customisation)
* [Key bindings](#key-bindings)
* [Gallery](#gallery)

<!-- vim-markdown-toc -->


# Configuration file structure
+ `settings.lua`

Settings for widgets and modules

+ `rc.lua`

Main configuration file awesomeWM reads that file.

+ `keybindings.lua`

Default key bindings, mouse bindings, client key bindings

## modules

Wiboxes with custom key bindings and serve certain purpose.
+ `volcontrol.lua`

Control volume and default sink and source.
Volume widget use it.
+ `exit_screen.lua`

Allow to power off, reboot, restart awesomeWM, exit awesomeWM and "lock" for lockscreen.

+ `startmenu.lua`

Is used to spawn application and/or run command.

+ `wallpaper.lua`

Change wallpaper manually or change when timer restarts.

+ `notif.lua`

Allow to control notification.

## widgets

+ `stats.lua`

Memory and cpu usage percentage.

+ `volume.lua`

Shows default sink and source.

+ `net.lua`

Shows local ip address.

+ `battery.lua`

Shows battery status.

+ `player.lua`

Controls and shows player status.

+ `taglist.lua`

Shows workspaces.

## tools

+ `connect.lua`

Rules for clients.

+ `terminal_dropdown.lua`

Controls dropdown terminal.

+ `shapes.lua`

Shapes used in wibar and modules

+ 'colors'

Colors for modules, widgets, wibar


# Dependencies



## Required

| Name                                                | why?     |
| ---                                                 | ---      |
| [awesome-git](https://github.com/awesomeWM/awesome) | why not? |
| lua5.3                                              |Some lines might be interpreted wrongly in previous lua versions |
<!--[Cinnamon](https://nekopara.fandom.com/wiki/Cinnamon)| best catgirl| -->

## Optional

| Name                                                                 | why?                                                                          |
| ---                                                                  | ---                                                                           |
| [cmus](https://github.com/cmus/cmus)                                 | for player widget                                                             |
| [Source Han Sans JP](https://github.com/adobe-fonts/source-han-sans) | if you want japanese characters |
| [Font Awesome 5](https://fontawesome.com/)                           | for font icons ( has awesome in name so only works with awesomewm :))         |
| [Nerd font](https://www.nerdfonts.com/font-downloads)                | for font icons                                                                |
| awk                                                                  | for volume module and widgets player, net, status and corona tracked          |
| grep                                                                 | same as awk                                                                   |
| pacmd and pulseaudio                                                 | volume module and player widget                                               |
| sed                                                                  | same as grep                                                                  |
| tr                                                                   | yes                                                                           |
| urxvt                                                                | to dropdown terminal                                                          |
| urxvd                                                                | to dropdown terminal run urxvtd before awesomewm in .xinitrc                  |
| xwallpaper|for changing wallpaper|

# Customization
## Changins settings.lua
Open default_settings.lua for refrence and edit settings.lua

**Don't change**  `default_settings.lua`

Example of settings.lua
```lua
local settings = require('default_settings')
change(settings,{"widgets"},"battery", "/sys/class/power_supply/BAT1")

change(settings,{ --[[Here give all arrays value is in --]] 'widgets','player'}, --[[ Here which value you want to change--]] "max_song_title",--[[ Here put value --]]70 )
```
## Changing corona virus tracker

Go to [https://github.com/sagarkarira/coronavirus-tracker-cli](https://github.com/sagarkarira/coronavirus-tracker-cli)
to find your country name and code
``` lua

change(settings,{"rc"},"country_name", --[[ Change to your country name --]]"USA")
change(settings,{"rc"},"country_code", --[[Change to your country code --]]"usa")

```

## Wallpaper module / wallpapers
Run scripts/thumbnail.sh to create thumbnails and config/wallpapers.lua

thumbnail.sh takes folders from ~/wallpaper
Files must be named 1.jpg 2.jpg etc.
and be in folder.

Example of folder structure

``` sh

~/wallpaper/
├── awe
│   ├── 1.jpg
│   ├── 2.jpg
│   ├── 3.jpg
│   ├── 4.jpg
│   └── 5.jpg
├── some
│   ├── 1.jpg
│   ├── 2.jpg
│   ├── 3.jpg
│   ├── 4.jpg
│   ├── 5.jpg
│   ├── 6.jpg
│   ├── 7.jpg
│   └── 8.jpg
└── wm
    ├── 1.jpg
    ├── 2.jpg
    ├── 3.jpg
    ├── 4.jpg
    ├── 5.jpg
    ├── 6.jpg
    ├── 7.jpg
    ├── 8.jpg
    └── 9.jpg
```
Go to ~/.config/awesome/settings.lua
``` lua

change(settings,{"wallpaper"},"wallpaper_width", --[[ Change to your wallpaper width --]]1920)
change(settings,{"wallpaper"},"wallpaper_height", --[[ Change to your wallpaper hight --]]1080)

```
Run thumbnail.sh to generate thumbnails for wallpaper module
```sh
~/.config/awesome/scripts/thumbnail.sh
```
It will generate config file in ~/.config/awesome/config/wallpapers.lua

Example of config file

```lua
return{{"awe",5},{"some",8},{"wm",9},}
```
**If number next to folder name isn't same as number of files in that folder simply change it.**

## Changing / adding colors

Create file create.lua in folder tools/colors/

**Number of strings in arrays shouldn't be changed**

Example
```lua
return {
--chosen_array
{
-- chosencol
{
w = {"col1","col2","col3","col4","col5"},
tg = {"col1","col2","col3","col4"},
tgs ={"col1","col2","col3"},

},
}
}
```
Better way is link files for each wallpaper folder

Example

+ create.lua

```lua
return{
require('tools.colors.awe'),
require('tools.colors.some'),
require('tools.colors.wm'),
}
```

+ awe.lua

```lua
return{
{
w={'#aa0d0a','#dc100c','#aa1812','#f73420','#21aa10'} ,
tg={'#f9ba50','#c79540','#f9c864','#aa5717'} ,
tgs={'#55a49e','#f9f6dd','#2adc14'} ,
} ,
{
w={'#f9ebda','#ebe4db','#c8ddcc','#e1f9e3','#a1cedb'} ,
tg={'#c7c5bf','#dbd9d5','#c7c4af','#f7f9f5'} ,
tgs={'#a1cedb','#dc5d38','#aa5f32'} ,
},
}
```
Only way to change colors is to change wallpaper through wallpaper module

Remember to link files in same order as their folder is in ~/.config/awesome/config/wallpapers.lua.

## Start menu
### Manually generated
Simply run
``` sh
~/.config/awesome/scripts/luamenu
```

It should find desktop files from /usr/share/applications/
and create config file in ~/.config/awesome/config/menu.lua
### Auto generated

Go to ~/.config/awesome/settings.lua
```lua
change(settings,{"start_menu"},"auto_menu", true)
```
And reload configuration

## Profile picture

add profile.jpg to ~/.config/awesome/images/
## Change terminal
Go to ~/.config/awesome/settings.lua

```lua
change(settings,{},"terminal",  "xterm")
```


## Change clients "rules"
Go to ~/.config/awesome/tools/connect.lua

And change find_class

## Change password
Go to ~/.config/awesome/modules/exit_screen.lua

And change password

## Further customisation

Do what you want.



# Key bindings
Modkey is super key (windows key)

Modkey + F1 to cheat sheet


# Gallery
| Startmenu module and volume mode                                                              | Volume module and wallpaper module |
| --                                                                     | --                                 |
| ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/start_menu.jpg) | ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/volume_clients.jpg)|

| Notification                                                             | Exit srceen                                                      |
| --                                                                       | --                                                               |
| ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/notification.jpg) | ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/exit.jpg) |


