local capi = {screen = screen}
local gobject = require("gears.object")
local gtable = require("gears.table")

local gfs = require("gears.filesystem")

local naughty = require("my.naughty.core")

local pcommon = require("awful.permissions._common")

local notification = {}


function notification:reset_timeout(new_timeout)
    if self.timer then self.timer:stop() end

    if new_timeout and self.timer then self.timeout = new_timeout end

    if self.timer and not self.timer.started then self.timer:start() end
end
--[[
local properties = {
    "message", "title", "timeout", "hover_timeout", "app_name", "position",
    "ontop", "border_width", "width", "font", "icon", "icon_size", "fg", "bg",
    "height", "border_color", "shape", "opacity", "margin", "ignore_suspend",
    "destroy", "preset", "callback", "actions", "run", "id", "ignore",
    "auto_reset_timeout", "urgency", "image", "images", "widget_template",
    "max_width"
}
--]]

--[[
for _, prop in ipairs(properties) do
    notification["get_" .. prop] = notification["get_" .. prop] or
                                       function(self)

            local preset = rawget(self, "preset")

            return self._private[prop] or (preset and preset[prop]) or
                       cst.config.defaults[prop]
        end

    notification["set_" .. prop] = notification["set_" .. prop] or
                                       function(self, value)
            self._private[prop] = value
            self:emit_signal("property::" .. prop, value)

            local reset = ((not self.suspended) and self.auto_reset_timeout ~=
                              false and naughty.auto_reset_timeout)

            if reset then self:reset_timeout() end
        end

end

--]]
for _, prop in ipairs {"image", "images"} do
    local cur = notification["set_" .. prop]

    notification["set_" .. prop] = function(self, value)
        cur(self, value)
        self._private.icon = nil
        self:emit_signal("property::icon")
    end
end

local hints_default = {urgency = "normal", resident = false}

for _, prop in ipairs {"category", "resident"} do
    notification["get_" .. prop] = notification["get_" .. prop] or
                                       function(self)
            return self._private[prop] or
                       (self._private.freedesktop_hints and
                           self._private.freedesktop_hints[prop]) or
                       hints_default[prop]
        end

    notification["set_" .. prop] = notification["set_" .. prop] or
                                       function(self, value)
            self._private[prop] = value
            self:emit_signal("property::" .. prop, value)
        end
end

local function request_filter(self, context, _)
    if not pcommon.check(self, "notification", "icon", context) then
        return true
    end
    if self._private.icon then return true end
end

local function check_path(input)
    if type(input) ~= "string" then return nil end

    if input:sub(1, 7) == "file://" then input = input:sub(8) end

    input = input:gsub("%%(%x%x)",
                       function(x) return string.char(tonumber(x, 16)) end)

    return gfs.file_readable(input) and input or nil
end






function notification:append_actions(new_actions)
    self._private.actions = self._private.actions or {}

    for _, a in ipairs(new_actions or {}) do
        a:connect_signal("_changed", self._private.action_cb)
        a:connect_signal("invoked", self._private.invoked_cb)
        table.insert(self._private.actions, a)
    end

end








local function create(args)
    --[[
    if cst.config.notify_callback then
        args = cst.config.notify_callback(args)
        if not args then return end
    end
    --]]

    assert(not args.id, "Identifiers cannot be specified externally")

    args = args or {}


    local n = gobject {enable_properties = true}

    if args.text then

        args.message = args.text
    end

    assert(naughty.emit_signal)

    n:_connect_everything(naughty.emit_signal)

    local private = {weak_screen = setmetatable({}, {__mode = "v"})}
    rawset(n, "_private", private)






    n.is_expired = false

    gtable.crush(n, notification, true)


    n.id = n.id or notification._gen_next_id()

    n:emit_signal("new", args)

    if naughty._has_preset_handler then
        naughty.emit_signal("request::preset", n, "new", args)
    end

    if (not n.ignore) and ((not n.preset) or n.preset.ignore ~= true) then
        naughty.emit_signal("request::display", args)
    end

    if n._private.timeout then
        n:set_timeout(n._private.timeout or (n.preset and n.preset.timeout) or
                          2)
    end

    return n
end



local counter = 1

function notification._gen_next_id()
    counter = counter + 1
    return counter
end

return setmetatable(notification,
                    {__call = function(_, ...) return create(...) end})
