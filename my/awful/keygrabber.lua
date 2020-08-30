local ipairs = ipairs;
local table = table;
local a = require('my.gears.debug')
local b = require("my.awful.key")
local unpack = unpack or table.unpack;
local c = require("my.gears.table")
local d = require("my.gears.object")
local e = require("my.gears.timer")
local f = require("my.awful.keyboard")
local g = require("lgi").GLib;
local h = {keygrabber = keygrabber, root = root, awesome = awesome}
local i = {}
local j = {}
local k = false;
local keygrabber = {object = {}}
local l = nil;
local function m()
    if l then return l end
    local n = h.awesome._modifiers;
    assert(n)
    l = {}
    for o, p in pairs(n) do
        for q, r in ipairs(p) do
            assert(r.keysym)
            l[r.keysym] = o
        end
    end
    return l
end
h.awesome.connect_signal("xkb::map_changed", function() l = nil end)

local function x(o, y, z)
    for q, A in ipairs(j) do if A(o, y, z) ~= false then break end end
end
local function B(self, C, y, z)
    local D = m()[y]
    if (y == self.stop_key or D and D == self.stop_key) and z == self.stop_event and
        self.stop_key then
        self:stop(y, C)
        return false
    end
    if self._private.allowed_keys and not self._private.allowed_keys[y] then
        self:stop(y, C)
        return false
    end
    if type(self.stop_key) == "table" and z == self.stop_event then
        for q, E in ipairs(self.stop_key) do
            if E == y then
                self:stop(E, C)
                return false
            end
        end
    end
    local F = D ~= nil;
    if self._private.timer and self._private.timer.started then
        self._private.timer:again()
    end
    local G = g.utf8_strlen(self.sequence, -1)
    if y == "BackSpace" and G > 0 and z == "release" then
        self.sequence = g.utf8_substring(self.sequence, 0, G - 1)
    elseif g.utf8_strlen(y, -1) == 1 and z == "release" then
        self.sequence = self.sequence .. y
    end
    local o = {}
    for q, H in ipairs(C) do o[H] = true end
    self:emit_signal(y .. "::" .. z, C, o)
    local I = {}
    if self._private.keybindings[y] and z == "press" then
        for q, J in ipairs(C) do
            if not c.hasitem(b.ignore_modifiers, J) then
                table.insert(I, J)
            end
        end
        for q, H in ipairs(self._private.keybindings[y]) do
            if #I == #H.modifiers then
                local K = true;
                for q, L in ipairs(H.modifiers) do K = K and o[L] end
                if K and H.on_press then
                    H.on_press(self)
                    if self.mask_event_callback ~= false then
                        return
                    end
                end
            end
        end
    end
    if F and self.mask_modkeys then return end
    if self.keypressed_callback and z == "press" then
        self.keypressed_callback(self, C, y, z)
    elseif self.keyreleased_callback and z == "release" then
        self.keyreleased_callback(self, C, y, z)
    end
end
function i.stop(M)
    M = M or i.current_instance and i.current_instance.grabber or j[#j]
    for N, H in ipairs(j) do
        if H == M then
            table.remove(j, N)
            break
        end
    end
    if M and i.current_instance and i.current_instance.grabber == M then
        i.current_instance = nil
    end
    if #j == 0 then
        k = false;
        h.keygrabber.stop()
    end
end
function keygrabber:start()
    if self.grabber or i.current_instance then return false end
    self.current_instance = setmetatable({}, {
        __index = self,
        __newindex = function(O, y, P)
            if keygrabber["set_" .. y] then
                self[y](self, P)
            else
                rawset(O, y, P)
            end
        end
    })
    self.sequence = ""
    if self.start_callback then self.start_callback(self.current_instance) end
    self.grabber = i.run(function(...) return B(self, ...) end)
    if self.timeout and not self._private.timer then
        self._private.timer = e {
            timeout = self.timeout,
            single_shot = true,
            callback = function()
                if self.timeout_callback then
                    pcall(self.timeout_callback, self)
                end
                self:stop()
            end
        }
    end
    if self._private.timer then self._private.timer:start() end
    i.current_instance = self;
    i.emit_signal("property::current_instance", i.current_instance)
    self:emit_signal("started")
end
function keygrabber:stop(Q, R)
    i.stop(self.grabber)
    if self.stop_callback then
        self.stop_callback(self.current_instance, Q, R, self.sequence)
    end
    i.emit_signal("property::current_instance", nil)
    self.grabber = nil;
    self:emit_signal("stopped")
end


function keygrabber:set_allowed_keys(U)
    self._private.allowed_keys = {}
    for q, H in ipairs(U) do self._private.allowed_keys[H] = true end
end
function keygrabber:get_release_event() return self.stop_event end
function i.run_with_keybindings(_)
    _ = _ or {}
    local a0 = d {enable_properties = true, enable_auto_signals = true}
    rawset(a0, "_private", {})
    a0.sequence = ""
    c.crush(a0, keygrabber, true)
    c.crush(a0, _)
    a0._private.keybindings = {}
    a0.stop_event = _.stop_event or "press"
    for q, H in ipairs(_.keybindings or {}) do
        if H._is_awful_key then
            a0._private.keybindings[H.key] =
                a0._private.keybindings[H.key] or {}
            table.insert(a0._private.keybindings[H.key], H)
        elseif #H >= 3 and #H <= 4 then
            
            local C, y, a1 = unpack(H)
            if type(a1) == "function" then
                local E = b {modifiers = C, key = y, on_press = a1}
                a0._private.keybindings[y] = a0._private.keybindings[y] or {}
                table.insert(a0._private.keybindings[y], E)
            else
                a.print_warning(
                    "The hook's 3rd parameter has to be a function. " ..
                        a.dump(H or {}))
            end
        else
            a.print_warning("The keybindings should be awful.key objects" ..
                                a.dump(H or {}))
        end
    end
    if _.export_keybindings then a0:set_root_keybindings(_.keybindings) end
    local a2 = getmetatable(a0)
    function a2.__call() a0:start() end
    if _.autostart then a0:start() end
    return a0
end
function i.run(M)
    i.stop(M)
    table.insert(j, 1, M)
    if not k then
        k = true;
        h.keygrabber.run(x)
    end
    return M
end
local a3 = {}
function i.connect_signal(a4, a1)
    a3[a4] = a3[a4] or {}
    table.insert(a3[a4], a1)
end
function i.disconnect_signal(a4, a1)
    a3[a4] = a3[a4] or {}
    for E, H in ipairs(a3[a4]) do
        if H == a1 then
            table.remove(a3[a4], E)
            break
        end
    end
end
function i.emit_signal(a4, ...)
    a3[a4] = a3[a4] or {}
    for q, a5 in ipairs(a3[a4]) do a5(...) end
end
function i.get_is_running() return i.current_instance ~= nil end
return setmetatable(i, {
    __call = function(q, _) return i.run_with_keybindings(_) end
})
