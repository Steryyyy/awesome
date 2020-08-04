
local base = require("my.wibox.widget.base")
return setmetatable({
    fixed = require("my.wibox.layout.fixed");
    align = require("my.wibox.layout.align");
    flex = require("my.wibox.layout.flex");

    stack = require("my.wibox.layout.stack");

}, {__call = function(_, args) return base.make_widget_declarative(args) end})