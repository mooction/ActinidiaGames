--[[
Module:         abkey
Description:    AB Key
Usage:
    global:     abkey = load(GetText("lua/abkey.lua"))()
    current.OnCreate:   abkey.prepare(path_keya, path_keyb)
    current.OnPaint:    abkey.draw(g_temp)
    current.OnClose:    abkey.free()
]]
local abkey = {
    right_a = 160,
    bottom_a = 120,
    right_b = 60,
    bottom_b = 60,

    g_keya = nil,
    keya_r = 0,
    keya_x = 0,
    keya_y = 0,
    keyb_r = 0,
    keyb_x = 0,
    keyb_y = 0,

    prepare = function(path_keya, path_keyb)
        abkey.g_keya = GetImage(path_keya)
        abkey.keya_r = GetHeight(abkey.g_keya)//2
        abkey.keya_x = canvas_width - abkey.right_a - abkey.keya_r
        abkey.keya_y = canvas_height - abkey.bottom_a - abkey.keya_r

        abkey.g_keyb = GetImage(path_keyb)
        abkey.keyb_r = GetHeight(abkey.g_keyb)//2
        abkey.keyb_x = canvas_width - abkey.right_b - abkey.keyb_r
        abkey.keyb_y = canvas_height - abkey.bottom_b - abkey.keyb_r
    end,

    draw = function(g)
        PasteToImage(g,abkey.g_keya,abkey.keya_x-abkey.keya_r,abkey.keya_y-abkey.keya_r)
        PasteToImage(g,abkey.g_keyb,abkey.keyb_x-abkey.keyb_r,abkey.keyb_y-abkey.keyb_r)
    end,

    inKeyA = function(mouse_x,mouse_y)
        return ((abkey.keya_x - mouse_x)*(abkey.keya_x - mouse_x) + 
            (abkey.keya_y - mouse_y)*(abkey.keya_y - mouse_y) <= 
            abkey.keya_r*abkey.keya_r)
    end,

    inKeyB = function(mouse_x,mouse_y)
        return ((abkey.keyb_x - mouse_x)*(abkey.keyb_x - mouse_x) + 
            (abkey.keyb_y - mouse_y)*(abkey.keyb_y - mouse_y) <= 
            abkey.keyb_r*abkey.keyb_r)
    end,

    free = function()
        DeleteImage(abkey.g_keya)
        DeleteImage(abkey.g_keyb)
    end
}
return abkey