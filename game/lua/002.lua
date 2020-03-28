printer = load(GetText("lua/text_printer.lua"))()
rpgcommon = load(GetText("lua/rpgcommon.lua"))()
rpgmap = load(GetText("lua/rpgmap.lua"))()
rpghero = load(GetText("lua/rpghero.lua"))()
rocker = load(GetText("lua/rocker.lua"))()
abkey = load(GetText("lua/abkey.lua"))()
local current = {}
--注意保存lua编码为UTF-8


--[[ 全局定义
======================================================]]
canvas_width=1024
canvas_height=682

hero_speed = 0          -- 主角运动速度（走2，跑4）
hero_slowfeet = 0       -- 防止脚发生鬼畜

do_event = false -- 表明正在处理事件，将禁用人物移动
do_id = 0

isSpaceKeyDown = false
isLMouseDown = false
mouse_x = 0
mouse_y = 0

--[[ 消息响应
======================================================]]

function current.OnCreate()
    printer.prepare(printer, "pics/texts/002.png",36)
    rpgcommon.prepare("pics/skin/conversation-box.png","pics/skin/message.png",
        "pics/skin/dialog.png","pics/skin/ok_cancel.png")
    rpgmap.prepare("scene/land_0.png",logicwidth,logicheight,floor,obj,vir)
    rpghero.prepare("role/npc/01.png")
    rocker.prepare("pics/skin/circle.png", "pics/skin/circle_touch.png")
    abkey.prepare( "pics/skin/key_a.png", "pics/skin/key_b.png")

    bgm = GetSound("sound/bgm/In the Night Garden Closing Theme.mp3",true)
    SetVolume(bgm,0.5)
    PlaySound(bgm)

    g_portrait = GetImage("role/portrait/01-1.png")
    g_portrait2 = GetImage("role/portrait/01-3.png")
    g_portrait3 = GetImage("role/portrait/01-4.png")
    return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
    local g_temp = CreateImageEx(canvas_width,canvas_height,0xFF000000)
    local x = 0     -- 正前方逻辑x坐标
    local y = 0     -- y
    
    if hero_speed ~= 0 and not do_event then
        x,y = rpghero.move(hero_speed,obj)  -- 主角运动
        rpghero.calcoffset()            -- 视野偏移
        
        hero_slowfeet = hero_slowfeet + 1
        if hero_slowfeet == 7 then
            rpghero.frame = rpghero.frame + 1
            rpghero.frame = rpghero.frame % 4
            hero_slowfeet = 0
        end
    end

    rpghero.draw(g_temp)    -- 显示四层图形

    if do_event then    -- 自定义事件处理，两个连续事件的id是连续的，两个独立事件之间id间隔一个
        if do_id == 1 then
            if rpgcommon.message(g_temp,0,rpgcommon.fade.normal) then
                do_event = false
                do_id = 0
                obj[4][3] = 0
                rpgmap.reloadobjlayer(obj)
            end
        elseif do_id == 3 then
            rpgcommon.talk(g_temp,g_portrait2,1,2)
        elseif do_id == 4 then
            rpgcommon.talk(g_temp,g_portrait3,1,3)
        elseif do_id == 5 then
            do return "lua/001.lua" end -- 切换场景     
        else
            do_event = false
            do_id = 0
        end 

    elseif x==4 and y==3  then  -- 事件捕获
        if obj[4][3] ~= 0 then
            do_event = true
            do_id = 1
        end
    elseif x==16 and y==9 then 
        do_event = true
        do_id = 3
    end

    rocker.draw(g_temp,mouse_x,mouse_y)
    abkey.draw(g_temp)
    
    PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,
        0,0,canvas_width,canvas_height)
    DeleteImage(g_temp)
    return ""
end

function current.OnClose()
    rpghero.free()
    rpgmap.free()
    rpgcommon.free()
    rocker.free()
    abkey.free()
    printer.free(printer)

    StopSound(bgm)
    DeleteImage(g_portrait)
    DeleteImage(g_portrait2)
    DeleteImage(g_portrait3)
end

function current.OnKeyDown(nChar)
    if nChar == core.vk["VK_DOWN"] then 
        if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
        rpghero.direct = 0
    elseif nChar == core.vk["VK_UP"] then
        if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
        rpghero.direct = 3
    elseif nChar == core.vk["VK_LEFT"] then
        if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
        rpghero.direct = 1
    elseif nChar == core.vk["VK_RIGHT"] then
        if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
        rpghero.direct = 2
    elseif nChar == core.vk["VK_SPACE"] then
        isSpaceKeyDown = true
        if (2 == hero_speed) then hero_speed = 4 end
    end
end

function current.OnKeyUp(nChar)
    if nChar == core.vk["VK_RETURN"] then
        if (do_event == true) then do_id = do_id +1 end
    elseif nChar == core.vk["VK_DOWN"] then
        if (0 == rpghero.direct) then hero_speed = 0 end
    elseif nChar == core.vk["VK_UP"] then
        if (3 == rpghero.direct) then hero_speed = 0 end
    elseif nChar == core.vk["VK_LEFT"] then
        if (1 == rpghero.direct) then hero_speed = 0 end
    elseif nChar == core.vk["VK_RIGHT"] then
        if (2 == rpghero.direct) then hero_speed = 0 end
    elseif nChar == core.vk["VK_SPACE"] then
        isSpaceKeyDown = false
        if (4 == hero_speed) then hero_speed = 2 end
    elseif nChar == core.vk["VK_F4"] then
        if Screenshot() then
            local bgm = GetSound("sound/core/screenshot.wav",false)
            PlaySound(bgm)
        end
    end
end

function current.OnLButtonDown(x,y)
    local mouse_x = x
    local mouse_y = y
    if abkey.inKeyA(mouse_x,mouse_y) then
        current.OnKeyDown(core.vk["VK_RETURN"])
    elseif abkey.inKeyB(mouse_x,mouse_y) then
        current.OnKeyDown(core.vk["VK_SPACE"])
    else isLMouseDown = true
    end
end

function current.OnLButtonUp(x,y)
    local mouse_x = x
    local mouse_y = y
    if abkey.inKeyA(mouse_x,mouse_y) then
        current.OnKeyUp(core.vk["VK_RETURN"])
    elseif abkey.inKeyB(mouse_x,mouse_y) then
        current.OnKeyUp(core.vk["VK_SPACE"])
    else 
        isLMouseDown = false
        hero_speed = 0
    end
end

function current.OnMouseMove(x,y)
    mouse_x = x
    mouse_y = y
    if isLMouseDown then
        -- 角度-90到270，下左右上0123
        local v = rocker.getDegree(mouse_x,mouse_y)
        if v>-45 and v<=45 then rpghero.direct = 2
        elseif v>45 and v<=135 then rpghero.direct = 3
        elseif v>135 and v<=225 then rpghero.direct = 1
        else rpghero.direct = 0 end
        if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
    end
end

function current.OnSetFocus()

end

function current.OnKillFocus()
    
end

function current.OnMouseWheel(zDeta,x,y)
    
end

logicwidth = 26 -- 内圈大括号数(24-32)
logicheight = 18 -- 大括号内数字（16-24）
-- 以下地图信息由ActinidiaMapEditor生成
floor = {

{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}

}
obj = {

{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 174, 0, 0, 0, 0, 0, 0, 0, 238, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 39, 0, 0, 0, 537, 0, 0, 152, 152, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 538, 0, 136, 157, 152, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 320, 336, 352, 368, 384, 400, 416, 572, 0, 0, 191, 0, 0, 0, 0},
{0, 0, 0, 321, 337, 353, 369, 385, 401, 417, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 322, 338, 354, 370, 386, 402, 418, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 323, 339, 355, 371, 387, 403, 419, 589, 605, 0, 0, 0, 0, 0, 0},
{0, 36, 0, 324, 340, 356, 372, 388, 404, 420, 590, 606, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 141, 0, 0, 0, 0, 591, 607, 0, 0, 0, 0, 0, 0},
{58, 36, 0, 0, 0, 0, 0, 148, 551, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{59, 0, 0, 69, 0, 0, 0, 0, 552, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{36, 55, 20, 36, 0, 169, 185, 201, 217, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 27, 36, 71, 0, 170, 186, 202, 218, 0, 141, 0, 0, 0, 0, 0, 0, 0},
{36, 71, 5, 254, 0, 171, 187, 203, 219, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{44, 60, 25, 36, 0, 172, 188, 204, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{36, 0, 36, 0, 36, 0, 0, 0, 0, 212, 0, 159, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 40, 212, 0, 0, 29, 0, 0, 0, 528, 544, 0, 0, 0, 0},
{0, 0, 0, 309, 41, 0, 36, 0, 0, 0, 0, 0, 529, 545, 0, 0, 0, 0},
{36, 0, 0, 310, 36, 0, 0, 113, 129, 145, 0, 0, 530, 546, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 212, 0, 114, 130, 146, 0, 254, 0, 0, 0, 0, 0, 0},
{0, 36, 0, 41, 36, 0, 0, 0, 237, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

}
vir={

{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 521, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 522, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 292, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 304, 0, 0, 0, 0, 0, 0, 556, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 289, 305, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 290, 306, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 291, 307, 0, 0, 0, 0, 0, 557, 573, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 308, 375, 432, 0, 0, 0, 558, 574, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 559, 575, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 168, 184, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 154, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 155, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 156, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 173, 189, 205, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 512, 0, 0, 0, 0, 0, 0},
{0, 0, 293, 0, 0, 0, 96, 112, 128, 0, 0, 513, 0, 0, 0, 0, 0, 0},
{0, 0, 294, 0, 0, 81, 97, 0, 0, 0, 0, 514, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 82, 98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 99, 115, 131, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

}

return current