local wibox = require("wibox")

local volume = {}

volume.volume = wibox.layout.fixed.horizontal()
volume.microphone = wibox.layout.fixed.horizontal()

awesome.connect_signal('default-sink-change',
                       function(e)

    volume.volume:set_children{e:get_children_by_id('volume_layout')[1]}

end)
awesome.connect_signal('default-source-change', function(e)

    volume.microphone:set_children{e:get_children_by_id('volume_layout')[1]}

end)

volume.microphone.forced_width = 70
volume.volume.forced_width = 70

return volume
