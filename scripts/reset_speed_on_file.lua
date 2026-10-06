--[reset_speed_on_file]
-- 切换/打开新文件时把倍速重置为 1x。
-- 背景：uosc 的"下一集"按钮走 navigate_item -> loadfile，不触发 mpv 的
--       reset-on-next-file，导致倍速不会在下一集自动恢复。这里监听 path
--       变化手动重置。同一文件内手动调的倍速不受影响（path 不变不触发）。
local mp = require 'mp'

mp.observe_property('path', 'string', function(_, path)
    if path and path ~= '' then
        mp.set_property('speed', '1')
    end
end)
