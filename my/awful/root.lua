local a = {root = root}
local b = require("my.gears.table")
local c = require("my.gears.timer")
local unpack = unpack or table.unpack;

local d = require("my.gears.object.properties")


do
    local f, g = {}, {}
    a.root.set_newindex_miss_handler(function(h, i, j)
        if g["set_" .. i] then
            g["set_" .. i](j)
        elseif not g["get_" .. i] then
            f[i] = j
        else
            error("Cannot set '" .. tostring(i) .. " because it is read-only")
        end
    end)
    a.root.set_index_miss_handler(function(h, i)
        if g["get_" .. i] then
            return g["get_" .. i]()
        else
            return f[i]
        end
    end)
    root._private = {}
    root.object = g;
    assert(root.object == g)
end
d._legacy_accessors(a.root, "buttons", "_buttons", false, function(k)
    return k[1] and (type(k[1]) == "button" or k[1]._is_capi_button) or false
end, true)
d._legacy_accessors(a.root, "keys", "_keys", false, function(k)
    return k[1] and (type(k[1]) == "key" or k[1]._is_capi_button) or false
end, true)

for d, e in ipairs {"button", "key"} do
    local f = e .. "s"
    local g, h, i = false, {}, {}
    local function j(k)
        if k then table.insert(h, k) end
        if g then return end
        g = true;
        c.delayed_call(function()
            local l = a.root["_" .. f]()
            for d, m in ipairs(i) do
                local n = b.hasitem(l, m[1])
                if n then
                    for o = 1, #m do
                        assert(l[n] == m[o], "The root private " .. e ..
                                   " table is corrupted")
                        table.remove(l, n)
                    end
                end
                n = b.hasitem(h, m)
                if n then table.remove(h, n) end
            end
            local p = b.join(unpack(h))
            l = b.merge(l, p)
            a.root["_" .. f](l)
            g, h, i = false, {}, {}
        end)
    end
    a.root["_append_" .. e] = function(k)
        if not k then return end
        local q = a.root._private[f]
        if not q or not next(q) then
            a.root[f] = {k}
            assert(a.root._private[f])
            return
        end
        j(k)
    end;
    a.root["_append_" .. f] = function(r)
        for d, k in ipairs(r) do a.root["_append_" .. e](k) end
    end;
    a.root["_remove_" .. e] = function(k)
        if not a.root._private[f] then return end
        local s = b.hasitem(a.root._private[f], k)
        if s then table.remove(a.root._private[f], s) end
        assert(k[1])
        table.insert(i, k)
    end;
    a.root["has_" .. e] = function(t)
        if not t["_is_capi_" .. e] then t = t[1] end
        return b.hasitem(a.root["_" .. f](), t) ~= nil
    end;
    assert(root[f])
end
