local awful = require("my.awful")
local beautiful = require("my.beautiful")


awful.rules.rules = {

    {
        rule = {},
        properties = {
            border_width = 3,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,

            size_hints_honor = false,

            screen = awful.screen.preferred

        }
    }, {
        rule_any = {
            instance = {"DTA", "copyq", "pinentry"},
            class = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin",
                "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },

            name = {"Event Tester"},

            role = {"AlarmWindow", "ConfigManager", "pop-up"}
        },
        properties = {floating = true}
    },
}
