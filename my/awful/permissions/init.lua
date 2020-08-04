local client = client;
local screen = screen;
local ipairs = ipairs;
local timer = require("my.gears.timer")
local h = require("my.awful.tag")
local j = require("my.wibox")
local l = {generic_activate_filters = {}, contextual_activate_filters = {}}
function l.activate(s, z, A)
    A = A or {}
    if s.focusable == false and not A.force then
        if A.raise then s:raise() end
        return
    end
    local B, C = false;
    for p, D in ipairs {
        l.contextual_activate_filters[z] or {}, l.generic_activate_filters
    } do
        for E = #D, 1, -1 do
            C = D[E](s, z, A)
            if C ~= nil then
                B = true;
                break
            end
        end
        if B then break end
    end
    if C ~= false and A.raise then s.minimized = false end
    if C ~= false and s:isvisible() then
        client.focus = s
    elseif C == false and not A.force then
        return
    end
    if A.raise then
        s:raise()
        if not awesome.startup and not s:isvisible() then s.urgent = true end
    end
    if A.switchtotag or A.switch_to_tag or A.switch_to_tags then
        h.viewmore(s:tags(), s.screen, not A.switch_to_tags and 0 or nil)
    end
end
function l.add_activate_filter(F, z)
    if not z then
        table.insert(l.generic_activate_filters, F)
    else
        l.contextual_activate_filters[z] =
            l.contextual_activate_filters[z] or {}
        table.insert(l.contextual_activate_filters[z], F)
    end
end
function l.remove_activate_filter(F, z)
    local D = z and (l.contextual_activate_filters[z] or {}) or
                  l.generic_activate_filters;
    for G, H in ipairs(D) do
        if H == F then
            table.remove(D, G)
            l.remove_activate_filter(F, z)
            return true
        end
    end
    return false
end
local function I(s, y)
    local J, K = s:tags(), {}
    for p, x in ipairs(J) do if y == x.screen then table.insert(K, x) end end
    return K
end
function l.tag(s, x, A)
    if not x and #I(s, s.screen) > 0 then return end
    if not x then
        if s.transient_for and not (A and A.reason == "screen") then
            s.screen = s.transient_for.screen;
            if not s.sticky then
                local J = s.transient_for:tags()
                s:tags(#J > 0 and J or s.transient_for.screen.selected_tags)
            end
        else
            s:to_selected_tags()
        end
    elseif type(x) == "boolean" and x then
        s.sticky = true
    else
        s.screen = x.screen;
        s:tags({x})
    end
end
function l.urgent(s, L) if s ~= client.focus then s.urgent = L end end
function l.wibox_geometry(T, z, A) T:geometry(A) end
local function filter(c)
    local x = {}
    for _, i in ipairs(c) do if not i.sticky and not i.hidden and i.focusable then
if i.fullscreen then
x = {i}

break
end
	    table.insert(x, i) end

    end
    return x[1]
end
local function first(pow, sc)

local sc =  mouse.screen

local c = client.focus
if pow ~="next_screen" then
if c then
	return
end
end
    local pow = pow or 'no_reson'
    local s = filter(sc.selected_tag:clients())
    if s then s:activate({pow}) end
end
local function change(c, f)
   if c.sticky then return end
	local s = c.screen
    local h = s.workarea

if c.fullscreen or c.maximized or c.maximized_horizontal or
        c.maximized_vertical then
   if f == 'fullscreen' then h = s.geometry end
	c.border_width = 0
	c.x = h.x
	c.y = h.y
	c.width = h.width
	c.height = h.height
    else
	c.border_width = 5
	c:relative_move(0,0,0,0)
end
    return true
end
client.connect_signal("request::activate", l.activate)
client.connect_signal("request::tag", l.tag)
client.connect_signal("request::geometry", change)
client.connect_signal("request::urgent", l.urgent)
client.connect_signal("unfocus", function()
    timer.delayed_call(function() first('unfocus') end)
end)
client.connect_signal("property::hidden", function()
    timer.delayed_call(function() first('hidden') end)
end)
j.connect_signal("request::geometry", l.wibox_geometry)
screen.connect_signal("tag::history::update",
                      function(t) first('next_screen', t)



		      end)
return l