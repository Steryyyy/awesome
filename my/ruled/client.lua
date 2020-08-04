local capi = {client = client, awesome = awesome, screen = screen, tag = tag}
local table = table
local type = type
local ipairs = ipairs
local pairs = pairs
local atag = require("my.awful.tag")
local gobject = require("my.gears.object")
local gtable = require("my.gears.table")

local protected_call = require("my.gears.protected_call")
local aspawn = require("my.awful.spawn")
local gdebug = require("my.gears.debug")
local gmatcher = require("my.gears.matcher")
local amouse = require("my.awful.mouse")
local akeyboard = require("my.awful.keyboard")
local unpack = unpack or table.unpack

local module = {}

local crules = gmatcher()

function module.match(c, rule) return crules:_match(c, rule) end

function module.match_any(c, rule) return crules:_match_any(c, rule) end

function module.matches(c, entry) return crules:matches_rule(c, entry) end

function module.matching_rules(c, _rules) return
    crules:matching_rules(c, _rules) end

function module.matches_list(c, _rules) return crules:matches_rules(c, _rules) end

function module.remove_rule_source(name)
    return crules:remove_matching_source(name)
end

function module.apply(c) return crules:apply(c) end

function module.append_rule(rule) crules:append_rule("my.awful.rules", rule) end

function module.append_rules(rules) crules:append_rules("my.awful.rules", rules) end

function module.remove_rule(rule) crules:remove_rule("my.awful.rules", rule) end

function module.add_rule_source(name, cb, ...)
    local function callback(_, ...) cb(...) end
    return crules:add_matching_function(name, callback, ...)
end

crules:add_matching_rules("my.awful.rules", {}, {"my.awful.spawn"}, {})

local function apply_spawn_rules(c, props, callbacks)
    if c.startup_id and aspawn.snid_buffer[c.startup_id] then
        local snprops, sncb = unpack(aspawn.snid_buffer[c.startup_id])

        if snprops.tag or snprops.tags or snprops.new_tag then
            props.tag, props.tags, props.new_tag = nil, nil, nil
        end

        gtable.crush(props, snprops)
        gtable.merge(callbacks, sncb)
    end
end

module.add_rule_source("my.awful.spawn", apply_spawn_rules, {},
                       {"my.awful.rules"})

local function apply_singleton_rules(c, props, callbacks)
    local persis_id, info = c.single_instance_id, nil

    if capi.awesome.startup and persis_id then
        info = aspawn.single_instance_manager.by_uid[persis_id]
    elseif c.startup_id then
        info = aspawn.single_instance_manager.by_snid[c.startup_id]
        aspawn.single_instance_manager.by_snid[c.startup_id] = nil
    elseif aspawn.single_instance_manager.by_pid[c.pid] then
        info = aspawn.single_instance_manager.by_pid[c.pid].matcher(c) and
                   aspawn.single_instance_manager.by_pid[c.pid] or nil
    end

    if info then
        c.single_instance_id = info.hash
        if info.rules then gtable.crush(props, info.rules) end
        table.insert(callbacks, info.callback)
        table.insert(info.instances, c)

        aspawn.single_instance_manager.by_pid[c.pid] = nil
    end
end

module.add_rule_source("my.awful.spawn_once", apply_singleton_rules,
                       {"my.awful.spawn"}, {"my.awful.rules"})

local function add_to_tag(c, t)
    if not t then return end

    local tags = c:tags()
    table.insert(tags, t)
    c:tags(tags)
end

module.extra_properties = {}

module.high_priority_properties = {}

module.delayed_properties = {}

local force_ignore = {

    focus = true,
    screen = true,
    x = true,
    y = true,
    width = true,
    height = true,
    geometry = true,
 
    border_width = true,
    floating = true,
    size_hints_honor = false
}

function module.high_priority_properties.tag(c, value, props)
    if value then
        if type(value) == "string" then
            local name = value
            value = atag.find_by_name(c.screen, value)
            if not value and not props.screen then
                value = atag.find_by_name(nil, name)
            end
            if not value then
                gdebug.print_error("my.ruled.client-rule specified " ..
                                       "tag = '" .. name ..
                                       "', but no such tag exists")
                return
            end
        end

        if c.screen ~= value.screen then
            c.screen = value.screen
            props.screen = value.screen
        end

        c:tags{value}
    end
end

function module.delayed_properties.switch_to_tags(c, value)
    if not value then return end
    atag.viewmore(c:tags(), c.screen)
end



function module.extra_properties.geometry(c, _, props)
    local cur_geo = c:geometry()

    local new_geo = type(props.geometry) == "function" and
                        props.geometry(c, props) or props.geometry or {}

    for _, v in ipairs {"x", "y", "width", "height"} do
        new_geo[v] = type(props[v]) == "function" and props[v](c, props) or
                         props[v] or new_geo[v] or cur_geo[v]
    end

    c:geometry(new_geo)
end

function module.high_priority_properties.new_tag(c, value, props)
    local ty = type(value)
    local t = nil

    if ty == "boolean" then

        t = atag.add(c.class or "N/A", {screen = c.screen, volatile = true})
    elseif ty == "string" then

        t = atag.add(value, {screen = c.screen, volatile = true})
    elseif ty == "table" then

        local values = value.screen and value or gtable.clone(value)
        values.screen = values.screen or c.screen

        t = atag.add(value.name or c.class or "N/A", values)

        c.screen = t.screen
        props.screen = t.screen
    else
        assert(false)
    end

    add_to_tag(c, t)

    return t
end



function module.high_priority_properties.tags(c, value, props)
    local current = c:tags()

    local tags, s = {}, nil

    for _, t in ipairs(value) do
        if type(t) == "string" then t = atag.find_by_name(c.screen, t) end

        if t and ((not s) or t.screen == s) then
            table.insert(tags, t)
            s = s or t.screen
        end
    end

    if s and s ~= c.screen then
        c.screen = s
        props.screen = s
    end

    if #current == 0 or (value[1] and value[1].screen ~= current[1].screen) then
        c:tags(tags)
    else
        c:tags(gtable.merge(current, tags))
    end
end

crules._execute = function(_, c, props, callbacks)

    local btns = amouse._get_client_mousebindings()
    local keys = akeyboard._get_client_keybindings()
    props.keys = props.keys or keys
    props.buttons = props.buttons or btns

    if props.border_width then
        c.border_width = type(props.border_width) == "function" and
                             props.border_width(c, props) or props.border_width
    end

  

    if props.size_hints_honor ~= nil then
        c.size_hints_honor = type(props.size_hints_honor) == "function" and
                                 props.size_hints_honor(c, props) or
                                 props.size_hints_honor
    end

    if props.floating ~= nil then
        c.floating = type(props.floating) == "function" and
                         props.floating(c, props) or props.floating
    end

    if props.screen then
        c.screen = type(props.screen) == "function" and
                       capi.screen[props.screen(c, props)] or
                       capi.screen[props.screen]
    end

    for prop, handler in pairs(module.high_priority_properties) do
        local value = props[prop]
        if value ~= nil then
            if type(value) == "function" then value = value(c, props) end
            handler(c, value, props)
        end
    end

    c:emit_signal("request::tag", nil, {reason = "rules", screen = c.screen})


    if props.height or props.width or props.x or props.y or props.geometry then
        module.extra_properties.geometry(c, nil, props)
    end

    for property, value in pairs(props) do
        if property ~= "focus" and property ~= "shape" and type(value) ==
            "function" then value = value(c, props) end

        local ignore = module.high_priority_properties[property] or
                           module.delayed_properties[property] or
                           force_ignore[property]

        if not ignore then
            if module.extra_properties[property] then
                module.extra_properties[property](c, value, props)
            elseif type(c[property]) == "function" then
                c[property](c, value)
            else
                c[property] = value
            end
        end
    end

    if callbacks then
        for _, callback in pairs(callbacks) do
            protected_call(callback, c)
        end
    end

    for prop, handler in pairs(module.delayed_properties) do
        if not force_ignore[prop] then
            local value = props[prop]
            if value ~= nil then
                if type(value) == "function" then
                    value = value(c, props)
                end
                handler(c, value, props)
            end
        end
    end

    if props.focus and (type(props.focus) ~= "function" or props.focus(c)) then
        c:emit_signal('request::activate', "rules",
                      {raise = not capi.awesome.startup})
    end
end

function module.execute(...) crules:_execute(...) end

function module.completed_with_payload_callback(c, props, callbacks)
    module.execute(c, props, callbacks)
end

gobject._setup_class_signals(module)

capi.client.connect_signal("request::manage", module.apply)

local function request_rules() module.emit_signal("request::rules") end

capi.client.connect_signal("scanning", request_rules)

return setmetatable(module, {
    __newindex = function(_, k, v)
        if k == "rules" then


            if not next(v) then

                for k2 in pairs(crules._matching_rules["my.awful.rules"]) do
                    crules._matching_rules["my.awful.rules"][k2] = nil
                end
            else
                crules:append_rules("my.awful.rules", v)
            end
        else
            rawset(k, v)
        end
    end,
    __index = function(_, k)
        if k == "rules" then
         

            if not crules._matching_rules["my.awful.rules"] then
                crules:add_matching_rules("my.awful.rules", {}, {}, {})
            end

            return crules._matching_rules["my.awful.rules"]
        end
    end
})

