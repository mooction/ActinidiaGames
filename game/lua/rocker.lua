--[[
Module:         rocker
Description:    Rocker implement
Usage:
    global:     rocker = load(GetText("lua/rocker.lua"))()
    current.OnCreate:   rocker.prepare(path_circle, path_circle_touch)
    current.OnPaint:    rocker.draw(g_temp, mouse_x, mouse_y)
    current.OnClose:    rocker.free()
]]
local rocker = {
    left = 60,
    bottom = 60,

    g_circle = nil,
    circle_r = 0,
    circle_x = 0,
    circle_y = 0,
    
    g_circle_touch = nil,
    circle_touch_r = 0,

    prepare = function(path_circle, path_circle_touch)
        rocker.g_circle = GetImage(path_circle)
        rocker.circle_r = GetHeight(rocker.g_circle)//2
        rocker.circle_x = rocker.left + rocker.circle_r
        rocker.circle_y = canvas_height - rocker.circle_r - rocker.bottom

        rocker.g_circle_touch = GetImage(path_circle_touch)
        rocker.circle_touch_r = GetHeight(rocker.g_circle_touch)//2
    end,

    -- get the degree from mouse position to center of the circle, range(-90 ~ 270)
    getDegree = function(mouse_x,mouse_y)
        -- devide zero
        if mouse_x == rocker.circle_x then
            do return ((mouse_y<rocker.circle_y and 90) or -90) end
        end
        local temp = (rocker.circle_y - mouse_y)/(mouse_x - rocker.circle_x)
        if mouse_x > rocker.circle_x then
            do return math.deg(math.atan(temp)) end
        else
            do return (math.deg(math.atan(temp))+180) end
        end
    end,

    draw = function(g, mouse_x, mouse_y)
        -- rocker area
        PasteToImage(g,rocker.g_circle,rocker.left,rocker.circle_y-rocker.circle_r)
        -- inside
        if (rocker.circle_x - mouse_x)*(rocker.circle_x - mouse_x) + 
            (rocker.circle_y - mouse_y)*(rocker.circle_y - mouse_y) <= 
            rocker.circle_r*rocker.circle_r then
            PasteToImage(g, rocker.g_circle_touch,
                mouse_x - rocker.circle_touch_r, mouse_y - rocker.circle_touch_r)
            do return end
        end
        -- devide zero
        if mouse_x == rocker.circle_x then
            do return end
        end
        -- outside
        local temp = (rocker.circle_y - mouse_y)/(mouse_x - rocker.circle_x)    -- 除数不为零
        local circle_touch_x = rocker.circle_x - rocker.circle_touch_r
        local circle_touch_y = rocker.circle_y - rocker.circle_touch_r
        if mouse_x > rocker.circle_x then
            PasteToImage(g,rocker.g_circle_touch,
                circle_touch_x + math.floor(rocker.circle_r/math.sqrt(1+temp*temp)),
                circle_touch_y - math.floor(rocker.circle_r*temp/math.sqrt(1+temp*temp)))
        else
            PasteToImage(g,rocker.g_circle_touch,
                circle_touch_x - math.floor(rocker.circle_r/math.sqrt(1+temp*temp)),
                circle_touch_y + math.floor(rocker.circle_r*temp/math.sqrt(1+temp*temp)))
        end
    end,

    free = function()
        DeleteImage(rocker.g_circle)
        DeleteImage(rocker.g_circle_touch)
    end
}
return rocker