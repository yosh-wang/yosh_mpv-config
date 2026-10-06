--------------------------------------------------------------------------------------------------------
-----------------------------------------List Formatting------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

local g = require 'modules.globals'
local o = require 'modules.options'
local fb_utils = require 'modules.utils'
local mp = require 'mp'

local state = g.state
local style = g.style
local ass = g.ass

--- https://www.unicode.org/reports/tr9/#Explicit_Directional_Isolates
local ISOLATE_DIRECTION_START = '\226\129\168' -- U+2068 FIRST STRONG ISOLATE
local ISOLATE_DIRECTION_END = '\226\129\169' -- U+2069 POP DIRECTIONAL ISOLATE

local function draw()
    ass:update()
end

local function remove()
    ass:remove()
end

---@type string[]
local string_buffer = {}

---appends the entered text to the overlay
---@param ... string
local function append(...)
    for i = 1, select("#", ...) do
        table.insert(string_buffer, select(i, ...) or '' )
    end
end

--appends a newline character to the osd
local function newline()
    table.insert(string_buffer, '\\N' .. style.spacer .. '\\N')
end

local function flush_buffer()
    ass.data = table.concat(string_buffer, '')
    string_buffer = {}
end

---detects whether or not to highlight the given entry as being played
---@param v Item
---@return boolean
local function highlight_entry(v)
    if g.current_file.path == nil then return false end
    local full_path = fb_utils.get_full_path(v)
    local alt_path = v.name and g.state.directory..v.name or nil

    if fb_utils.parseable_item(v) then
        return (
            string.find(g.current_file.directory, full_path, 1, true)
            or (alt_path and string.find(g.current_file.directory, alt_path, 1, true))
        ) ~= nil
    else
        return g.current_file.path == full_path
            or (alt_path and g.current_file.path == alt_path)
    end
end

---Escapes unwanted unicode control characters that may affect the rest of the display.
---Currently this only isolates unicode directional overrides.
---Based on: https://github.com/mpv-player/mpv/pull/17606
---@param str string
---@return string
local function unicode_escape(str)
    return ISOLATE_DIRECTION_START..str..ISOLATE_DIRECTION_END
end

---escape ass values and replace newlines
---@param str string
---@param style_reset string?
---@return string
local function ass_escape(str, style_reset)
    return fb_utils.ass_escape(str, style_reset and style.warning..'␊'..style_reset or true)
end

local header_overrides = {}

---@return number start
---@return number finish
---@return boolean is_overflowing
local function calculate_view_window()
    ---@type number
    local start = 1
    ---@type number
    local finish = start+o.num_entries-1

    --handling cursor positioning
    local anchor = state.view_anchor_index or state.selected
    local mid = math.ceil(o.num_entries/2)+1
    if anchor+mid > finish then
        ---@type number
        local offset = anchor - finish + mid

        --if we've overshot the end of the list then undo some of the offset
        if finish + offset > #state.list then
            offset = offset - ((finish+offset) - #state.list)
        end

        start = start + offset
        finish = finish + offset
    end

    --making sure that we don't overstep the boundaries
    if start < 1 then start = 1 end
    local overflow = finish < #state.list
    --this is necessary when the number of items in the dir is less than the max
    if not overflow then finish = #state.list end

    return start, finish, overflow
end

local function count_ass_lines(value)
    local count = 1
    for _ in tostring(value or ""):gmatch("\\N") do count = count + 1 end
    return count
end

local header_is_inline
-- Hit-testing must follow the header that is actually on screen. Recomputing
-- the responsive breakpoint from a newer window size can disagree with the
-- last rendered ASS frame during resize/DPI transitions and shift every row by
-- one phantom tool line.
local rendered_header_is_inline

local function active_header_is_inline()
    if rendered_header_is_inline ~= nil then return rendered_header_is_inline end
    return not header_is_inline or header_is_inline()
end

local function display_width(text)
    local width = 0
    local index = 1
    text = tostring(text or '')
    while index <= #text do
        local byte = text:byte(index)
        if byte < 0x80 then index = index + 1
        elseif byte < 0xE0 then index = index + 2
        elseif byte < 0xF0 then index = index + 3
        else index = index + 4 end
        width = width + (byte < 0x80 and 1 or 2)
    end
    return width
end

-- The bundled Noto Sans Mono CJK font advances by roughly 0.38 em per
-- display-width unit at the file-browser's ASS resolution. Keeping this one
-- metric shared by drawing hitboxes avoids the old byte-count/CJK drift.
local function estimate_text_width(text, font_size)
    return display_width(text) * font_size * 0.38
end

local function mouse_ass_position(position)
    local pos = position or mp.get_property_native("mouse-pos")
    local osd_w = mp.get_property_number("osd-width", 0)
    local osd_h = mp.get_property_number("osd-height", 0)
    if not pos or pos.x == nil or pos.y == nil or osd_h <= 0 or osd_w <= 0 then return nil end
    return pos.x / osd_h * ass.res_y, pos.y / osd_h * ass.res_y,
        osd_w / osd_h * ass.res_y
end

local function list_hit_width(viewport_width)
    local base_font_size = 25
    local max_chars = 0
    for _, list_item in ipairs(state.list) do
        local name = list_item.label or list_item.name or ''
        if #name > max_chars then max_chars = #name end
    end
    local estimated_width = max_chars * base_font_size * 0.65 + base_font_size * 10
    local minimum_hit_width = (viewport_width or 0) * 0.45
    local maximum_hit_width = (viewport_width or math.huge) * 0.55
    return math.min(maximum_hit_width, math.max(minimum_hit_width, estimated_width))
end

local function exit_area_at_position(x, viewport_width)
    if state.hidden or g.ALIGN_X ~= 'left' or g.ALIGN_Y ~= 'top' then return false end
    if not x or not viewport_width or viewport_width <= 0 then return false end
    return x > list_hit_width(viewport_width) and x <= viewport_width
end

local function is_mouse_in_exit_area()
    local x, _, viewport_width = mouse_ass_position()
    return exit_area_at_position(x, viewport_width)
end

local function item_at_position(x, y, viewport_width)
    if state.hidden or #state.list < 1 then return nil end
    if g.ALIGN_X ~= 'left' or g.ALIGN_Y ~= 'top' then return nil end

    local base_font_size = 25
    local start, finish = calculate_view_window()
    local header_line_height = base_font_size * o.scaling_factor_header * 1.15
    local wrapper_line_height = base_font_size * o.scaling_factor_wrappers * 1.15
    -- Each rendered entry contains a body line plus the small spacer line from
    -- newline(). libass advances that pair by about 1.445 em with the bundled
    -- CJK font. Using the older 1.55 estimate made the hit grid roughly 7%
    -- taller than the rendered rows, so the mismatch accumulated farther down
    -- the list even though the first few entries still looked correct.
    local body_line_height = base_font_size * 1.445
    local list_top = count_ass_lines(o.format_string_header) * header_line_height
    -- Long breadcrumbs add the secondary action row plus a 4px breathing row
    -- so title -> tools and tools -> divider share one visual rhythm.
    if not active_header_is_inline() then
        list_top = list_top + 21 * 0.72 + 4
    end

    if o.format_string_topwrapper ~= '' and start > 1 then
        list_top = list_top + count_ass_lines(o.format_string_topwrapper) * wrapper_line_height
    end

    -- Align the first hit cell with the visual midpoint around the first row.
    -- This small virtual-canvas correction scales together with ass.res_y; it
    -- is intentionally independent of physical resolution and Windows DPI.
    local row_grid_offset = base_font_size * 0.11
    -- Keep the original browser interaction: every rendered row owns its full
    -- 36.125px pitch, including the visual breathing space below the glyphs.
    -- This gives the pointer one continuous path through the list instead of
    -- making the selection cursor disappear between adjacent rows.
    local index = start + math.floor((y - (list_top - row_grid_offset)) / body_line_height)
    local item = index >= start and index <= finish and state.list[index] or nil
    if not item then return nil end

    -- Restore the old list-wide horizontal buffer as well. The broad, stable
    -- column is part of the original feel: short labels remain selectable when
    -- the pointer naturally travels through whitespace beside them.
    -- Keep short episode names from collapsing the active column to the glyphs.
    -- A forgiving 45% minimum preserves continuous diagonal pointer travel;
    -- the existing 55% ceiling still leaves the video area inert.
    local hit_width = list_hit_width(viewport_width)
    if x < 0 or x > hit_width then return nil end
    return index
end

local function item_at_mouse(position)
    local x, y, viewport_width = mouse_ass_position(position)
    if not x then return nil end
    return item_at_position(x, y, viewport_width)
end

header_is_inline = function()
    local osd_width = mp.get_property_number('osd-width', 1920)
    local osd_height = mp.get_property_number('osd-height', 1080)
    local aspect = osd_height > 0 and osd_width / osd_height or (16 / 9)
    local capacity = math.max(34, math.min(72, math.floor(aspect * 38)))
    local path = state.directory == '' and 'ROOT' or state.directory_label or state.directory or ''
    local sort_label = mp.get_property('user-data/file-browser/sort-label', '名称↑')
    local tools = string.format('[ 刷新 ]   [ 排序：%s ]   共 %d 项', sort_label, #(state.list or {}))
    return display_width(path) + 4 + display_width(tools) <= capacity
end

local header_action_at_position

---Return the directly clickable action under the mouse on the lighter tool row.
---@return 'refresh'|'sort'|nil
local function header_action_at_mouse()
    if state.hidden or #state.list < 1 then return nil end
    if g.ALIGN_X ~= 'left' or g.ALIGN_Y ~= 'top' then return nil end

    local x, y = mouse_ass_position()
    if not x then return nil end
    return header_action_at_position(x, y)
end

---@param x number ASS virtual X coordinate
---@param y number ASS virtual Y coordinate
---@return 'refresh'|'sort'|nil
header_action_at_position = function(x, y)
    local base_font_size = 25
    local title_font_size = 31
    local tool_font_size = 21
    local left_padding = 14
    local inline = active_header_is_inline()
    -- Restrict clicks to the visible glyph row. The previous broad 0..line
    -- estimate overlapped neighbouring content and made sort clicks refresh.
    local tool_top = inline and tool_font_size * 1.1
        or title_font_size * 1.35 + 4 + tool_font_size * 0.48
    local tool_bottom = tool_top + tool_font_size * 1.1
    if y < tool_top or y >= tool_bottom then return nil end

    if inline then
        local path = state.directory == '' and 'ROOT' or state.directory_label or state.directory or ''
        x = x - left_padding - estimate_text_width(path, title_font_size)
            - estimate_text_width('    ', tool_font_size)
    else
        x = x - left_padding
    end
    local sort_label = mp.get_property('user-data/file-browser/sort-label', '名称↑')
    local refresh_width = estimate_text_width('[ 刷新 ]', tool_font_size)
    local separator_width = estimate_text_width('   ', tool_font_size)
    local sort_width = estimate_text_width('[ 排序：' .. sort_label .. ' ]', tool_font_size)
    if x >= 0 and x < refresh_width then return 'refresh' end
    if x >= refresh_width + separator_width
        and x < refresh_width + separator_width + sort_width then
        return 'sort'
    end
    return nil
end

---@return boolean
local function is_mouse_in_header()
    return header_action_at_mouse() ~= nil
end

---@param i number index
---@return string
local function calculate_item_style(i)
    local is_playing_file = highlight_entry(state.list[i])
    local selected = state.mouse_hover_index or state.selected

    --sets the selection colour scheme
    local multiselected = state.selection[i]

    --sets the colour for the item
    local item_style = style.body

    if multiselected then item_style = item_style..style.multiselect
    elseif i == selected then item_style = item_style..style.selected end

    if is_playing_file then item_style = item_style..(multiselected and style.playing_selected or style.playing) end

    return item_style
end

local function draw_header()
    append(style.header)
    local rendered_header = fb_utils.substitute_codes(o.format_string_header, header_overrides, nil, nil, function(str, code)
        if code == '|' then return str end
        return ass_escape(str, style.header)
    end)
    -- sort.lua inserts extra ASS lines only for the stacked header. Cache the
    -- substituted result from this exact draw so mouse geometry cannot switch
    -- layouts independently when the window or Windows scale changes.
    rendered_header_is_inline = count_ass_lines(rendered_header)
        <= count_ass_lines(o.format_string_header)
    append(rendered_header)
    newline()
end

---@param wrapper_overrides ReplacerTable
local function draw_top_wrapper(wrapper_overrides)
    --adding a header to show there are items above in the list
    append(style.footer_header)
    append(fb_utils.substitute_codes(o.format_string_topwrapper, wrapper_overrides, nil, nil, function(str)
        return ass_escape(str)
    end))
    newline()
end

---@param wrapper_overrides ReplacerTable
local function draw_bottom_wrapper(wrapper_overrides)
    append(style.footer_header)
    append(fb_utils.substitute_codes(o.format_string_bottomwrapper, wrapper_overrides, nil, nil, function(str)
        return ass_escape(str)
    end))
end

---@param i number index
---@param cursor string
local function draw_cursor(i, cursor)
    local selected = state.mouse_hover_index or state.selected

    --handles custom styles for different entries
    if i == selected or i == state.multiselect_start then
        if not (i == selected) then append(style.selection_marker) end

        if not state.multiselect_start then append(style.cursor)
        else
            if state.selection[state.multiselect_start] then append(style.cursor_select)
            else append(style.cursor_deselect) end
        end
    else
        append(g.style.indent)
    end
    append(cursor, '\\h', style.body)
end

--refreshes the ass text using the contents of the list
local function update_ass()
    if state.hidden then state.flag_update = true ; return end

    append(style.global)
    draw_header()

    if #state.list < 1 then
        append(state.empty_text)
        flush_buffer()
        draw()
        return
    end

    local start, finish, overflow = calculate_view_window()

    -- these are the number values to place into the wrappers
    local wrapper_overrides = {['<'] = tostring(start-1), ['>'] = tostring(#state.list-finish)}
    if o.format_string_topwrapper ~= '' and start > 1 then
        draw_top_wrapper(wrapper_overrides)
    end

    for i=start, finish do
        local v = state.list[i]
        append(style.body)
        if g.ALIGN_X ~= 'right' then draw_cursor(i, o.cursor_icon) end

        local item_style = calculate_item_style(i)
        append(item_style)

        --sets the folder icon
        if v.type == 'dir' then
            append(style.folder, o.folder_icon, "\\h", style.body)
            append(item_style)
        end

        --adds the actual name of the item
        append(v.ass or ass_escape( unicode_escape(v.label or v.name) , item_style), '\\h')
        if g.ALIGN_X == 'right' then draw_cursor(i, o.cursor_icon_flipped) end
        newline()
    end

    if o.format_string_bottomwrapper ~= '' and overflow then
        draw_bottom_wrapper(wrapper_overrides)
    end

    flush_buffer()
    draw()
end

---@class ass
return {
    update_ass = update_ass,
    highlight_entry = highlight_entry,
    item_at_mouse = item_at_mouse,
    item_at_position = item_at_position,
    header_action_at_mouse = header_action_at_mouse,
    header_action_at_position = header_action_at_position,
    is_mouse_in_header = is_mouse_in_header,
    is_mouse_in_exit_area = is_mouse_in_exit_area,
    exit_area_at_position = exit_area_at_position,
    view_window = calculate_view_window,
    draw = draw,
    remove = remove,
}
