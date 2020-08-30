local tostring = tostring;
local print = print;
local type = type;
local pairs = pairs;
local a = {}
local function b(c, d, e, f)
    f = f == nil and 10 or f or 0;
    local g = ""
    if e then g = g .. tostring(e) .. " : " end
    if type(c) == "table" and f > 0 then
        d = (d or "") .. "  "
        g = g .. tostring(c)
        for h, i in pairs(c) do g = g .. "\n" .. d .. b(i, d, h, f - 1) end
    else
        g = g .. tostring(c) .. " (" .. type(c) .. ")"
        if f == 0 and type(c) == "table" then g = g .. " […]" end
    end
    return g
end
function a.dump_return(c, e, f) return b(c, nil, e, f) end
function a.dump(c, e, f) print(a.dump_return(c, e, f)) end
function a.print_warning(j)
    io.stderr:write(os.date("%Y-%m-%d %T W: awesome: ") .. tostring(j) .. "\n")
end
function a.print_error(j)
    io.stderr:write(os.date("%Y-%m-%d %T E: awesome: ") .. tostring(j) .. "\n")
end
local k = {}


return a
