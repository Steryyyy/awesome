

<img src="https://github.com/Steryyyy/awesome/blob/master/screenshots/alll.jpg" width="50%">


<!-- vim-markdown-toc GFM -->

* [Dependencies](#dependencies)
	* [Required](#required)
	* [Optional](#optional)
* [Customization](#customization)
	* [Changing corona virus tracker](#changing-corona-virus-tracker)
	* [Changind / adding colors](#changind--adding-colors)
	* [Wallpaper module](#wallpaper-module)
	* [Start menu](#start-menu)
	* [Profile picture](#profile-picture)
	* [Change terminal](#change-terminal)
	* [Change clients tags](#change-clients-tags)
	* [Change password](#change-password)
	* [Farther customisation](#farther-customisation)
* [Key bindings](#key-bindings)
	* [Default mode](#default-mode)
		* [Volume and player](#volume-and-player)
		* [Switching to modules](#switching-to-modules)
		* [Notification](#notification)
		* [Screen keybindings](#screen-keybindings)
		* [Tag keybindings](#tag-keybindings)
		* [Client keybindings](#client-keybindings)
	* [Module keybindings](#module-keybindings)
		* [Startmenu module](#startmenu-module)
		* [Volume module](#volume-module)
		* [Wallpaper module](#wallpaper-module-1)
		* [Notification module](#notification-module)
		* [Exitmenu module](#exitmenu-module)
	* [Mouse binding](#mouse-binding)
		* [Default](#default)
		* [Exitmenu module](#exitmenu-module-1)
* [Gallery](#gallery)

<!-- vim-markdown-toc -->


# Dependencies



## Required

| Name                                                | why?     |
| ---                                                 | ---      |
| [awesome-git](https://github.com/awesomeWM/awesome) | why not? |
<!--[Cinnamon](https://nekopara.fandom.com/wiki/Cinnamon)| best catgirl| -->

## Optional

| Name                                                                 | why?                                                                          |
| ---                                                                  | ---                                                                           |
| [cmus](https://github.com/cmus/cmus)                                 | for player widget                                                             |
| [Source Han Sans JP](https://github.com/adobe-fonts/source-han-sans) | if you want japanese characters (beautiful.font_name default font) |
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

## Changing corona virus tracker

Go to [https://github.com/sagarkarira/coronavirus-tracker-cli](https://github.com/sagarkarira/coronavirus-tracker-cli)
to find your country name and code

Go to ~/.config/awesome/rc.lua
and edit country_name and ISO_3166_1 to your country code


## Changind / adding colors

Create file create.lua in folder tools/colors/

File must contain something like that

**Number of strings in arrays shouldn't be changed**
```lua
return {
--chosen_array{
-- chosencol{
w = {"col1","col2","col3","col4","col5"},
tg = {"col1","col2","col3","col4"},
tgs ={"col1","col2","col3"},
tks = {"col"},

},
}
}
```
Only way to change widgets colors is to change wallpaper through wallpaper module

## Wallpaper module
Run scripts/thumbnail.sh to create thumbnails and config/wallpapers.lua

thumbnail.sh takes folders from ~/wallpaper
Files must be named 1.jpg 2.jpg etc.
and be in other folders

Example

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

Go to ~/.config/awesome/modules/wallpaper.lua
And change wallpaper_width to your monitor resolution
```
## Start menu
Simply run
``` sh
lua ~/.config/awesome/scripts/luamenu.lua > ~/.config/awesome/config/menu.lua
```
It should find desktop files from /usr/share/applications/

## Profile picture

add profile.jpg to ~/.config/awesome/images/
## Change terminal
Go to ~/.config/awesome/tools/connect.lua

And change term_command

Go to ~/.config/awesome/widgets/player.lua

And change term_command

## Change clients tags
Go to ~/.config/awesome/tools/connect.lua

And change find_class

## Change password
Go to ~/.config/awesome/modules/exit_screen.lua

And change password

## Farther customisation

Do what you want.



# Key bindings
Modkey is super key (windows key)

Return enter
## Default mode

### Volume and player

| key binding                          | Action                                            |
| ---                                  | ---                                               |
| modkey + p                           | spawn player if is not running                    |
| X86Audioplay                         | Player play/pause                                 |
| modkey + X86Audioplay                | Player previous file                              |
| modkey + X86AudioStop                | Player next file                                  |
| modkey + X86AudioStop                | Player next player (cmus to spotify or other way) |
| X86AudioMute                         | Mute sink input                                   |
| X86AudioRaiseVolume                  | Default sink volume up                            |
| X86AudioLowerVolume                  | Default sink volume down                          |
| modkey + Shift + X86AudioMute        | Mute default source                               |
| modkey + Shift + X86AudioRaiseVolume | Default source volume up                          |
| modkey + Shift + X86AudioLowerVolume | Default source volume down                        |

### Switching to modules

| key binding | Action                                                                 |
| ---         | ---                                                                    |
| modkey + n  | Show notification module and switch to notification module keybindings |
| modkey + x  | Show startmenu and switch to startmenu keybindings                     |
| modkey + w  | Show wallpaper module and switch to wallpaper module keybindings       |
| modkey + v  | Show volume module and switch to volume module keybindings             |

### Notification

| key binding | Action                                  |
| ---         | ---                                     |
| modkey + i  | Get network ip and mac                  |
| modkey + b  | Battery state and update battery widget |



### Screen keybindings
| key binding          | Action                         |
| ---                  | ---                            |
| modkey + Control + k | Focus previous screen          |
| modkey + Control + j | Focus next screen              |
| modkey + k           | Move client to previous screen |
| modkey + j           | Move client to next screen     |

### Tag keybindings

| key binding             | Action                    |
| ---                     | ---                       |
| modkey + Control + h    | Go to idden tag           |
| modkey + 1..5           | Go to tag                 |
| modkey + Control + 1..5 | Move client and go to tag |
| modkey + Leftarrow      | Previous tag              |
| modkey + Rightarrow     | Next tag                  |
| modkey + h              | Shrink gap                |
| modkey + l              | Increase gap              |
| modkey + Space          | Next screen layout        |
| modkey + Shift + Space  | Previous screen layout    |


### Client keybindings
| key binding                             | Action                                   |
| ---                                     | ---                                      |
| modkey + q                              | Toggle dropdown terminal visibility      |
| modkey + Tab                            | Focus next client (for all screens)      |
| modkey + Shift + Tab                    | Focus previous client (for all screens)  |
| modkey + n                              | Client restore                           |
| modkey + Shift + j                      | Swap client with next                    |
| modkey + Shift + k                      | Swap client with previous                |
| modkey + u                              | Go to urgent tab                         |
| modkey + Control + Leftarrow            | Move client to previous tag and go there |
| modkey + Control + Rightarrow           | Move client to next tag and go there     |
| modkey + Shift + c                      | Kill selected client                     |
| modkey + m                              | Client toggle maximize                   |
| modkey + f                              | Client toggle fullscreen                 |
| modkey + Shift + f                      | Client toggle float                      |
| modkey + Numpad[1-9]                    | Move floating client to  site            |
| modkey + Shift +  Numpad[1-9]           | Move floating client to site and resize  |
| modkey + Control +  Numpad[1-9]         | Increase size client                     |
| modkey + Shift + Control +  Numpad[1-9] | Decrees size client                      |



##Module keybindings
### Startmenu module


| key binding         | Action                                                           |
| ---                 | ---                                                              |
| modkey + w          | Show wallpaper module and switch to wallpaper module keybindings |
| modkey + v          | Show volume module and switch to volume module keybindings       |
| modkey + e          | Show exitmenu and switch to exitmenu module keybindings          |
| X86AudioMute        | Mute sink input                                                  |
| X86AudioRaiseVolume | Default sink volume up                                           |
| X86AudioLowerVolume | Default sink volume down                                         |
| Uparrow             | Previous entry                                                   |
| Downarrow           | Next entry                                                       |
| Escape              | Hide startmenu and switch to default keybindings                 |
| Return              | Exec entry hide startmenu and switch to previous keybindings     |

### Volume module

| key binding | Action                                                 |
| ---         | ---                                                    |
| Uparrow     | Previous entry                                         |
| Downarrow   | Next entry                                             |
| Leftarrow   | Entry volume -5                                        |
| Rightarrow  | Entry volume  +5                                       |
| c           | Change default sink/source or change input/output card |
| K           | Kill input/source                                      |
| r           | restart                                                |
| Escape or x | Hide volume module and switch to previous keybindings  |

### Wallpaper module

| key binding     | Action                                                   |
| ---             | ---                                                      |
| Uparrow         | Previous wallpaper directory                             |
| Downarrow       | Next wallpaper directory                                 |
| Leftarrow       | Previous wallpaper                                       |
| Rightarrow      | Next wallpaper                                           |
| Space or Return | Change wallpaper                                         |
| t               | Notify timer                                             |
| r               | restart timer and start                                  |
| s               | Pause timer                                              |
| p               | Resume timer                                             |
| Escape or x     | Hide wallpaper module and switch to previous keybindings |

### Notification module


| key binding     | Action                                                    |
| ---             | ---                                                       |
| t               | Toggle showing message                                    |
| Space or Return | kill first notification                                   |
| Escape or x     | Hide notication module and switch to previous keybindings |

### Exitmenu module


| key binding         | Action                                           |
| ---                 | ---                                              |
| Leftarrow           | Previous entry                                   |
| Rightarrow          | Next entry                                       |
| Escape or x q       | Hide exitmenu and switch to previous keybindings |
| X86AudioMute        | Mute sink input                                  |
| X86AudioRaiseVolume | Default sink volume up                           |
| X86AudioLowerVolume | Default sink volume down                         |
| Return              | Execute entry (lock and reload immediately )     |

Mouse only work here.





## Mouse binding
### Default
Courently only rightclick on wallpaper show exitmenu module
### Exitmenu module
Left click to start selected entry count down


# Gallery
| Startmenu module and volume mode                                                              | Volume module and wallpaper module |
| --                                                                     | --                                 |
| ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/start_menu.jpg) | ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/volume_clients.jpg)|

| Notification                                                             | Exit srceen                                                      |
| --                                                                       | --                                                               |
| ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/notification.jpg) | ![startmenu](https://github.com/Steryyyy/awesome/blob/master/screenshots/exit.jpg) |


