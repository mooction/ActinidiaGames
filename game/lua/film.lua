--[[
Module:         film
Description:    film implement
Usage:
    global:     film = load(GetText("lua/film.lua"))()
    current.OnCreate:   film.add(path_image, id_string)
    current.OnPaint:    film.play(g_temp)
    current.OnClose:    film.free()
]]
local film = {
    g_images = {},
    texts = {},
    count = 0,
    index = 1,
    alpha = -255,
    let_user_watch = 150,

    add = function(path_image, id_string)
        film.count = film.count + 1
        film.g_images[film.count] = GetImage(path_image)
        film.texts[film.count] = id_string
    end,

    -- return true if playing is completed.
    play = function(g)
        if film.index <= film.count then
            local yoffset = (canvas_height - GetHeight(film.g_images[film.index]))//2
            if film.alpha < -1 then
                -- fade in
                AlphaBlend(g,film.g_images[film.index],0,yoffset,255 + film.alpha)
                film.alpha = film.alpha + 2
            end
            if film.alpha == -1 then
                -- critical value
                if film.let_user_watch == 0 then
                    film.alpha = 255
                    film.let_user_watch = 200
                end
                AlphaBlend(g,film.g_images[film.index],0,yoffset,255)
                film.let_user_watch = film.let_user_watch - 1
            end
            if film.alpha > 1 then
                -- fade out
                AlphaBlend(g,film.g_images[film.index],0,yoffset,film.alpha)
                film.alpha = film.alpha - 2
            end
            
            printer.out(g, 32, canvas_height-46, film.texts[film.index], film.alpha)

            if film.alpha == 1 then
                film.alpha = -255
                film.index = film.index + 1
            end
            return false
        else
            return true
        end
    end,

    free = function()
        for i=1,film.count do
            DeleteImage(film.g_images[i])
        end
    end
}
return film