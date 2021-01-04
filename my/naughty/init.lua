
local naughty = require("my.naughty.core")
local gdebug = require("gears.debug")
local capi = {awesome = awesome, screen = screen}
if dbus then
    naughty.dbus = require("my.naughty.dbus")
end
naughty.notification = require("my.naughty.notification")
local function screen_fallback()
    if capi.screen.count() == 0 then
        gdebug.print_warning("An error occurred before a scrren was added")

        if #screen._viewports() == 0 then
            screen._scan_quiet()
        end

        local viewports = screen._viewports()

        if #viewports > 0 then
            for _, viewport in ipairs(viewports) do
                local geo = viewport.geometry
                local s = capi.screen.fake_add(geo.x, geo.y, geo.width, geo.height)
                s.outputs = viewport.outputs
            end
        else
            capi.screen.fake_add(0, 0, 640, 480)
        end
    end
end

if capi.awesome.startup_errors then

    client.connect_signal("scanning", function()
        screen_fallback()

        naughty.emit_signal(
            "request::display_error", capi.awesome.startup_errors, true
        )
    end)
end

do
    local in_error = false

    capi.awesome.connect_signal("debug::error", function (err)
        if in_error then return end

        in_error = true

        screen_fallback()

        naughty.emit_signal("request::display_error", tostring(err), false)

        in_error = false
    end)

end
return naughty
