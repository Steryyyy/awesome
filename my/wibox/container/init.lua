local base = require("my.wibox.widget.base")
return setmetatable({
    rotate = require("my.wibox.container.rotate");
    margin = require("my.wibox.container.margin");
    background = require("my.wibox.container.background");
}, {__call = function(_, args) return base.make_widget_declarative(args) end})


