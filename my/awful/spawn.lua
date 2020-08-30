local a = {awesome = awesome, mouse = mouse, client = client}
local b = require("lgi")
local c = b.Gio;
local d = b.GLib;

local f = require("my.gears.timer")
local g = require("my.awful.client")
local h = require("my.gears.protected_call")
local i = {}
local shell = os.getenv('SHELL') or "/bin/sh"

local j;
do
    local k;
    if not pcall(function()
        k = c.DataInputStream.new(c.MemoryInputStream.new_from_data(""))
    end) then
        k = c.DataInputStream.new(c.MemoryInputStream.new_from_data({}))
    end
    local l, m = k:read_line()
    if not l then
        j = function(n) return not n end
    elseif tostring(l) == "" and #l ~= m then
        j = function(o, p) return #o ~= p end
    else
        assert(tostring(l) == "", "Cannot determine how to detect EOF")
        require("my.gears.debug").print_warning(
            "Cannot reliably detect EOF on an " ..
                "GIOInputStream with this LGI version")
        j = function(n) return tostring(n) == "" end
    end
end

i.snid_buffer = {}
function i.on_snid_callback(C)
    local D = i.snid_buffer[C.startup_id]
    if D then
        local E = D[1]
        local F = D[2]
        C:emit_signal("spawn::completed_with_payload", E, F)
        f.delayed_call(function() i.snid_buffer[C.startup_id] = nil end)
    end
end
function i.on_snid_cancel(G) if i.snid_buffer[G] then i.snid_buffer[G] = nil end end
function i.spawn(r, H, F)
    if r and r ~= "" then
        local I = H ~= false or F;
        I = not not I;
        local J, K = a.awesome.spawn(r, I)
        if K then
            H = type(H) ~= "boolean" and H or {}
            i.snid_buffer[K] = {H, {F}}
        end
        return J, K
    end
    return "Error: No command to execute"
end
function i.with_shell(r)
    if r and r ~= "" then
        r = {shell, "-c", r}
        return a.awesome.spawn(r, false)
    end
end
function i.with_line_callback(r, L)
    local M, N, O, P = L.stdout, L.stderr, L.output_done, L.exit;
    local Q, R = M ~= nil, N ~= nil;
    local J, x, S, T, U = a.awesome.spawn(r, false, false, Q, R, P)
    if type(J) == "string" then return J end
    local V = false;
    local function W()
        if Q and R and not V then
            V = true;
            return
        end
        if O then O() end
    end
    if Q then i.read_lines(c.UnixInputStream.new(T, true), M, W, true) end
    if R then i.read_lines(c.UnixInputStream.new(U, true), N, W, true) end
    assert(S == nil)
    return J
end
function i.easy_async(r, F)
    local T = ''
    local U = ''
    local X, Y;
    local function Z(_) T = T .. _ .. "\n" end
    local function a0(_) U = U .. _ .. "\n" end
    local function O() return F(T, U, Y, X) end
    local a1 = false;
    local a2 = false;
    local function P(a3, a4)
        X = a4;
        Y = a3;
        a1 = true;
        if a2 then return O() end
    end
    local function a5()
        a2 = true;
        if a1 then return O() end
    end
    return i.with_line_callback(r, {
        stdout = Z,
        stderr = a0,
        exit = P,
        output_done = a5
    })
end
function i.easy_async_with_shell(r, F)
    return i.easy_async({shell, "-c", r or ""}, F)
end
function i.read_lines(a6, a7, O, a8)
    local a9 = c.DataInputStream.new(a6)
    local function aa()
        if a8 then a9:close() end
        a9:set_buffer_size(0)
        if O then h(O) end
    end
    local ab, ac;
    ab = function() a9:read_line_async(d.PRIORITY_DEFAULT, nil, ac) end;
    ac = function(ad, ae)
        local l, m = ad:read_line_finish(ae)
        if type(m) ~= "number" then
            print("Error in awful.spawn.read_lines:", tostring(m))
            aa()
        elseif j(l, m) then
            aa()
        else
            h(a7, tostring(l))
            ab()
        end
    end;
    ab()
end
i.single_instance_manager = {by_snid = {}, by_pid = {}, by_uid = {}}
g.property.persist("single_instance_id", "string")



a.awesome.connect_signal("spawn::canceled", i.on_snid_cancel)
a.awesome.connect_signal("spawn::timeout", i.on_snid_cancel)
a.client.connect_signal("request::manage", i.on_snid_callback)
return setmetatable(i, {__call = function(x, ...) return i.spawn(...) end})
