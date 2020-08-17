local pairs = pairs
local type = type
local string = string
local capi = {awesome = awesome}
local gsurface = require("my.gears.surface")

local protected_call = require("my.gears.protected_call")
local lgi = require("lgi")
local cairo, Gio, GLib, GObject = lgi.cairo, lgi.Gio, lgi.GLib, lgi.GObject

local schar = string.char
local sbyte = string.byte
local tcat = table.concat
local tins = table.insert
local unpack = unpack or table.unpack
local naughty = require("my.naughty.core")
-- local cst = require("my.naughty.constants")
local nnotif = require("my.naughty.notification")

local capabilities = {
    "body", "body-markup", "icon-static", "actions", "action-icons"
}

local dbus = {config = {}}

local bus_connection

local urgency = {low = "\0", normal = "\1", critical = "\2"}

-- dbus.config.mapping = cst.config.mapping



local function convert_icon(w, h, rowstride, channels, data)

    local expected_length = rowstride * (h - 1) + w * channels
    if w < 0 or h < 0 or rowstride < 0 or (channels ~= 3 and channels ~= 4) or
        string.len(data) < expected_length then
        w = 0
        h = 0
    end

    local format = cairo.Format[channels == 4 and 'ARGB32' or 'RGB24']

    local stride = cairo.Format.stride_for_width(format, w)
    local append = schar(0):rep(stride - 4 * w)
    local offset = 0

    local rows = {}

    for _ = 1, h do
        local this_row = {}

        for i = 1 + offset, w * channels + offset, channels do
            local R, G, B, A = sbyte(data, i, i + channels - 1)
            tins(this_row, schar(B, G, R, A or 255))
        end

        tins(this_row, append)
        tins(rows, tcat(this_row))

        offset = offset + rowstride
    end

    local pixels = tcat(rows)
    local surf = cairo.ImageSurface
                     .create_for_data(pixels, format, w, h, stride)

    local res = gsurface.duplicate_surface(surf)
    surf:finish()
    return res
end

local notif_methods = {}

function notif_methods.Notify(sender, object_path, interface, method,
                              parameters, invocation)
    local appname, replaces_id, app_icon, title, text, actions, hints, expire =
        unpack(parameters.value)

    local args = {}
    if text ~= "" then
        args.message = text
        if title ~= "" then args.title = title end
    else
        if title ~= "" then
            args.message = title
        else

            return
        end
    end

    if appname ~= "" then
        args.appname = appname
        args.app_name = appname
    end

    local preset = args.preset or  {
    padding         = 4,
    spacing         = 1,
    icon_dirs       = { "/usr/share/pixmaps/", "/usr/share/icons/hicolor" },
    icon_formats    = { "png", "gif" },
    notify_callback = nil,
}

    local notification

    local legacy_data = {
        type = "method_call",
        interface = interface,
        path = object_path,
        member = method,
        sender = sender,
        bus = "session"
    }
    if not preset.callback or (type(preset.callback) == "function" and
        preset.callback(legacy_data, appname, replaces_id, app_icon, title,
                        text, actions, hints, expire)) then

        if app_icon ~= "" then args.app_icon = app_icon end

        if hints.icon_data or hints.image_data or hints["image-data"] then

            local icon_condidates = {}
            for k, v in parameters:get_child_value(7 - 1):pairs() do
                if k == "image-data" then
                    icon_condidates[1] = v
                    break
                elseif k == "image_data" then
                    icon_condidates[2] = v
                elseif k == "icon_data" then
                    icon_condidates[3] = v
                end
            end

            local icon_data = icon_condidates[1] or icon_condidates[2] or
                                  icon_condidates[3]

            local data = tostring(icon_data:get_child_value(7 - 1).data)
            args.image = convert_icon(icon_data[1], icon_data[2], icon_data[3],
                                      icon_data[6], data)

            if naughty.image_animations_enabled then
                args.images = {args.image}

                if #icon_data > 7 then
                    for frame = 8, #icon_data do
                        data = tostring(
                                   icon_data:get_child_value(frame - 1).data)

                        table.insert(args.images, convert_icon(icon_data[1],
                                                               icon_data[2],
                                                               icon_data[3],
                                                               icon_data[6],
                                                               data))
                    end
                end
            end
        end

        args.image = args.image or hints["image-path"] or hints["image_path"]

        args.freedesktop_hints = hints

        if hints and hints.urgency then
            for name, key in pairs(urgency) do
                local b = string.char(hints.urgency)
                if key == b then args.urgency = name end
            end
        end

        args.urgency = args.urgency or "normal"

        args._unique_sender = sender

        notification = nnotif(args)
        invocation:return_value(GLib.Variant("(u)", {notification._gen_next_id()}))
        return
    end

    invocation:return_value(GLib.Variant("(u)", {notification._gen_next_id()}))
end

function notif_methods.CloseNotification(_, _, _, _, parameters, invocation)
    --[[
    local obj = naughty.get_by_id(parameters.value[1])
    if obj then
        obj:destroy(cst.notification_closed_reason.dismissed_by_command)
    end
    --]]
    invocation:return_value(GLib.Variant("()"))
end

function notif_methods.GetServerInformation(_, _, _, _, _, invocation)

    invocation:return_value(GLib.Variant("(ssss)", {
        "naughty", "my.awesome", capi.awesome.version, "1.2"
    }))
end

function notif_methods.GetCapabilities(_, _, _, _, _, invocation)

    invocation:return_value(GLib.Variant("(as)", {capabilities}))
end

local function method_call(_, sender, object_path, interface, method,
                           parameters, invocation)
    if not notif_methods[method] then return end

    protected_call(notif_methods[method], sender, object_path, interface,
                   method, parameters, invocation)
end

local function on_bus_acquire(conn, _)
    local function arg(name, signature)
        return Gio.DBusArgInfo {name = name, signature = signature}
    end
    local method = Gio.DBusMethodInfo
    local signal = Gio.DBusSignalInfo

    local interface_info = Gio.DBusInterfaceInfo {
        name = "org.freedesktop.Notifications",
        methods = {
            method {name = "GetCapabilities", out_args = {arg("caps", "as")}},
            -- method {name = "CloseNotification", in_args = {arg("id", "u")}},
            method {
                name = "GetServerInformation",
                out_args = {
                    arg("return_name", "s"), arg("return_vendor", "s"),
                    arg("return_version", "s"), arg("return_spec_version", "s")
                }
            }, method {
                name = "Notify",
                in_args = {
                    arg("app_name", "s"), arg("id", "u"), arg("icon", "s"),
                    arg("summary", "s"), arg("body", "s"), arg("actions", "as"),
                    arg("hints", "a{sv}"), arg("timeout", "i")
                },
                out_args = {arg("return_id", "u")}
            }
        },
        signals = {
            signal {
                name = "NotificationClosed",
                args = {arg("id", "u"), arg("reason", "u")}
            }, signal {
                name = "ActionInvoked",
                args = {arg("id", "u"), arg("action_key", "s")}
            }
        }
    }
    conn:register_object("/org/freedesktop/Notifications", interface_info,
                         GObject.Closure(method_call))
end

local bus_proxy, pid_for_unique_name = nil, {}

Gio.DBusProxy.new_for_bus(Gio.BusType.SESSION,
                          Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES, nil,
                          "org.freedesktop.DBus", "/org/freedesktop/DBus",
                          "org.freedesktop.DBus", nil,
                          function(proxy) bus_proxy = proxy end, nil)

function dbus.get_clients(notif)

    local win_id = notif.freedesktop_hints and
                       (notif.freedesktop_hints.window_ID or
                           notif.freedesktop_hints["window-id"] or
                           notif.freedesktop_hints.windowID or
                           notif.freedesktop_hints.windowid)

    if win_id then
        for _, c in ipairs(client.get()) do
            if c.window_id == win_id then return {win_id} end
        end
    end

    local pid = notif.freedesktop_hints and
                    (notif.freedesktop_hints.PID or notif.freedesktop_hints.pid)

    if ((not bus_proxy) or not notif._private._unique_sender) and not pid then
        return {}
    end

    if (not pid) and (not pid_for_unique_name[notif._private._unique_sender]) then
        local owner = GLib.Variant("(s)", {notif._private._unique_sender})

        pid = bus_proxy:call_sync("GetConnectionUnixProcessID", owner,
                                  Gio.DBusCallFlags.NONE, -1)

        if (not pid) or (not pid.value) then return {} end

        pid = pid.value and pid.value[1]

        if not pid then return {} end

        pid_for_unique_name[notif._private._unique_sender] = pid
    end

    pid = pid or pid_for_unique_name[notif._private._unique_sender]

    if not pid then return {} end

    local ret = {}

    for _, c in ipairs(client.get()) do
        if c.pid == pid then table.insert(ret, c) end
    end

    return ret
end

local function on_name_acquired(conn, _) bus_connection = conn end

local function on_name_lost(_, _) bus_connection = nil end

Gio.bus_own_name(Gio.BusType.SESSION, "org.freedesktop.Notifications",
                 Gio.BusNameOwnerFlags.NONE, GObject.Closure(on_bus_acquire),
                 GObject.Closure(on_name_acquired),
                 GObject.Closure(on_name_lost))

dbus._notif_methods = notif_methods

local function remove_capability(cap)
    for k, v in ipairs(capabilities) do
        if v == cap then
            table.remove(capabilities, k)
            break
        end
    end
end

naughty.connect_signal("property::persistence_enabled", function()
    remove_capability("persistence")

    if naughty.persistence_enabled then
        table.insert(capabilities, "persistence")
    end
end)
naughty.connect_signal("property::image_animations_enabled", function()
    remove_capability("icon-multi")
    remove_capability("icon-static")

    table.insert(capabilities,
                 naughty.persistence_enabled and "icon-multi" or "icon-static")
end)

dbus._capabilities = capabilities

return dbus

