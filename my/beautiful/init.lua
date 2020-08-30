local os = os
local pairs = pairs
local type = type
local dofile = dofile
local setmetatable = setmetatable
local lgi = require("lgi")
local Pango = lgi.Pango
local PangoCairo = lgi.PangoCairo
local gears_debug = require("my.gears.debug")
local Gio = require("lgi").Gio
local protected_call = require("my.gears.protected_call")

local xresources = require("my.beautiful.xresources")
local theme_assets = require("my.beautiful.theme_assets")

local beautiful = {
    xresources = xresources,
    theme_assets = theme_assets,

    mt = {}
}

local theme = {}
local descs = setmetatable({}, {__mode = 'k'})
local fonts = setmetatable({}, {__mode = 'v'})
local active_font

local function load_font(name)
    name = name or active_font
    if name and type(name) ~= "string" then
        if descs[name] then
            name = descs[name]
        else
            name = name:to_string()
        end
    end
    if fonts[name] then return fonts[name] end

    local desc = Pango.FontDescription.from_string(name)
    local ctx = PangoCairo.font_map_get_default():create_context()
    ctx:set_resolution(beautiful.xresources.get_dpi())

    desc:merge(ctx:get_font_description(), false)

    local metrics = ctx:get_metrics(desc, nil)
    local height = math.ceil((metrics:get_ascent() + metrics:get_descent()) /
                                 Pango.SCALE)
    if height == 0 then
        height = desc:get_size() / Pango.SCALE
        gears_debug.print_warning(string.format(
                                      "my.beautiful.load_font: could not get height for '%s' (likely missing font), using %d.",
                                      name, height))
    end

    local font = {name = name, description = desc, height = height}
    fonts[name] = font
    descs[desc] = name
    return font
end

local function set_font(name) active_font = load_font(name).name end

function beautiful.get_font(name) return load_font(name).description end

function beautiful.get_merged_font(name, merge)
    local font = beautiful.get_font(name)
    merge = Pango.FontDescription.from_string(merge)
    local merged = font:copy_static()
    merged:merge(merge, true)
    return beautiful.get_font(merged:to_string())
end

function beautiful.get_font_height(name) return load_font(name).height end

function beautiful.init(config)
    if config then
        local state, t_theme = nil, nil
        local homedir = os.getenv("HOME")

        local t_config = type(config)
        if t_config == 'string' then

            config = config:gsub("^~/", homedir .. "/")
            local dir = Gio.File.new_for_path(config):get_parent()
            rawset(beautiful, "theme_path",
                   dir and (dir:get_path() .. "/") or nil)
            theme = protected_call(dofile, config)
            t_theme = type(theme)
            state = t_theme == 'table' and next(theme)
        elseif t_config == 'table' then
            rawset(beautiful, "theme_path", nil)
            theme = config
            state = next(theme)
        end

        if state then

            if homedir then
                for k, v in pairs(theme) do
                    if type(v) == "string" then
                        theme[k] = v:gsub("^~/", homedir .. "/")
                    end
                end
            end

            if theme.font then set_font(theme.font) end
            return true
        else
            rawset(beautiful, "theme_path", nil)
            theme = {}
            local file = t_config == 'string' and (" from: " .. config)
            local err = (file and t_theme == 'table' and "got an empty table" ..
                            file) or
                            (file and t_theme ~= 'table' and "got a " .. t_theme ..
                                file) or
                            (t_config == 'table' and "got an empty table") or
                            ("got a " .. t_config)
            return gears_debug.print_error(
                       "my.beautiful: error loading theme: " .. err)
        end
    else
        return gears_debug.print_error(
                   "my.beautiful: error loading theme: no theme specified")
    end
end

function beautiful.get() return theme end

function beautiful.mt:__index(k) return theme[k] end

function beautiful.mt:__newindex(k, v) theme[k] = v end

set_font("sans 8")

return setmetatable(beautiful, beautiful.mt)

