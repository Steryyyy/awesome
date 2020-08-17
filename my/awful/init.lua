require("my.awful.root")
local ret = {
    client = require("my.awful.client");

    layout = require("my.awful.layout");


    screen = require("my.awful.screen");
    tag = require("my.awful.tag");

    keygrabber = require("my.awful.keygrabber");

    mouse = require("my.awful.mouse");
    remote = require("my.awful.remote");
    key = require("my.awful.key");
    keyboard = require("my.awful.keyboard");
    button = require("my.awful.button");

   permissions = require("my.awful.permissions");

    -- rules = require("my.awful.rules");

    spawn = require("my.awful.spawn");
}
return ret
