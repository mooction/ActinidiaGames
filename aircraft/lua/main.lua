--[[
+======================================+
|            DO NOT MODIFY             |
+======================================+
]]
-- entrance
core = load(GetText("lua/core.lua"))()

local custom = nil
function OnCreate()
    script = load(GetText("lua/001.lua"))
    if not script then 
        do return "cannot load specific script" end 
    end
    custom = script()
    custom.OnCreate()   -- enter
    return ""
end

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

function OnClose()
    custom.OnClose()
end

function OnKeyDown(nChar)
    custom.OnKeyDown(nChar)
end

function OnKeyUp(nChar)
    custom.OnKeyUp(nChar)
end

function OnLButtonDown(x,y)
    custom.OnLButtonDown(x,y)
end

function OnLButtonUp(x,y)
    custom.OnLButtonUp(x,y)
end

function OnMouseMove(x,y)
    custom.OnMouseMove(x,y)
end

function OnSetFocus()
    custom.OnSetFocus()
end

function OnKillFocus()
    custom.OnKillFocus()
end

function OnMouseWheel(zDeta,x,y)
    custom.OnMouseWheel(zDeta,x,y)
end