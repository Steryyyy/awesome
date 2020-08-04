






local base = require("my.wibox.widget.base")

return setmetatable({
    rotate = require("my.wibox.container.rotate");
    margin = require("my.wibox.container.margin");
  --  mirror = require("my.wibox.container.mirror");

 --   scroll = require("my.wibox.container.scroll");
    background = require("my.wibox.container.background");
  --  radialprogressbar = require("my.wibox.container.radialprogressbar");
 --   arcchart = require("my.wibox.container.arcchart");
  --  place = require("my.wibox.container.place");
}, {__call = function(_, args) return base.make_widget_declarative(args) end})


