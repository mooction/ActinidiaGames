--[[
+======================================+
|            DO NOT MODIFY             |
+======================================+
]]
core = load(GetText("lua/core.lua"))()
local custom = nil

--[[
Load resources here.
]]
function OnCreate()
    script = load(GetText("lua/001.lua"))
    if not script then 
        do return "cannot load specific script" end 
    end
    custom = script()
    custom.OnCreate()   -- enter
    return ""
end

--[[
Draw anything here.
]]
function OnPaint(WndGraphic)
    local next_script = custom.OnPaint(WndGraphic)
    if next_script ~= "" then
        script = load(GetText(next_script))
        if script then 
            custom.OnClose()    -- clean
            custom = script()
            custom.OnCreate()   -- enter
        end
    end
end

--[[
Free resources that you created here.
]]
function OnClose()
    custom.OnClose()
end

--[[
The function is called when player pressed any key.
@param nChar The key id pressed by player. See `core.lua` for more infomation.
]]
function OnKeyDown(nChar)
    custom.OnKeyDown(nChar)
end

--[[
The function is called when player released any key.
@param nChar The key id released by player. See `core.lua` for more infomation.
]]
function OnKeyUp(nChar)
    custom.OnKeyUp(nChar)
end

--[[
The function is called when player touch the screen or clicked the window.
@param x   If `preferred_width` is set in `config.ini`,
           the range is [0, preferred_width], else [0, core.screen_width]
@param y   If `preferred_height` is set in `config.ini`,
           the range is [0, preferred_height], else [0, core.screen_height]
]]
function OnLButtonDown(x,y)
    custom.OnLButtonDown(x,y)
end

--[[
The function is called when player released the thumb or mouse left button.
@param x   If `preferred_width` is set in `config.ini`,
           the range is [0, preferred_width], else [0, core.screen_width]
@param y   If `preferred_height` is set in `config.ini`,
           the range is [0, preferred_height], else [0, core.screen_height]
]]
function OnLButtonUp(x,y)
    custom.OnLButtonUp(x,y)
end

--[[
The function is called when player move thumb or mouse on screen.
@param x   If `preferred_width` is set in `config.ini`,
           the range is [0, preferred_width], else [0, core.screen_width]
@param y   If `preferred_height` is set in `config.ini`,
           the range is [0, preferred_height], else [0, core.screen_height]
]]
function OnMouseMove(x,y)
    custom.OnMouseMove(x,y)
end

--[[
When the window get focus, the function is called.
]]
function OnSetFocus()
    custom.OnSetFocus()
end

--[[
When the window lost focus, the function is called.
]]
function OnKillFocus()
    custom.OnKillFocus()
end

--[[
When the user scroll the mouse wheel, the function is called.
@param zDelta  A relative value of mouse wheel
@param x       If `preferred_width` is set in `config.ini`,
               the range is [0, preferred_width], else [0, core.screen_width]
@param y       If `preferred_height` is set in `config.ini`,
               the range is [0, preferred_height], else [0, core.screen_height]
]]
function OnMouseWheel(zDeta,x,y)
    custom.OnMouseWheel(zDeta,x,y)
end
