
local capi = {
    screen = screen,
    client = client,
}
local awful = require("awful")
local gtable = require("gears.table")
local gstring = require("gears.string")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local keysbin = require('keybindings')
local tcolor = require('tools.colors')
local gears = require('gears')
-- Stripped copy of this module https://github.com/copycat-killer/lain/blob/master/util/markup.lua:
local markup = {}
-- Set the font.
function markup.font(font, text)
    return '<span font="'    .. tostring(font)    .. '">' .. tostring(text) ..'</span>'
end
-- Set the foreground.
function markup.fg(color, text)
    return '<span foreground="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end
-- Set the background.
function markup.bg(color, text)
    return '<span background="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end

local settings = {

    font = "Monospace Bold 9",
    label_fg = "#000000",
    bg = "#000000AA",
    height = dpi(800),
    width = dpi(1200),
    border_width = 1,
    modifiers_fg = "#dddddd",
    description_font = "Monospace 10",
}
local group_margin = dpi(6)
local ind = 1
local color_back = {}
local    function group_label(group, color)

    local textbox = wibox.widget{
        {
            text = group,
            align = 'center',
            font = settings.font,
            widget = wibox.widget.textbox,
        },
        fg = settings.label_fg,
        bg = tcolor.get_color(ind%4+1,'w'),
        widget = wibox.container.background

    }
    ind = ind +1
    table.insert(color_back,textbox)
    local margin = wibox.container.margin()
    margin:set_widget(textbox)
    margin:set_top(group_margin)
    return margin
end

local place_func = function(c)
    -- c.x = mouse.screen.geometry.x +  mouse.screen.geometry.width/2 - c.width/2
    c.screen = mouse.screen
    awful.placement.centered(c, {honor_workarea = true})
end
local mypopup = awful.popup {
    widget = wibox.widget.textbox("adwawd"),
    ontop = true,
    bg=settings.bg,
    fg="#ffffff",
    visible = false,

    border_width = beautiful.border_width,
    border_color = "#ffffff",
    placement = place_func,
    minimum_width = 1200,
    minimum_height = 800,
}

awesome.connect_signal('color_change', function()
    --ind = 1
    for i,a in pairs(color_back) do
        a.bg = tcolor.get_color(i%4+1,'w')
    end
mypopup.border_color = beautiful.border_color_active
end)

local function get_screen(s)
    return s and capi.screen[s]
end


local widget = {
    group_rules = {},
}

--- Don't show hotkeys without descriptions.
-- @tfield boolean widget.hide_without_description
-- @param boolean
widget.hide_without_description = true

widget.merge_duplicates = true
local cached_wiboxes = {}
local labels = {

    Control          = "Ctrl",
    Mod1             = "Alt",
    ISO_Level3_Shift = "Alt Gr",
    Mod4             = "Super",
    Insert           = "Ins",
    Delete           = "Del",
    Backspace        = "BackSpc",
    Next             = "PgDn",
    Prior            = "PgUp",
    Left             = "←",
    Up               = "↑",
    Right            = "→",
    Down             = "↓",
    KP_End           = "Num1",
    KP_Down          = "Num2",
    KP_Next          = "Num3",
    KP_Left          = "Num4",
    KP_Begin         = "Num5",
    KP_Right         = "Num6",
    KP_Home          = "Num7",
    KP_Up            = "Num8",
    KP_Prior         = "Num9",
    KP_Insert        = "Num0",
    KP_Delete        = "Num.",
    KP_Divide        = "Num/",
    KP_Multiply      = "Num*",
    KP_Subtract      = "Num-",
    KP_Add           = "Num+",
    KP_Enter         = "NumEnter",
    -- Some "obvious" entries are necessary for the Escape sequence
    -- and whitespace characters:
    Escape           = "Esc",
    Tab              = "Tab",
    space            = "Space",
    Return           = "Enter",
    -- Dead keys aren't distinct from non-dead keys because no sane
    -- layout should have both of the same kind:
    dead_circumflex  = "^",
    dead_grave       = "`",
    -- Basic multimedia keys:
    XF86MonBrightnessUp   = "🔆+",
    XF86MonBrightnessDown = "🔅-",
    XF86AudioRaiseVolume = "Vol+",
    XF86AudioLowerVolume = "Vol-",
    XF86AudioMute = "Mute",
    XF86AudioPlay = "⏯",
    XF86AudioPrev = "⏮",
    XF86AudioNext = "⏭",

}
local function labelsjoin(s)
    local whole = ''
    for _,a in  pairs(gears.string.split(tostring(s),'..')) do
        whole = whole .."..".. (labels[a] or a)

    end

    return whole:sub(3)
end


args = args or {}
local widget_instance = {
    hide_without_description = (
    args.hide_without_description == nil
    ) and widget.hide_without_description or args.hide_without_description,
    merge_duplicates = (
    args.merge_duplicates == nil
    ) and widget.merge_duplicates or args.merge_duplicates,
    group_rules = args.group_rules or gtable.clone(widget.group_rules),
    -- For every key in every `awful.key` binding, the first non-nil result
    -- in this lists is chosen as a human-readable name:
    -- * the value corresponding to its keysym in this table;
    -- * the UTF-8 representation as decided by awful.keyboard.get_key_name();
    -- * the keysym name itself;
    -- If no match is found, the key name will not be translated, and will
    -- be presented to the user as-is. (This is useful for cheatsheets for
    -- external programs.)
    _additional_hotkeys = {},
    _cached_wiboxes = {},
    _cached_awful_keys = {},
    _colors_counter = {},
    _group_list = {},
    _widget_settings_loaded = false,
    _keygroups = {},
}
--[[
for k, v in pairs(awful.key.keygroups) do
widget_instance._keygroups[k] = {}
for k2, v2 in pairs(v) do
local keysym, keyprint = awful.keyboard.get_key_name(v2[1])
widget_instance._keygroups[k][k2] =
widget_instance.labels[keysym] or keyprint or keysym or v2[1]
end
end
--]]

function _load_widget_settings()
    --[[
    if self._widget_settings_loaded then return end
    self.width = args.width or dpi(1200)
    self.height = args.height or dpi(800)
    self.bg = "#000000AA"

    self.fg = args.fg or
    beautiful.hotkeys_fg or beautiful.fg_normal
    self.border_width = args.border_width or
    beautiful.hotkeys_border_width or beautiful.border_width
    self.border_color = args.border_color or
    beautiful.hotkeys_border_color or self.fg
    self.shape = args.shape or beautiful.hotkeys_shape
    self.modifiers_fg = args.modifiers_fg or
    beautiful.hotkeys_modifiers_fg or beautiful.bg_minimize or "#555555"
    self.label_bg = args.label_bg or
    beautiful.hotkeys_label_bg or self.fg
    self.label_fg = args.label_fg or
    beautiful.hotkeys_label_fg or self.bg
    self.opacity = args.opacity or
    beautiful.hotkeys_opacity or 1
    self.font = args.font or
    beautiful.hotkeys_font or "Monospace Bold 9"
    self.description_font = args.description_font or
    beautiful.hotkeys_description_font or "Monospace 8"
    group_margin = args.group_margin or
    beautiful.hotkeys_group_margin or dpi(6)
    self.label_colors = beautiful.xresources.get_current_theme()
    self._widget_settings_loaded = true
    --]]
end


function _get_next_color(id)
    id = id or "default"
    if self._colors_counter[id] then
        self._colors_counter[id] = math.fmod(self._colors_counter[id] + 1, 15) + 1
    else
        self._colors_counter[id] = 1
    end
    return self.label_colors["color"..tostring(self._colors_counter[id], 15)]
end


--[[
function _add_hotkey(key, data, target)
if self.hide_without_description and not data.description then return end

local readable_mods = {}
for _, mod in ipairs(data.mod) do
table.insert(readable_mods, labels[mod] or mod)
end
local joined_mods = join_plus_sort(readable_mods)

local group = data.group or "none"
self._group_list[group] = true
if not target[group] then target[group] = {} end
local keysym, keyprint = awful.keyboard.get_key_name(key)
local keylabel = labels[keysym] or keyprint or keysym or key
local new_key = {
key = keylabel,
keylist = {keylabel},
mod = joined_mods,
description = data.description
}
local index = data.description or "none"  -- or use its hash?
if not target[group][index] then
target[group][index] = new_key
else
if self.merge_duplicates and joined_mods == target[group][index].mod then
target[group][index].key = target[group][index].key .. "/" .. new_key.key
table.insert(target[group][index].keylist, new_key.key)
else
while target[group][index] do
index = index .. " "
end
target[group][index] = new_key
end
end
end
--]]


--[[
function _sort_hotkeys(target)
for group, _ in pairs(self._group_list) do
if target[group] then
local sorted_table = {}
for _, key in pairs(target[group]) do
table.insert(sorted_table, key)
end
table.sort(
sorted_table,
function(a,b)
local k1, k2 = a.key or a.keys[1][1], b.key or b.keys[1][1]
return (a.mod or '')..k1<(b.mod or '')..k2 end
)
target[group] = sorted_table
end
end
end

--]]

--[[
function _abbreviate_awful_keys()
-- This method is intended to abbreviate the keys of a merged entry (not
-- the modifiers) if and only if the entry consists of five or more
-- correlative keys from the same keygroup.
--
-- For simplicity, it checks only the first keygroup which contains the
-- first key. If any of the keys in the merged entry is not in this
-- keygroup, or there are any gaps between the keys (e.g. the entry
-- contains the 2nd, 3rd, 5th, 6th, and 7th key in
-- awful.key.keygroups.numrow, but not the 4th) this method does not try
-- to abbreviate the entry.
--
-- Cheatsheets for external programs are abbreviated by hand where
-- applicable: they do not need this method.
for _, keys in pairs(self._cached_awful_keys) do
for _, params in pairs(keys) do
if #params.keylist > 4 then
-- assuming here keygroups will never overlap;
-- if they ever do, another for loop will be necessary:
local keygroup = gtable.find_first_key(self._keygroups, function(_, v)
return not not gtable.hasitem(v, params.keylist[1])
end)
local first, last, count, tally = nil, nil, 0, {}
for _, k in ipairs(params.keylist) do
local i = gtable.hasitem(self._keygroups[keygroup], k)
if i and not tally[i] then
tally[i] = k
if (not first) or (i < first) then first = i end
if (not last) or (i > last) then last = i end
count = count + 1
elseif not i then
count = 0
break
end
end
-- this conditional can only be true if there are more than
-- four actual keys (discounting duplicates) and ALL of
-- these keys can be found one after another in a keygroup:
if count > 4 and last - first + 1 == count then
params.key = tally[first] .. "…" .. tally[last]
end
end
end
end
end

--]]

--[[
function _import_awful_keys()
if next(self._cached_awful_keys) then
return
end
for _, data in pairs(awful.key.hotkeys) do
for _, key_pair in ipairs(data.keys) do
_add_hotkey(key_pair[1], data, self._cached_awful_keys)
end
end
_sort_hotkeys(self._cached_awful_keys)
if self.merge_duplicates then
_abbreviate_awful_keys()
end
end

--]]


function _create_group_columns(column_layouts, group, keys, s, wibox_height)
    local line_height = beautiful.get_font_height(settings.font)
    local group_label_height = line_height + group_margin
    -- -1 for possible pagination:
    local max_height_px = wibox_height - group_label_height


    -- +1 for group label:
    local items_height = #keys * line_height + group_label_height
    local current_column
    local available_height_px = max_height_px
    local add_new_column = true
    for i, column in ipairs(column_layouts) do
        if ((column.height_px + items_height) < max_height_px) or
            (i == #column_layouts and column.height_px < max_height_px / 2)
            then
                current_column = column
                add_new_column = false
                available_height_px = max_height_px - current_column.height_px
                break
            end
        end
        local overlap_leftovers
        if items_height > available_height_px then
            local new_keys = {}
            overlap_leftovers = {}
            -- +1 for group title and +1 for possible hyphen (v):
            local available_height_items = (available_height_px - group_label_height*2) / line_height
            for i=1,#keys do
                table.insert(((i<available_height_items) and new_keys or overlap_leftovers), keys[i])
            end
            keys = new_keys
            table.insert(keys, {key=markup.fg(settings.modifiers_fg, "▽"), description=""})
        end
        if not current_column then
            current_column = {layout=wibox.layout.fixed.vertical()}
        end
        current_column.layout:add(group_label(group))
        local ie = 1
        local function insert_keys(_keys, _add_new_column)
            local max_label_width = 0
            local max_label_content = ""
            local joined_labels = ""
            for i, key in ipairs(_keys) do
                local length = string.len(key[2] or '') + string.len(key[3] and key[3].description or '')
                local modifiers = key.mod or ""
                for _,a in ipairs(key[1])do
                    modifiers = (labels[a] or a) .."+" .. modifiers
                end
                if not modifiers or modifiers == "none" then
                    modifiers = ""
                else
                    length = length + string.len(modifiers)  -- +1 for "+" character
                    modifiers = markup.fg(settings.modifiers_fg, modifiers)
                end
                local rendered_hotkey = markup.font(settings.font,
                modifiers .. ((key[2] and  labelsjoin(key[2]) or key[2]) or "") .. " "
                ) .. markup.font(settings.description_font,
                key[3] and key[3].description or ""
                )
                if length > max_label_width then
                    max_label_width = length
                    max_label_content = rendered_hotkey
                end
                joined_labels = joined_labels .. rendered_hotkey .. (i~=#_keys and "\n" or "")
                ie = ie +1
            end
            current_column.layout:add(wibox.widget{markup = joined_labels,align = 'center',widget = wibox.widget.textbox})
            local max_width, _ = wibox.widget.textbox(max_label_content):get_preferred_size(s)
            max_width = max_width + group_margin
            if not current_column.max_width or max_width > current_column.max_width then
                current_column.max_width = max_width
            end
            -- +1 for group label:
            current_column.height_px = (current_column.height_px or 0) +
            gstring.linecount(joined_labels)*line_height + group_label_height
            if _add_new_column then
                table.insert(column_layouts, current_column)
            end
        end

        insert_keys(keys, add_new_column)
        if overlap_leftovers then
            current_column = {layout=wibox.layout.fixed.vertical()}
            insert_keys(overlap_leftovers, true)
        end
    end

    function _create_wibox(s, available_groups)
        s = mouse.screen or get_screen(s)
        local wa = s.workarea
        local wibox_height = (settings.height < wa.height) and settings.height or
        (wa.height - settings.border_width * 2)
        local wibox_width = (settings.width < wa.width) and settings.width or
        (wa.width - settings.border_width * 2)

        -- arrange hotkey groups into columns
        local column_layouts = {}
        for _, k in ipairs(available_groups) do

            if #k > 0 then
                _create_group_columns(column_layouts, (k[1] and k[1][3] and k[1][3].group) or "nul", k, s, wibox_height)
            end
        end
        available_groups = nil
        -- arrange columns into pages
        local available_width_px = wibox_width
        local pages = {}
        local columns = wibox.layout.fixed.horizontal()
        local previous_page_last_layout
        for i, item in ipairs(column_layouts) do
            if item.max_width > available_width_px then
                previous_page_last_layout:add(
                group_label("PgDn - Next Page", settings.bg)
                )
                table.insert(pages, columns)
                columns = wibox.layout.fixed.horizontal()
                available_width_px = wibox_width - item.max_width
                item.layout:insert(
                1, group_label("PgUp - Prev Page", settings.bg)
                )
            else
                available_width_px = available_width_px - item.max_width
            end
            local column_margin = wibox.container.margin()
            column_margin:set_widget(item.layout)
            column_margin:set_left(group_margin)
            columns:add(column_margin)
            previous_page_last_layout = item.layout
        end
        table.insert(pages, columns)

        -- Function to place the widget in the center and account for the
        -- workarea. This will be called in the placement field of the
        -- awful.popup constructor.

        -- Construct the popup with the widget

        local widget_obj = {
            current_page = 1,
            popup = mypopup,
        }

        -- Set up the mouse buttons to hide the popup
        -- Any keybinding except what the keygrabber wants wil hide the popup
        -- too
        mypopup.buttons = {
            awful.button({ }, 1, function () widget_obj:hide() end),
            awful.button({ }, 3, function () widget_obj:hide() end)
        }

        function widget_obj.page_next(_self)
            if _self.current_page == #pages then return end
            _self.current_page = _self.current_page + 1
            _self.popup:set_widget(pages[_self.current_page])
        end
        function widget_obj.page_prev(_self)
            if _self.current_page == 1 then return end
            _self.current_page = _self.current_page - 1
            _self.popup:set_widget(pages[_self.current_page])
        end
        function widget_obj.show(_self)
            _self.popup.visible = true
            place_func(_self.popup)
            _self.popup:set_widget(pages[1])
        end
        function widget_obj.hide(_self)
            _self.popup.visible = false
            if _self.keygrabber then
                awful.keygrabber.stop(_self.keygrabber)
            end
        end

        return widget_obj
    end


    --- Show popup with hotkeys help.
    -- @tparam[opt] client c Client.
    -- @tparam[opt] screen s Screen.
    -- @tparam[opt] table show_args Additional arguments.
    -- @tparam[opt=true] boolean show_args.show_awesome_keys Show AwesomeWM hotkeys.
    -- When set to `false` only app-specific hotkeys will be shown.
    -- @method show_help
    function add_cache(name,array)

        if not cached_wiboxes[name] then
            local s = mouse.screen
            local avilable = {nul = {}}
            for _,a in ipairs(array)do
                if a[3] and a[3].group then
                    if not avilable[a[3].group] then
                        avilable[a[3].group] = {a}
                    else
                        table.insert(avilable[a[3].group],a)
                    end

                else
                    table.insert(avilable.nul,a)
                end

            end
            local tab = {}
            for _,a in pairs(avilable) do
                table.insert(tab,a)
            end
            table.sort(tab,function(a,b) return  (a[1] and a[1][3] and a[1][3].group or "nul") < (b[1] and b[1][3] and b[1][3].group or "nul")  end)
            avilable = nil
            cached_wiboxes[name] = _create_wibox(s, tab)
        end

    end

    function widget.show_help( to_show)
        _load_widget_settings()

        if not cached_wiboxes[to_show] then
            return
        end
        local help_wibox = cached_wiboxes[to_show]
        help_wibox:show()

        help_wibox.keygrabber = awful.keygrabber.run(function(_, key, event)
            if event == "release" then return end
            if key then
                if key == "Next" then
                    help_wibox:page_next()
                elseif key == "Prior" then
                    help_wibox:page_prev()
                else
                    help_wibox:hide()
                end
            end
        end)
        return help_wibox.keygrabber
    end


    function widget.init()
        add_cache("global",keysbin.globals)
        add_cache("wallpaper",keysbin.wallpaper_keys)
        add_cache("startmenu",keysbin.startmenu_keys)
        add_cache("volume",keysbin.volume_keys)


    end

    return widget






