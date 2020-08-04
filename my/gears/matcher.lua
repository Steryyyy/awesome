local a = require("my.gears.table")
local b = require("my.gears.sort")
local c = require("my.gears.debug")
local d = require("my.gears.object")
local e = require("my.gears.protected_call")
local f = {}
local function g(h, i) return h == i or type(h) == "string" and h:match(i) end
local function j(h, i) return h > i end
local function k(h, i) return h < i end
function f:_match(l, m, n)
    if not m then return false end
    n = n or g;
    for o, p in pairs(m) do
        local q = self._private.prop_matchers[o]
        if q and q(l, p, o) then
            return true
        elseif not n(l[o], p) then
            return false
        end
    end
    return true
end
local function r(self, l, o, p, n)
    n = n or g;
    local q = self._private.prop_matchers[o]
    if q and q(l, p, o) then
        return true
    elseif n(l[o], p) then
        return true
    end
    return false
end
function f:_match_any(l, m)
    if not m then return false end
    for o, s in pairs(m) do
        if l[o] then
            if type(s) == "boolean" and s then return true end
            for t, p in ipairs(s) do
                if r(self, l, o, p) then return true end
            end
        end
    end
    return false
end
function f:_match_every(l, m)
    if not m then return true end
    for o, s in pairs(m) do
        local u = false;
        for t, p in ipairs(s) do
            if not r(self, l, o, p) then
                u = true;
                break
            end
        end
        if not u then return false end
    end
    return true
end
function f:matches_rule(l, v)
    local w = self:_match(l, v.rule) or self:_match_any(l, v.rule_any)
    if not w and (v.rule or v.rule_any) then return false end
    if not self:_match_every(l, v.rule_every) then return false end
    if v.except and self:_match(l, v.except) then return false end
    if v.except_any and self:_match_any(l, v.except_any) then return false end
    if v.rule_greater and not self:_match(l, v.rule_greater, j) then
        return false
    end
    if v.rule_lesser and not self:_match(l, v.rule_lesser, k) then
        return false
    end
    return true
end
function f:matching_rules(l, x)
    if not x then
        local y = {}
        for t, z in pairs(self._matching_rules) do
            a.merge(y, self:matching_rules(l, z))
        end
        return y
    end
    local A = {}
    if not x then
        c.print_warning("This matcher has no rule source")
        return A
    end
    for t, v in ipairs(x) do
        if self:matches_rule(l, v) then table.insert(A, v) end
    end
    return A
end
function f:matches_rules(l, x)
    for t, v in ipairs(x) do if self:matches_rule(l, v) then return true end end
    return false
end
function f:add_property_matcher(B, C)
    assert(not self._private.prop_matchers[B], B .. " already has a matcher")
    self._private.prop_matchers[B] = C;
    self:emit_signal("property_matcher::added", B, C)
end
function f:add_property_setter(B, C)
    assert(not self._private.prop_setters[B], B .. " already has a matcher")
    self._private.prop_setters[B] = C;
    self:emit_signal("property_setter::added", B, C)
end
local function D(self, l, E, F, x)
    for t, v in ipairs(self:matching_rules(l, x)) do
        a.crush(E, v.properties or {})
        if v.callback then table.insert(F, v.callback) end
    end
end
function f:add_matching_rules(B, x, G, H)
    local function I(J, K, E, F) D(J, K, E, F, x) end
    self._matching_rules[B] = x;
    self:emit_signal("matching_rules::added", x)
    return self:add_matching_function(B, I, G, H)
end
function f:add_matching_function(B, L, G, H)
    G = G or {}
    H = H or {}
    assert(type(G) == "table")
    assert(type(H) == "table")
    for t, M in ipairs(self._matching_source) do
        assert(M.name ~= B,
               "Name must be unique, but '" .. B .. "' was already registered.")
    end
    local N = self._rule_source_sort:clone()
    N:prepend(B, H)
    N:append(B, G)
    local O, P = N:sort()
    if P then
        c.print_warning("Failed to add the rule source: " .. P)
        return false
    end
    self._rule_source_sort = N;
    local F = {}
    for t, M in ipairs(self._matching_source) do F[M.name] = M.callback end
    self._matching_source = {}
    F[B] = L;
    for t, M in ipairs(O) do
        if F[M] then
            table.insert(self._matching_source, 1, {callback = F[M], name = M})
        end
    end
    self:emit_signal("matching_function::added", L)
    return true
end
function f:remove_matching_source(B)
    self._rule_source_sort:remove(B)
    for Q, M in ipairs(self._matching_source) do
        if M.name == B then
            self:emit_signal("matching_source::removed", M)
            table.remove(self._matching_source, Q)
            return true
        end
    end
    self._matching_rules[B] = nil;
    return false
end
function f:apply(l)
    local F, E = {}, {}
    for t, M in ipairs(self._matching_source) do M.callback(self, l, E, F) end
    self:_execute(l, E, F)
end
function f:_execute(l, E, F)
    if F then for t, L in pairs(F) do e(L, l) end end
    for R, p in pairs(E) do
        if type(p) == "function" then p = p(l, E) end
        if self._private.prop_setters[R] then
            self._private.prop_setters[R](l, p)
        elseif type(l[R]) == "function" then
            l[R](l, p)
        else
            l[R] = p
        end
    end
end
function f:append_rule(S, m)
    if not self._matching_rules[S] then
        self:add_matching_rules(S, {}, {}, {})
    end
    table.insert(self._matching_rules[S], m)
    self:emit_signal("rule::appended", m, S, self._matching_rules[S])
end
function f:append_rules(S, x) for t, m in ipairs(x) do self:append_rule(S, m) end end
function f:remove_rule(S, m)
    if not self._matching_rules[S] then return end
    for Q, M in ipairs(self._matching_rules[S]) do
        if M == m or M.id == m then
            table.remove(self._matching_rules[S], Q)
            self:emit_signal("rule::removed", m, S, self._matching_rules[S])
            return true
        end
    end
    return false
end
local T = {}
local function U()
    local y = d()
    rawset(y, "_private", {rules = {}, prop_matchers = {}, prop_setters = {}})
    y._matching_source = {}
    y._rule_source_sort = b.topological()
    y._matching_rules = {}
    a.crush(y, f, true)
    return y
end
return setmetatable(T, {__call = U})
