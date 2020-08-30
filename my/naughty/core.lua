local capi = {screen = screen}
local gdebug = require("my.gears.debug")
local screen = require("my.awful.screen")
local gtable = require("my.gears.table")
local gobject = require("my.gears.object")
local gsurface = require("my.gears.surface")

local naughty = {}

-- gtable.crush(naughty, require("my.naughty.constants"))

local properties = {
    suspended = false,
    expiration_paused = false,
    auto_reset_timeout = true,
    image_animations_enabled = false,
    persistence_enabled = false
}

naughty.notifications = {suspended = {}, _expired = {{}}}

naughty._active = {}

screen.connect_for_each_screen(function(s)
    naughty.notifications[s] = {
        top_left = {},
        top_middle = {},
        top_right = {},
        bottom_left = {},
        bottom_middle = {},
        bottom_right = {},
        middle = {}
    }
end)
local conns = gobject._setup_class_signals(naughty, {
    allow_chain_of_responsibility = true
})

local function resume()
    properties.suspended = false
    for _, v in pairs(naughty.notifications.suspended) do
        local args = v._private.args
        assert(args)
        v._private.args = nil

        naughty.emit_signal("added", v, args)
        naughty.emit_signal("request::display", v, "resume", args)
        if v.timer then v.timer:start() end
    end
    naughty.notifications.suspended = {}
end






function naughty.destroy_all_notifications(screens, reason)
    if not screens then
        screens = {}
        for key, _ in pairs(naughty.notifications) do
            table.insert(screens, key)
        end
    end
    local ret = true
    for _, scr in pairs(screens) do
        for _, list in pairs(naughty.notifications[scr]) do
            while #list > 0 do

                assert(not list[1]._private.is_destroyed)

                ret = ret and list[1]:destroy(reason)
            end
        end
    end
    return ret
end


function naughty.get_by_id(id)

    for s in pairs(naughty.notifications) do
        for p in pairs(naughty.notifications[s]) do
            for _, notification in pairs(naughty.notifications[s][p]) do
                if notification.id == id then return notification end
            end
        end
    end
end

function naughty.get_active() return naughty._active end

function naughty.get_has_display_handler()
    return conns["request::display"] and #conns["request::display"] > 0 or false
end

function naughty.get__has_preset_handler()
    return conns["request::preset"] and #conns["request::preset"] > 0 or false
end

function naughty._reset_display_handlers() conns["request::display"] = nil end







function naughty.set_expiration_paused(p)
    properties.expiration_paused = p

    if not p then
        for _, n in ipairs(naughty.notifications._expired[1]) do
            n:destroy(naughty.notification_closed_reason.expired)
        end
    end
end

function naughty.default_screen_handler(n)
    if n.screen and n.screen.valid then return end

    n.screen = screen.focused()
end





local function index_miss(_, key)
    if rawget(naughty, "get_" .. key) then
        return rawget(naughty, "get_" .. key)()
    elseif properties[key] ~= nil then
        return properties[key]
    else
        return nil
    end
end

local function set_index_miss(_, key, value)
    if rawget(naughty, "set_" .. key) then
        return rawget(naughty, "set_" .. key)(value)
    elseif properties[key] ~= nil then
        assert(type(value) == "boolean")
        properties[key] = value
        if not value then resume() end

        naughty.emit_signal("property::" .. key, value)
    else
        rawset(naughty, key, value)
    end
end

local nnotif = nil

function naughty.notify(args)

    nnotif = nnotif or require("my.naughty.notification")

    local n =
        args and args.replaces_id and naughty.get_by_id(args.replaces_id) or nil

    if n then return gtable.crush(n, args) end

    return nnotif(args)
end

function naughty.client_icon_handler(self, context)
    if context ~= "clients" then return end

    local clients = self:get_clients()

    for _, t in ipairs {"normal", "dialog"} do
        for _, c in ipairs(clients) do
            if c.type == t then
                self._private.icon = gsurface(c.icon)
                return
            end
        end
    end
end

function naughty.icon_path_handler(self, context, hints)
    if context ~= "image" and context ~= "path" then return end

    self._private.icon = gsurface.load_uncached_silently(
                             hints.path or hints.image)
end

function naughty.icon_clear_handler(self, context, hints)
    if context ~= "dbus_clear" then return end

    self._private.icon = nil
    self:emit_signal("property::icon")
end



naughty.connect_signal("request::icon", naughty.client_icon_handler)
naughty.connect_signal("request::icon", naughty.icon_path_handler)
naughty.connect_signal("request::icon", naughty.icon_clear_handler)

return
    setmetatable(naughty, {__index = index_miss, __newindex = set_index_miss})

