local mp = require 'mp'
local g = require 'modules.globals'
local ass = require 'modules.ass'
local playlist = require 'modules.playlist'
local movement = require 'modules.navigation.directory-movement'
local cursor = require 'modules.navigation.cursor'
local scanning = require 'modules.navigation.scanning'
local controls = require 'modules.controls'

local mouse = {}
local last_hover_index = nil

local function select_at_pointer(_, position)
    if g.state.hidden or g.state.multiselect_start then
        last_hover_index = nil
        if g.state.mouse_hover_index then
            g.state.mouse_hover_index = nil
            ass.update_ass()
        end
        return false
    end

    -- The observer already gives us the newest mouse position. Re-reading the
    -- property here can still return the previous event on some systems,
    -- leaving AList hover one movement behind until the pointer moves again.
    local index = ass.item_at_mouse(position)
    if not index then
        -- Original behaviour deliberately keeps the last valid hover while the
        -- pointer passes through surrounding whitespace or leaves the column.
        if g.state.mouse_hover_index then return false end
        last_hover_index = nil
        return false
    end
    if index == last_hover_index and g.state.mouse_hover_index == index then return false end

    last_hover_index = index
    g.state.mouse_hover_index = index
    ass.update_ass()
    return index ~= nil
end

function mouse.open_at_pointer(info)
    if info and info.event == 'up' then return end

    local header_action = ass.header_action_at_mouse()
    if header_action == 'refresh' then
        local parser = g.state.parser
        local parser_name = parser and (parser.keybind_name or parser.name)
        if parser_name == 'alist' then
            mp.commandv('script-message', 'alist-refresh-current')
        else
            scanning.rescan()
        end
        return
    elseif header_action == 'sort' then
        mp.commandv('script-message', 'file_browser/sort-cycle')
        return
    end

    local index = ass.item_at_mouse()
    if not index then
        -- Only the stable blank region to the right of the list acts as an
        -- outside click. Vertical breathing space inside the list column keeps
        -- the established hover behaviour and cannot close the browser.
        if ass.is_mouse_in_exit_area() then controls.escape() end
        return
    end

    last_hover_index = nil
    g.state.mouse_hover_index = nil
    g.state.view_anchor_index = nil
    g.state.selected = index
    cursor.disable_select_mode()

    local item = g.state.list[index]
    if not item then return end
    if item.type == 'dir' then
        movement.down_dir()
    else
        playlist.add_files('replace', false)
    end
end

function mouse.scroll_at_pointer(n, wrap)
    if g.state.hidden then return end

    if g.state.multiselect_start then cursor.scroll(n, wrap)
    else cursor.scroll_view(n, wrap) end
end

mp.observe_property("mouse-pos", "native", select_at_pointer)

return mouse
