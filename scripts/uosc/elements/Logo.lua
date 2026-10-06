local mp = require 'mp'
local Element = require('elements/Element')

--[[ Logo ]]

---@class Logo : Element
local Logo = class(Element)

function Logo:new() return Class.new(self) --[[@as Logo]] end
function Logo:init()
	Element.init(self, 'logo')
	self.enabled = state.is_idle

	self.logo_lines = {
		-- mod https://github.com/mpv-player/mpv/blob/master/player/lua/osc.lua
		'{\\3c&HF593C8&\\bord2\\blur8\\p5}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10{\\p0}',
		'{\\1c&HE5E5E5&\\bord0\\blur0\\p5}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10{\\p0}',
		'{\\1c&H682167&\\bord0\\blur0\\p5}m 925 42 b 463 42 87 418 87 880 87 1343 463 1718 925 1718 1388 1718 1763 1343 1763 880 1763 418 1388 42 925 42{\\p0}',
		'{\\1c&H430142&\\bord0\\blur0\\p5}m 1605 828 b 1605 1175 1324 1456 977 1456 631 1456 349 1175 349 828 349 482 631 200 977 200 1324 200 1605 482 1605 828{\\p0}',
		'{\\1c&HDDDBDD&\\bord0\\blur0\\p5}m 1296 910 b 1296 1131 1117 1310 897 1310 676 1310 497 1131 497 910 497 689 676 511 897 511 1117 511 1296 689 1296 910{\\p0}',
		'{\\1c&H691F69&\\bord0\\blur0\\p5}m 762 1113 l 762 708 b 881 776 1000 843 1119 911 1000 978 881 1046 762 1113{\\p0}',
	}

end

function Logo:decide_enabled() self.enabled = state.idlescreen and state.is_idle end
function Logo:on_prop_is_idle() self:decide_enabled() end
function Logo:on_prop_idlescreen() self:decide_enabled() end

function Logo:render()
	if Menu:is_open() then return end

	local ass = assdraw.ass_new()
	local scale = state.scale
	local scale_percent = scale * 100

	-- 中央 logo 独立倍率（只影响空闲页中央标记，不影响底部栏等其它 UI）
	--   0  = 自动，按窗口高度换算，与 mpv-lazy 的 auto_ui_scale() 完全一致
	--   >0 = 手动倍率，在现有 scale 基础上再乘
	local factor = options.idlelogo_scale
	if type(factor) ~= 'number' or factor < 0 then factor = 1 end
	if factor == 0 then
		local dw = mp.get_property_number('display-width', 0)
		local dh = mp.get_property_number('display-height', 0)
		local auto = 1
		if dw > 0 and dh > 0 then
			local v = (dw / dh >= 1) and (dh / 1080) or (dw / 1080)
			auto = tonumber(string.format('%.2f', v)) or 1
		end
		factor = scale > 0 and (auto / scale) or 1
	end
	if factor <= 0 then factor = 1 end

	-- logo is rendered at 2^(5-1) = 16 times resolution with size 1800x1800
	-- 1800/16 = 112.5，故 fscx/fscy 也要同样乘 factor，否则图标与占位高度对不上
	local logo_size = 112.5 * scale * factor
	local font_size = 40 * scale * factor
	local spacing = 10 * scale * factor
	local draw_percent = scale_percent * factor
	local total_height = logo_size + font_size + spacing
	local icon_x = (display.width - logo_size) / 2
	local icon_y = (display.height - total_height) / 2
	local scaled_icon_x = (display.width - logo_size) / 2
	local line_prefix = ('{\\rDefault\\an7\\1a&H00&\\bord0\\shad0\\pos(%f,%f)\\fscx%f\\fscy%f}'):format(scaled_icon_x, icon_y, draw_percent, draw_percent)

	-- mpv logo
	for _, line in ipairs(self.logo_lines) do
		ass:new_event()
		ass:append(line_prefix .. line)
	end

	if options.idlemsg == 'default' then
		state.idlemsg = ''
	else
		state.idlemsg = options.idlemsg
	end
	ass:txt(display.width / 2, icon_y + logo_size + spacing, 8, tostring(state.idlemsg), {size = font_size})

	return ass
end

return Logo
