local a = {}
local b = {
    client = {
        autoactivate = {
            mouse_enter = false,
            switch_tag = false,
          
        }
    }
}
function a.check(c, d, e, f)
    local g = nil;
    if c._private.permissions and c._private.permissions[e] then
        g = c._private.permissions[e][f]
    end
    if g ~= nil then return g end
    if not b[d] then return true end
    if not b[d][e] then return true end
    if b[d][e][f] == nil then return true end
    return b[d][e][f]
end
function a.set(d, e, f, h)
    assert(type(h) == "boolean")
    if not b[d] then b[d] = {} end
    if not b[d][e] then b[d][e] = {} end
    b[d][e][f] = h
end

local function i(self, e, f, j)
    self._private.permissions = self._private.permissions or {}
    if not self._private.permissions[e] then
        self._private.permissions[e] = {}
    end
    self._private.permissions[e][f] = j
end
function a.setup_grant(d, k)
    function d.grant(self, e, f) i(self, e, f, true) end
    function d.deny(self, e, f) i(self, e, f, false) end
end
return a
