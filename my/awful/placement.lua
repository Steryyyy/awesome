local ipairs = ipairs
local pairs = pairs
local math = math
local table = table
local capi = {screen = screen, mouse = mouse, client = client}
local floating = require("my.awful.layout.suit.floating")
local a_screen = require("my.awful.screen")
local grect = require("my.gears.geometry").rectangle

local gtable = require("my.gears.table")
local cairo = require("lgi").cairo
local unpack = unpack or table.unpack

local function get_screen(s) return s and capi.screen[s] end

local wrap_client = nil
local placement

local reverse_align_map = {}

local area_common
local wibox_update_strut
local attach

local function compose(...)
    local queue = {}

    local nodes = {...}

    if not nodes[2] then return nodes[1] end

    for _, w in ipairs(nodes) do

        if w.context and w.context == "compose" then
            for _, elem in ipairs(w.queue or {}) do
                table.insert(queue, elem)
            end
        else
            table.insert(queue, w)
        end
    end

    local ret
    ret = wrap_client(function(d, args, ...)
        local rets = {}
        local last_geo = nil

        args = setmetatable({composition_results = rets}, {__index = args})

        local attach_real = args.attach
        args.pretend = true
        args.attach = false
        args.offset = {}

        for k, f in ipairs(queue) do
            if k == #queue then

                args.pretend = nil
                args.offset = nil
            end

            local r = {f(d, args, ...)}
            last_geo = r[1] or last_geo
            args.override_geometry = last_geo

            if f.context then

                if f.context == "compose" then
                    for k2, v in pairs(r) do rets[k2] = v end
                else
                    rets[f.context] = r
                end
            end
        end

        if attach_real then
            args.attach = true
            attach(d, ret, args)
        end

        return last_geo, rets
    end, "compose")

    ret.queue = queue

    return ret
end

wrap_client = function(f, context)
    return setmetatable({is_placement = true, context = context}, {
        __call = function(_, ...) return f(...) end,
        __add = compose,
        __mul = compose
    })
end

local placement_private = {}

placement = setmetatable({}, {
    __index = placement_private,
    __newindex = function(_, k, f) placement_private[k] = wrap_client(f, k) end
})

local corners3x3 = {
    {"top_left", "top", "top_right"}, {"left", nil, "right"},
    {"bottom_left", "bottom", "bottom_right"}
}

local corners2x2 = {{"top_left", "top_right"}, {"bottom_left", "bottom_right"}}

local align_map = {
    top_left = function(_, _, _, _) return {x = 0, y = 0} end,
    top_right = function(sw, _, dw, _) return {x = sw - dw, y = 0} end,
    bottom_left = function(_, sh, _, dh) return {x = 0, y = sh - dh} end,
    bottom_right = function(sw, sh, dw, dh) return {x = sw - dw, y = sh - dh} end,
    left = function(_, sh, _, dh) return {x = 0, y = sh / 2 - dh / 2} end,
    right = function(sw, sh, dw, dh)
        return {x = sw - dw, y = sh / 2 - dh / 2}
    end,
    top = function(sw, _, dw, _) return {x = sw / 2 - dw / 2, y = 0} end,
    bottom = function(sw, sh, dw, dh)
        return {x = sw / 2 - dw / 2, y = sh - dh}
    end,
    centered = function(sw, sh, dw, dh)
        return {x = sw / 2 - dw / 2, y = sh / 2 - dh / 2}
    end,
    center_vertical = function(_, sh, _, dh) return {x = nil, y = sh - dh} end,
    center_horizontal = function(sw, _, dw, _)
        return {x = sw / 2 - dw / 2, y = nil}
    end
}

local resize_to_point_map = {

    top_left = {
        p1 = nil,
        p2 = {1, 1},
        x_only = false,
        y_only = false,
        align = "bottom_right"
    },
    top_right = {
        p1 = {0, 1},
        p2 = nil,
        x_only = false,
        y_only = false,
        align = "bottom_left"
    },
    bottom_left = {
        p1 = nil,
        p2 = {1, 0},
        x_only = false,
        y_only = false,
        align = "top_right"
    },
    bottom_right = {
        p1 = {0, 0},
        p2 = nil,
        x_only = false,
        y_only = false,
        align = "top_left"
    },

    left = {
        p1 = nil,
        p2 = {1, 1},
        x_only = true,
        y_only = false,
        align = "top_right"
    },
    right = {
        p1 = {0, 0},
        p2 = nil,
        x_only = true,
        y_only = false,
        align = "top_left"
    },
    top = {
        p1 = nil,
        p2 = {1, 1},
        x_only = false,
        y_only = true,
        align = "bottom_left"
    },
    bottom = {
        p1 = {0, 0},
        p2 = nil,
        x_only = false,
        y_only = true,
        align = "top_left"
    }
}

local outer_positions = {
    left_front = function(r, w, _) return {x = r.x - w, y = r.y}, "front" end,
    left_back = function(r, w, h)
        return {x = r.x - w, y = r.y - h + r.height}, "back"
    end,
    left_middle = function(r, w, h)
        return {x = r.x - w, y = r.y - h / 2 + r.height / 2}, "middle"
    end,
    right_front = function(r, _, _) return {x = r.x, y = r.y}, "front" end,
    right_back = function(r, _, h)
        return {x = r.x, y = r.y - h + r.height}, "back"
    end,
    right_middle = function(r, _, h)
        return {x = r.x, y = r.y - h / 2 + r.height / 2}, "middle"
    end,
    top_front = function(r, _, h) return {x = r.x, y = r.y - h}, "front" end,
    top_back = function(r, w, h)
        return {x = r.x - w + r.width, y = r.y - h}, "back"
    end,
    top_middle = function(r, w, h)
        return {x = r.x - w / 2 + r.width / 2, y = r.y - h}, "middle"
    end,
    bottom_front = function(r, _, _) return {x = r.x, y = r.y}, "front" end,
    bottom_back = function(r, w, _)
        return {x = r.x - w + r.width, y = r.y}, "back"
    end,
    bottom_middle = function(r, w, _)
        return {x = r.x - w / 2 + r.width / 2, y = r.y}, "middle"
    end
}

local function add_context(args, context)
    return setmetatable({context = (args or {}).context or context},
                        {__index = args})
end

local data = setmetatable({}, {__mode = 'k'})

local function store_geometry(d, reqtype)
    if not data[d] then data[d] = {} end
    if not data[d][reqtype] then data[d][reqtype] = {} end
    data[d][reqtype] = d:geometry()
    data[d][reqtype].screen = d.screen
    data[d][reqtype].sgeo = d.screen and d.screen.geometry or nil
    data[d][reqtype].border_width = d.border_width
end

local function get_decoration(args)
    local offset = args.offset

    offset = type(offset) == "number" and
                 {x = offset, y = offset, width = offset, height = offset} or
                 args.offset or {}

    local m = type(args.margins) == "table" and args.margins or {
        left = args.margins or 0,
        right = args.margins or 0,
        top = args.margins or 0,
        bottom = args.margins or 0
    }

    return m, offset
end

local function fix_new_geometry(new_geo, args, force)
    if (args.pretend and not force) or not new_geo then return nil end

    local m, offset = get_decoration(args)

    return {
        x = new_geo.x and (new_geo.x + (offset.x or 0) + (m.left or 0)),
        y = new_geo.y and (new_geo.y + (offset.y or 0) + (m.top or 0)),
        width = new_geo.width and math.max(1, (new_geo.width +
                                               (offset.width or 0) -
                                               (m.left or 0) - (m.right or 0))),
        height = new_geo.height and
            math.max(1, (new_geo.height + (offset.height or 0) - (m.top or 0) -
                         (m.bottom or 0)))
    }
end

area_common = function(d, new_geo, ignore_border_width, args)

    if new_geo and args.zap_border_width then d.border_width = 0 end
    local geometry = new_geo and d:geometry(new_geo) or d:geometry()
    local border = ignore_border_width and 0 or d.border_width or 0

    if args and args.override_geometry then
        geometry = gtable.clone(args.override_geometry)
    end

    geometry.width = geometry.width + 2 * border
    geometry.height = geometry.height + 2 * border
    return geometry
end

local function geometry_common(obj, args, new_geo, ignore_border_width)

    if args.store_geometry and new_geo and args.context then
        store_geometry(obj, args.context)
    end

    if obj.coords then
        local coords =
            fix_new_geometry(new_geo, args) and obj.coords(new_geo) or
                obj.coords()
        return {x = coords.x, y = coords.y, width = 0, height = 0}
    elseif obj.geometry then
        if obj.get_bounding_geometry then

            return obj:get_bounding_geometry(args)
        end

        local dgeo = area_common(obj, fix_new_geometry(new_geo, args),
                                 ignore_border_width, args)

        if args.margins then
            local delta = get_decoration(args)

            return {
                x = dgeo.x - (delta.left or 0),
                y = dgeo.y - (delta.top or 0),
                width = dgeo.width + (delta.left or 0) + (delta.right or 0),
                height = dgeo.height + (delta.top or 0) + (delta.bottom or 0)
            }
        end

        return dgeo
    else
        assert(false, "Invalid object")
    end
end

local function get_parent_geometry(obj, args)

    if args.bounding_rect then
        return args.bounding_rect
        elseif args.screen then
            return args.honor_workarea and  args.screen.workarea or args.screen.geometry
    elseif args.parent then
        return geometry_common(args.parent, {})
    elseif obj.screen  or args.screen then
        return geometry_common(obj.screen, {
            honor_padding = args.honor_padding,
            honor_workarea = args.honor_workarea
        })
    else
        return geometry_common(capi.screen[capi.mouse.screen], args)
    end
end

local function move_into_geometry(source, target)
    local ret = {x = target.x, y = target.y}

    if ret.x < source.x then
        ret.x = source.x
    elseif ret.x > source.x + source.width then
        ret.x = source.x + source.width - 1
    end

    if ret.y < source.y then
        ret.y = source.y
    elseif ret.y > source.y + source.height then
        ret.y = source.y + source.height - 1
    end

    return ret
end

wibox_update_strut = function(d, position, args)

    if not d.visible then
        d:struts{left = 0, right = 0, bottom = 0, top = 0}
        return
    end

    local geo = area_common(d)
    local vertical = geo.width < geo.height

    local struts = {left = 0, right = 0, bottom = 0, top = 0}

    local m = get_decoration(args)

    if vertical then
        for _, v in ipairs {"right", "left"} do
            if (not position) or position:match(v) then
                struts[v] = geo.width + m[v]
            end
        end
    else
        for _, v in ipairs {"top", "bottom"} do
            if (not position) or position:match(v) then
                struts[v] = geo.height + m[v]
            end
        end
    end

    d:struts(struts)
end

attach = function(d, position_f, args)
    args = args or {}

    if args.pretend then return end

    if not args.attach then return end

    args = setmetatable({attach = false}, {__index = args})

    d = d or capi.client.focus
    if not d then return end

    if type(position_f) == "string" then position_f = placement[position_f] end

end

local function rect_from_points(p1x, p1y, p2x, p2y)
    return {x = p1x, y = p1y, width = p2x - p1x, height = p2y - p1y}
end

local function rect_to_point(rect, corner_i, corner_j)
    return {
        x = rect.x + corner_i * math.floor(rect.width),
        y = rect.y + corner_j * math.floor(rect.height)
    }
end

local function get_cross_sections(abs_geo, mode)
    if not mode or mode == "cursor" then

        local coords = capi.mouse.coords()
        return {
            h = {
                x = abs_geo.drawable_geo.x,
                y = coords.y,
                width = abs_geo.drawable_geo.width,
                height = 1
            },
            v = {
                x = coords.x,
                y = abs_geo.drawable_geo.y,
                width = 1,
                height = abs_geo.drawable_geo.height
            }
        }
    elseif mode == "geometry" then

        return {
            h = {
                x = abs_geo.drawable_geo.x,
                y = abs_geo.y,
                width = abs_geo.drawable_geo.width,
                height = abs_geo.height
            },
            v = {
                x = abs_geo.x,
                y = abs_geo.drawable_geo.y,
                width = abs_geo.width,
                height = abs_geo.drawable_geo.height
            }
        }
    elseif mode == "cursor_inside" then

        local coords = capi.mouse.coords()
        coords.width, coords.height = 1, 1
        return {h = coords, v = coords}
    elseif mode == "geometry_inside" then

        return {h = abs_geo, v = abs_geo}
    end
end

local function get_relative_regions(geo, mode, is_absolute)

    if not geo then
        local draw = capi.mouse.current_wibox
        geo = draw and draw:geometry() or capi.mouse.coords()
        geo.drawable = draw
    elseif is_absolute then

        geo.drawable = geo

    elseif (not geo.drawable) and geo.x and geo.width then
        local coords = capi.mouse.coords()

        if coords.x > geo.x and coords.x < geo.x + geo.width and coords.y >
            geo.y and coords.y < geo.y + geo.height then
            geo.drawable = capi.mouse.current_wibox
        end

        if (not geo.drawable) and capi.mouse.current_client then
            geo.drawable = capi.mouse.current_client
        end
    end

    local bw, dgeo = 0, {x = 0, y = 0, width = 1, height = 1}

    if geo.drawin then
        bw, dgeo = geo.drawin._border_width, geo.drawin:geometry()
    elseif geo.drawable and geo.drawable.get_wibox then
        bw = geo.drawable.get_wibox().border_width
        dgeo = geo.drawable.get_wibox():geometry()
    elseif geo.drawable and geo.drawable.drawable then
        bw, dgeo = 0, geo.drawable.drawable:geometry()
    else

        assert(mode == "geometry")
    end

    dgeo.width = dgeo.width + 2 * bw
    dgeo.height = dgeo.height + 2 * bw

    local abs_widget_geo = is_absolute and dgeo or {
        x = dgeo.x + geo.x + bw,
        y = dgeo.y + geo.y + bw,
        width = geo.width,
        height = geo.height,
        drawable = geo.drawable
    }

    abs_widget_geo.drawable_geo = geo.drawable and dgeo or geo

    local center_point = mode:match("cursor") and capi.mouse.coords() or {
        x = abs_widget_geo.x + abs_widget_geo.width / 2,
        y = abs_widget_geo.y + abs_widget_geo.height / 2
    }

    local cs = get_cross_sections(abs_widget_geo, mode)

    local regions = {
        left = {x = cs.h.x, y = cs.h.y},
        right = {x = cs.h.x + cs.h.width, y = cs.h.y},
        top = {x = cs.v.x, y = cs.v.y},
        bottom = {x = cs.v.x, y = cs.v.y + cs.v.height}
    }

    local s = geo.drawable and geo.drawable.screen or
                  a_screen.getbycoord(center_point.x, center_point.y)

    for _, v in pairs(regions) do
        local dx, dy = v.x - center_point.x, v.y - center_point.y

        v.distance = math.sqrt(dx * dx + dy * dy)
        v.width = cs.v.width
        v.height = cs.h.height
        v.screen = capi.screen[s]
    end

    return regions
end

local function fit_in_bounding(obj, geo, args)
    local sgeo = get_parent_geometry(obj, args)
    local region = cairo.Region.create_rectangle(cairo.RectangleInt(sgeo))

    region:intersect(cairo.Region.create_rectangle(cairo.RectangleInt(geo)))

    local geo2 = region:get_rectangle(0)

    return geo2.width == geo.width and geo2.height == geo.height
end

local function remove_border(drawable, args, geo)
    local bw = (not args.ignore_border_width) and drawable.border_width or 0
    geo.width = geo.width - 2 * bw
    geo.height = geo.height - 2 * bw
end

function placement.closest_corner(d, args)
    args = add_context(args, "closest_corner")
    d = d or capi.client.focus

    local sgeo = get_parent_geometry(d, args)
    local dgeo = geometry_common(d, args)

    local pos = move_into_geometry(sgeo, dgeo)

    local corner_i, corner_j, n

    local function f(_n, mat)
        n = _n

        corner_i = -math.ceil(((sgeo.x - pos.x) * n) / (sgeo.width + 1))
        corner_j = -math.ceil(((sgeo.y - pos.y) * n) / (sgeo.height + 1))
        return mat[corner_j + 1][corner_i + 1]
    end

    local grid_size = args.include_sides and 3 or 2

    local corner = grid_size == 3 and f(3, corners3x3) or f(2, corners2x2)

    local new_args = setmetatable({position = corner}, {__index = args})
    local ngeo = placement_private.align(d, new_args)

    return fix_new_geometry(ngeo, args, true), corner
end

function placement.no_offscreen(c, args)

    if type(args) == "number" or type(args) == "screen" then
    
        args = {screen = args}
    end

    c = c or capi.client.focus
    args = add_context(args, "no_offscreen")
    local geometry = geometry_common(c, args)
    local screen = get_screen(args.screen or c.screen or
                                  a_screen.getbycoord(geometry.x, geometry.y))
    local screen_geometry = screen.workarea

    if geometry.x + geometry.width > screen_geometry.x + screen_geometry.width then
        geometry.x = screen_geometry.x + screen_geometry.width - geometry.width
    end
    if geometry.x < screen_geometry.x then geometry.x = screen_geometry.x end

    if geometry.y + geometry.height > screen_geometry.y + screen_geometry.height then
        geometry.y = screen_geometry.y + screen_geometry.height -
                         geometry.height
    end
    if geometry.y < screen_geometry.y then geometry.y = screen_geometry.y end

    remove_border(c, args, geometry)
    geometry_common(c, args, geometry)
    return fix_new_geometry(geometry, args, true)
end

local function client_on_selected_tags(c)
    if c.sticky then
        return true
    else
        for _, t in pairs(c:tags()) do if t.selected then return true end end
        return false
    end
end

local function client_visible_on_tags(c, tags)
    if c.hidden or c.minimized then
        return false
    elseif c.sticky then
        return true
    else
        for _, t in pairs(c:tags()) do
            if gtable.hasitem(tags, t) then return true end
        end
        return false
    end
end

function placement.no_overlap(c, args)
    c = c or capi.client.focus
    args = add_context(args, "no_overlap")
    local geometry = geometry_common(c, args)
    local screen = get_screen(c.screen or
                                  a_screen.getbycoord(geometry.x, geometry.y))
    local cls, curlay
    if client_on_selected_tags(c) then
        cls = screen:get_clients(false)
        local t = screen.selected_tag
        curlay = t.layout or floating
    else

        local tags = c:tags()
        cls = {}
        for _, other_c in pairs(capi.client.get(screen)) do
            if client_visible_on_tags(other_c, tags) then
                table.insert(cls, other_c)
            end
        end
        curlay = tags[1] and tags[1].layout
    end
    local areas = {screen.workarea}
    for _, cl in pairs(cls) do
        if cl ~= c and cl.type ~= "desktop" and
            (cl.floating or curlay == floating) and
            not (cl.maximized or cl.fullscreen) then
            areas = grect.area_remove(areas, area_common(cl))
        end
    end

    local found = false
    local new = {x = geometry.x, y = geometry.y, width = 0, height = 0}
    for _, r in ipairs(areas) do
        if r.width >= geometry.width and r.height >= geometry.height and r.width *
            r.height > new.width * new.height then
            found = true
            new = r

            if geometry.x >= r.x and geometry.y >= r.y and geometry.x +
                geometry.width <= r.x + r.width and geometry.y + geometry.height <=
                r.y + r.height then
                new.x = geometry.x
                new.y = geometry.y
            end
        end
    end

    if not found then
        if #areas > 0 then
            for _, r in ipairs(areas) do
                if r.width * r.height > new.width * new.height then
                    new = r
                end
            end
        elseif grect.area_intersect_area(geometry, screen.workarea) then
            new.x = geometry.x
            new.y = geometry.y
        else
            new.x = screen.workarea.x
            new.y = screen.workarea.y
        end
    end

    new.width = geometry.width
    new.height = geometry.height

    remove_border(c, args, new)
    geometry_common(c, args, new)
    return fix_new_geometry(new, args, true)
end

function placement.under_mouse(d, args)
    args = add_context(args, "under_mouse")
    d = d or capi.client.focus

    local m_coords = capi.mouse.coords()

    local ngeo = geometry_common(d, args)
    ngeo.x = math.floor(m_coords.x - ngeo.width / 2)
    ngeo.y = math.floor(m_coords.y - ngeo.height / 2)

    remove_border(d, args, ngeo)
    geometry_common(d, args, ngeo)

    return fix_new_geometry(ngeo, args, true)
end

function placement.next_to_mouse(d, args)
    if type(args) == "number" then
       
        args = nil
    end

    local old_args = args or {}

    args = add_context(args, "next_to_mouse")
    d = d or capi.client.focus

    local sgeo = get_parent_geometry(d, args)

    args.pretend = true
    args.parent = capi.mouse

    local ngeo = placement.left(d, args)

    if ngeo.x + ngeo.width > sgeo.x + sgeo.width then
        ngeo = placement.right(d, args)
    else

        ngeo.x = ngeo.x + 1
    end

    args.pretend = old_args.pretend

    geometry_common(d, args, ngeo)

    attach(d, placement.next_to_mouse, old_args)

    return fix_new_geometry(ngeo, args, true)
end

function placement.resize_to_mouse(d, args)
    d = d or capi.client.focus
    args = add_context(args, "resize_to_mouse")

    local coords = capi.mouse.coords()
    local ngeo = geometry_common(d, args)
    local h_only = args.axis == "horizontal"
    local v_only = args.axis == "vertical"

    local _, closest_corner = placement.closest_corner(capi.mouse, {
        parent = d,
        pretend = true,
        include_sides = args.include_sides or false
    })

    if h_only then
        closest_corner = closest_corner:match("left") or
                             closest_corner:match("right")
    elseif v_only then
        closest_corner = closest_corner:match("top") or
                             closest_corner:match("bottom")
    end

    local pts = resize_to_point_map[closest_corner]
    local p1 = pts.p1 and rect_to_point(ngeo, pts.p1[1], pts.p1[2]) or coords
    local p2 = pts.p2 and rect_to_point(ngeo, pts.p2[1], pts.p2[2]) or coords

    ngeo = rect_from_points(pts.y_only and ngeo.x or math.min(p1.x, p2.x),
                            pts.x_only and ngeo.y or math.min(p1.y, p2.y),
                            pts.y_only and ngeo.x + ngeo.width or
                                math.max(p2.x, p1.x), pts.x_only and ngeo.y +
                                ngeo.height or math.max(p2.y, p1.y))

    remove_border(d, args, ngeo)

    if d.apply_size_hints then
        local w, h = d:apply_size_hints(ngeo.width, ngeo.height)
        local offset = align_map[pts.align](w, h, ngeo.width, ngeo.height)
        ngeo.x = ngeo.x - offset.x
        ngeo.y = ngeo.y - offset.y
    end

    geometry_common(d, args, ngeo)

    return fix_new_geometry(ngeo, args, true)
end

function placement.align(d, args)
    args = add_context(args, "align")
    d = d or capi.client.focus

    if not d or not args.position then return end

    local sgeo = get_parent_geometry(d, args)
    local dgeo = geometry_common(d, args)

    local pos = align_map[args.position](sgeo.width, sgeo.height, dgeo.width,
                                         dgeo.height)

    local ngeo = {
        x = (pos.x and math.ceil(sgeo.x + pos.x) or dgeo.x),
        y = (pos.y and math.ceil(sgeo.y + pos.y) or dgeo.y),
        width = math.ceil(dgeo.width),
        height = math.ceil(dgeo.height)
    }
    remove_border(d, args, ngeo)
    geometry_common(d, args, ngeo)

  --  attach(d, placement[args.position], args)

    return fix_new_geometry(ngeo, args, true)
end

for k in pairs(align_map) do
    placement[k] = function(d, args)
        args = add_context(args, k)
        args.position = k
        return placement_private.align(d, args)
    end
    reverse_align_map[placement[k]] = k
end

function placement.stretch(d, args)
    args = add_context(args, "stretch")

    d = d or capi.client.focus
    if not d or not args.direction then return end

    if type(args.direction) == "table" then
        for _, dir in ipairs(args.direction) do
            args.direction = dir
            placement_private.stretch(dir, args)
        end
        return
    end

    local sgeo = get_parent_geometry(d, args)
    local dgeo = geometry_common(d, args)
    local ngeo = geometry_common(d, args, nil, true)
    local bw = (not args.ignore_border_width) and d.border_width or 0

    if args.direction == "left" then
        ngeo.x = sgeo.x
        ngeo.width = dgeo.width + (dgeo.x - ngeo.x)
    elseif args.direction == "right" then
        ngeo.width = sgeo.width - ngeo.x - 2 * bw
    elseif args.direction == "up" then
        ngeo.y = sgeo.y
        ngeo.height = dgeo.height + (dgeo.y - ngeo.y)
    elseif args.direction == "down" then
        ngeo.height = sgeo.height - dgeo.y - 2 * bw
    else
        assert(false)
    end

    ngeo.width = math.max(args.minimim_width or 1, ngeo.width)
    ngeo.height = math.max(args.minimim_height or 1, ngeo.height)

    geometry_common(d, args, ngeo)

    attach(d, placement["stretch_" .. args.direction], args)

    return fix_new_geometry(ngeo, args, true)
end

for _, v in ipairs {"left", "right", "up", "down"} do
    placement["stretch_" .. v] = function(d, args)
        args = add_context(args, "stretch_" .. v)
        args.direction = v
        return placement_private.stretch(d, args)
    end
end

function placement.maximize(d, args)
    args = add_context(args, "maximize")
    d = d or capi.client.focus

    if not d then return end

    local sgeo = get_parent_geometry(d, args)
    local ngeo = geometry_common(d, args, nil, true)
    local bw = (not args.ignore_border_width) and d.border_width or 0

    if (not args.axis) or args.axis:match "vertical" then
        ngeo.y = sgeo.y
        ngeo.height = sgeo.height - 2 * bw
    end

    if (not args.axis) or args.axis:match "horizontal" then
        ngeo.x = sgeo.x
        ngeo.width = sgeo.width - 2 * bw
    end

    geometry_common(d, args, ngeo)

    attach(d, placement.maximize, args)

    return fix_new_geometry(ngeo, args, true)
end

for _, v in ipairs {"vertically", "horizontally"} do
    placement["maximize_" .. v] = function(d2, args)
        args = add_context(args, "maximize_" .. v)
        args.axis = v
        return placement_private.maximize(d2, args)
    end
end

function placement.scale(d, args)
    args = add_context(args, "scale_to_percent")
    d = d or capi.client.focus

    local to_percent = args.to_percent
    local by_percent = args.by_percent

    local percent = to_percent or by_percent

    local direction = args.direction

    local sgeo = get_parent_geometry(d, args)
    local ngeo = geometry_common(d, args, nil)

    local old_area = {width = ngeo.width, height = ngeo.height}

    if (not direction) or direction == "left" or direction == "right" then
        ngeo.width = (to_percent and sgeo or ngeo).width * percent

        if direction == "left" then
            ngeo.x = ngeo.x - (ngeo.width - old_area.width)
        end
    end

    if (not direction) or direction == "up" or direction == "down" then
        ngeo.height = (to_percent and sgeo or ngeo).height * percent

        if direction == "up" then
            ngeo.y = ngeo.y - (ngeo.height - old_area.height)
        end
    end

    remove_border(d, args, ngeo)
    geometry_common(d, args, ngeo)

    attach(d, placement.maximize, args)

    return fix_new_geometry(ngeo, args, true)
end

function placement.next_to(d, args)
    args = add_context(args, "next_to")
    d = d or capi.client.focus

    local osize = type(d.geometry) == "function" and d:geometry() or d.geometry
    local original_pos, original_anchors = args.preferred_positions,
                                           args.preferred_anchors

    if type(original_pos) == "string" then original_pos = {original_pos} end

    if type(original_anchors) == "string" then
        original_anchors = {original_anchors}
    end

    local preferred_positions = {}
    local preferred_anchors =
        #(original_anchors or {}) > 0 and original_anchors or
            {"front", "back", "middle"}

    for k, v in ipairs(original_pos or {}) do preferred_positions[v] = k end

    local dgeo = geometry_common(d, args)
    local pref_idx, pref_name = 99, nil
    local mode, wgeo = args.mode

    if args.geometry then
        mode = "geometry"
        wgeo = args.geometry
    else
        local pos = capi.mouse.current_widget_geometry

        if pos then
            wgeo, mode = pos, "cursor"
        elseif capi.mouse.current_client then
            wgeo, mode = capi.mouse.current_client:geometry(), "cursor"
        end
    end

    if not wgeo then return end

    local is_absolute = wgeo.ontop ~= nil

    local regions = get_relative_regions(wgeo, mode, is_absolute)

    local sorted_regions, default_positions = {}, {
        "left", "right", "bottom", "top"
    }

    for _, pos in ipairs(original_pos or {}) do
        for idx, def in ipairs(default_positions) do
            if def == pos then
                table.remove(default_positions, idx)
                break
            end
        end

        table.insert(sorted_regions, {name = pos, region = regions[pos]})
    end

    for _, pos in ipairs(default_positions) do
        table.insert(sorted_regions, {name = pos, region = regions[pos]})
    end

    local does_fit = {}
    for _, pos in ipairs(sorted_regions) do
        local geo, dir, fit

        for _, anchor in ipairs(preferred_anchors) do
            geo, dir = outer_positions[pos.name .. "_" .. anchor](pos.region,
                                                                  dgeo.width,
                                                                  dgeo.height)

            geo.width, geo.height = dgeo.width, dgeo.height

            fit = fit_in_bounding(pos.region, geo, args)

            if fit then break end
        end

        does_fit[pos.name] = fit and {geo, dir} or nil

        local better_pos_idx = preferred_positions[pos.name] and
                                   preferred_positions[pos.name] < pref_idx or
                                   false

        if fit and (better_pos_idx or not pref_name) then
            pref_idx = preferred_positions[pos.name]
            pref_name = pos.name
        end

        if fit then break end
    end

    if not pref_name then return end

    assert(does_fit[pref_name])

    local ngeo, dir = unpack(does_fit[pref_name])

    if not ngeo then return end

    remove_border(d, args, ngeo)

    geometry_common(d, args, ngeo)

    attach(d, placement.next_to, args)

    local ret = fix_new_geometry(ngeo, args, true)

    assert((not osize.width) or ret.width == d.width)
    assert((not osize.height) or ret.height == d.height)

    return ret, pref_name, dir
end

function placement.restore(d, args)
    if not args or not args.context then return false end
    d = d or capi.client.focus

    if not data[d] then return false end

    local memento = data[d][args.context]

    if not memento then return false end

    local x, y = memento.x, memento.y

    if memento.sgeo and memento.screen and memento.screen.valid and args.context ==
        "maximize" and d.screen and get_screen(memento.screen) ~=
        get_screen(d.screen) then

        local sgeo = get_screen(d.screen).geometry

        x = sgeo.x + (memento.x - memento.sgeo.x)
        y = sgeo.y + (memento.y - memento.sgeo.y)

    end

    d.border_width = memento.border_width

    d:geometry{x = x, y = y, width = memento.width, height = memento.height}

    return true
end


return placement

