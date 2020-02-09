--[[
Module:         rpghero
Description:    RPG hero
Require:        rpgmap
Usage:
    global:     rpghero = load(GetText("lua/rpghero.lua"))()
    current.OnCreate:   rpghero.prepare(path_circle, path_circle_touch)
    current.OnPaint:    rpghero.draw(g_temp)
    current.OnClose:    rpghero.free()
]]
local rpghero = {
    xhero = 0,          -- 主角左下角初始坐标
    yhero = 0,

    hero_width = 32,        -- 常量：英雄图宽度
    hero_height = 48,
    direct = 0,         -- 主角朝向（下左右上0123）
    frame = 0,

    sight_width=768,
    sight_height=512,
    hero_width2=0,
    hero_height2=0,

    g_hero = nil,
    xoffset = 0,        -- x视野偏移
    yoffset = 0,        -- y视野偏移

    prepare = function(path_hero)
        rpghero.hero_width2 = rpghero.hero_width*canvas_width//rpghero.sight_width
        rpghero.hero_height2 = rpghero.hero_height*canvas_height//rpghero.sight_height
        rpghero.yhero = 5*rpgmap.sidelen-1
        rpghero.g_hero = GetImage(path_hero)
    end,

    -- OnPaint中将四个图形层叠加到g_temp
    draw = function(g_temp)
        -- 创建一个缓冲层，把四层叠加到这里，这样做的目的是不用进行四次拉伸
        local g = CreateImage(rpghero.sight_width,rpghero.sight_height)

        PasteToImageEx(g,rpgmap.g_floor,0,0,rpghero.sight_width,rpghero.sight_height,
            rpghero.xoffset,rpghero.yoffset,rpghero.sight_width,rpghero.sight_height)
        PasteToImageEx(g,rpgmap.g_obj,0,0,rpghero.sight_width,rpghero.sight_height,
            rpghero.xoffset,rpghero.yoffset,rpghero.sight_width,rpghero.sight_height)
        PasteToImageEx(g,rpghero.g_hero,rpghero.xhero-rpghero.xoffset,rpghero.yhero-rpghero.hero_height-rpghero.yoffset,rpghero.hero_width,rpghero.hero_height,
            rpghero.hero_width*rpghero.frame,rpghero.hero_height*rpghero.direct,rpghero.hero_width,rpghero.hero_height)
        PasteToImageEx(g,rpgmap.g_vir,0,0,rpghero.sight_width,rpghero.sight_height,
            rpghero.xoffset,rpghero.yoffset,rpghero.sight_width,rpghero.sight_height)

        -- 最后一次性进行拉伸，这样效率更高
        PasteToImageEx(g_temp,g,0,0,canvas_width,canvas_height,0,0,rpghero.sight_width,rpghero.sight_height)
        DeleteImage(g)
    end,

    -- OnPaint中计算视野偏移量
    calcoffset = function()
        if rpghero.direct == 1 or rpghero.direct == 2 then
            if rpghero.xhero < rpghero.sight_width//2 then
                rpghero.xoffset = 0
            elseif rpghero.xhero > rpgmap.pixelwidth - rpghero.sight_width//2 then
                rpghero.xoffset = rpgmap.pixelwidth - rpghero.sight_width
            else
                rpghero.xoffset = rpghero.xhero - rpghero.sight_width//2 
            end
        else
            if rpghero.yhero < rpghero.sight_height//2 then
                rpghero.yoffset = 0
            elseif rpghero.yhero > rpgmap.pixelheight - rpghero.sight_height//2 then
                rpghero.yoffset = rpgmap.pixelheight - rpghero.sight_height
            else
                rpghero.yoffset = rpghero.yhero - rpghero.sight_height//2 
            end
        end
    end,

    -- 将像素坐标转换为逻辑坐标
    pixeltologic = function(x,y)
        x = x//rpgmap.sidelen+1
        y = y//rpgmap.sidelen+1
        return x,y
    end,

    -- OnPaint中处理人物运动，返回新的像素xy坐标及人物正前方逻辑pq坐标
    move = function(hero_speed,obj)
        local i = 0
        local j = 0
        local m = 0
        local n = 0

        local p = 0 -- 正前方obj的逻辑坐标
        local q = 0 -- 用于判断事件

        if rpghero.direct == 0 then     -- 下
            rpghero.yhero = rpghero.yhero+hero_speed
            if rpghero.yhero > rpgmap.pixelheight then 
                rpghero.yhero = rpgmap.pixelheight-1
                do return rpghero.xhero,rpghero.yhero,0,0 end 
            end
            i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero) -- 左下角
            m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero) -- 右下角
            p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero)    -- 正前方
            if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end
            elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.xhero = rpghero.xhero-1
            elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.xhero = rpghero.xhero+1
            else
                rpghero.yhero = (j-1)*rpgmap.sidelen-1
            end
        elseif rpghero.direct == 3 then -- 上
            rpghero.yhero = rpghero.yhero-hero_speed
            if rpghero.yhero < rpgmap.sidelen then 
                rpghero.yhero = rpgmap.sidelen-1
                do return rpghero.xhero,rpghero.yhero,0,0 end 
            end
            i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen+1) -- 左上角
            m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen+1) -- 右上角
            p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero-rpgmap.sidelen+1)   -- 正前方
            if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end 
            elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.xhero = rpghero.xhero-1
            elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.xhero = rpghero.xhero+1
            else
                rpghero.yhero = (j+1)*rpgmap.sidelen-1
            end
        elseif rpghero.direct == 1 then -- 左
            rpghero.xhero = rpghero.xhero-hero_speed
            if rpghero.xhero < 0 then 
                rpghero.xhero = 0
                do return rpghero.xhero,rpghero.yhero,0,0 end 
            end
            i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen+1) -- 左上角
            m,n= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero) -- 左下角
            p,q= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen//2)    -- 正前方
            if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end 
            elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.yhero = rpghero.yhero-1
            elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.yhero = rpghero.yhero+1
            else
                rpghero.xhero = i*rpgmap.sidelen
            end
        elseif rpghero.direct == 2 then -- 右
            rpghero.xhero = rpghero.xhero+hero_speed
            if rpghero.xhero > rpgmap.pixelwidth - rpgmap.sidelen then 
                rpghero.xhero = rpgmap.pixelwidth - rpgmap.sidelen -1
                do return rpghero.xhero,rpghero.yhero,0,0 end 
            end
            i,j= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen+1) -- 右上角
            m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero) -- 右下角
            p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen//2)   -- 正前方
            if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end 
            elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.yhero = rpghero.yhero-1
            elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.yhero = rpghero.yhero+1
            else
                rpghero.xhero = (i-2)*rpgmap.sidelen
            end
        end
        return p,q
    end,

    -- 计算人物正前方的像素坐标，返回xy，如果前方越界返回0,0
    forward = function ()
        if rpghero.direct == 0 then     -- 下
            if rpghero.yhero+2 > rpgmap.pixelheight then 
                do return 0,0 end 
            end
            do return rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero end
        elseif rpghero.direct == 3 then -- 上
            if rpghero.yhero-2 < rpgmap.sidelen then 
                do return 0,0 end 
            end
            do return rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero-rpgmap.sidelen+1 end
        elseif rpghero.direct == 1 then -- 左
            if rpghero.xhero-2 < 0 then 
                do return 0,0 end 
            end
            do return rpghero.xhero,rpghero.yhero-rpgmap.sidelen//2 end
        elseif rpghero.direct == 2 then -- 右
            if rpghero.xhero+2 > rpgmap.pixelwidth - rpgmap.sidelen then 
                do return 0,0 end 
            end
            do return rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen//2 end
        end
    end,

    free = function()
        DeleteImage(rpghero.g_hero)
    end
}
return rpghero