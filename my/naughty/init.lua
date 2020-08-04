---------------------------------------------------------------------------
-- @author Uli Schlachter &lt;psychon@znc.in&gt;
-- @copyright 2014 Uli Schlachter
-- @module naughty
---------------------------------------------------------------------------

local naughty = require("my.naughty.core")
local gdebug = require("my.gears.debug")
local capi = {awesome = awesome, screen = screen}
if dbus then
    naughty.dbus = require("my.naughty.dbus")
end


naughty.notification = require("my.naughty.notification")


local function screen_fallback()
    if capi.screen.count() == 0 then
        gdebug.print_warning("An error occurred before a scrren was added")

        -- Private API to scan for screens now.
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

-- Handle runtime errors during startup
if capi.awesome.startup_errors then

    -- Wait until `rc.lua` is executed before creating the notifications.
    -- Otherwise nothing is handling them (yet).
    client.connect_signal("scanning", function()
        -- A lot of things have to go wrong for this to happen, but it can.
        screen_fallback()

        naughty.emit_signal(
            "request::display_error", capi.awesome.startup_errors, true
        )
    end)
end

-- Handle runtime errors after startup
do
    local in_error = false

    capi.awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end

        in_error = true

        screen_fallback()

        naughty.emit_signal("request::display_error", tostring(err), false)

        in_error = false
    end)

end

return naughty

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
