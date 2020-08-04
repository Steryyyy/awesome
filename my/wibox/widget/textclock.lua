local setmetatable = setmetatable;
local os = os;
local a = require("my.wibox.widget.textbox")
local b = require("my.gears.timer")
local c = require("my.gears.table")
local d = require("lgi").GLib;
local e = d.DateTime;
local f = d.TimeZone;
local g = {mt = {}}
local h = e.new_now;
local i = tonumber(os.getenv("SOURCE_DATE_EPOCH"))
if i and os.getenv("SOURCE_DIRECTORY") then
    h = function() return e.new_from_unix_utc(i) end
end
function g:set_format(j)
    self._private.format = j;
    self:force_update()
end
function g:get_format() return self._private.format end
function g:set_timezone(k)
    self._private.tzid = k;
    self._private.timezone = k and f.new(k)
    self:force_update()
end
function g:get_timezone() return self._private.tzid end
function g:set_refresh(l)
    self._private.refresh = l or self._private.refresh;
    self:force_update()
end
function g:get_refresh() return self._private.refresh end
function g:force_update() self._timer:emit_signal("timeout") end
local function m(n) return n - os.time() % n end
local function o(j, l, k)
    local p = a()
    c.crush(p, g, true)
    p._private.format = j or " %a %b %d, %H:%M "
    p._private.refresh = l or 60;
    p._private.tzid = k;
    p._private.timezone = k and f.new(k)
    function p._private.textclock_update_cb()
        local q = h(p._private.timezone or f.new_local()):format(
                      p._private.format)
        if q == nil then
            require("my.gears.debug").print_warning(
                "textclock: " .. "g_date_time_format() failed for format " ..
                    "'" .. p._private.format .. "'")
        end
        p:set_markup(q)
        p._timer.timeout = m(p._private.refresh)
        p._timer:again()
        return true
    end
    p._timer = b.weak_start_new(l, p._private.textclock_update_cb)
    p:force_update()
    return p
end
function g.mt:__call(...) return o(...) end
return setmetatable(g, g.mt)
