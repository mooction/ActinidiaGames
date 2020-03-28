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
    printer.prepare(printer, "pics/texts/001.png", 36)
    rpgcommon.prepare("pics/skin/conversation-box.png","pics/skin/message.png",
        "pics/skin/dialog.png","pics/skin/ok_cancel.png")
    rpgmap.prepare("scene/pokemon_1.png",logicwidth,logicheight,floor,obj,vir)
    rpghero.prepare("role/npc/01.png")
    rocker.prepare("pics/skin/circle.png", "pics/skin/circle_touch.png")
    abkey.prepare("pics/skin/key_a.png", "pics/skin/key_b.png")

    bgm = GetSound("sound/bgm/In the Night Garden Closing Theme.mp3",true)
    SetVolume(bgm,0.5)
    PlaySound(bgm)

    g_portrait = GetImage("role/portrait/01-1.png")
    g_portrait2 = GetImage("role/portrait/01-3.png")
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
            rpgcommon.talk(g_temp,g_portrait,0,1)
        elseif do_id == 3 then
            rpgcommon.talk(g_temp,g_portrait,0,2)
        elseif do_id == 4 then
            rpgcommon.talk(g_temp,g_portrait2,0,3)
        elseif do_id == 6 then
            do return "lua/002.lua" end -- 切换场景
        else
            do_event = false
            do_id = 0
        end
        
    elseif x==6 and y==12  then -- 事件捕获
        do_event = true
        do_id = 1
    elseif x==29 and y==5 then
        do_event = true
        do_id = 3
    elseif x==28 and y==4 then
        do_event = true
        do_id = 6
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

logicwidth = 30 -- 内圈大括号数(24-32)
logicheight = 16 -- 大括号内数字（16-24）
-- 以下地图信息由ActinidiaMapEditor生成
floor = {
{1, 16, 1, 16, 16, 16, 16, 16, 1, 1, 1, 1, 16, 1, 16, 1},
{1, 1, 1, 1, 1, 16, 16, 1, 1, 1, 1, 2, 2, 16, 16, 16},
{16, 1, 1, 1, 1, 198, 214, 230, 1, 16, 1, 2, 2, 1, 16, 16},
{16, 16, 1, 1, 1, 199, 215, 231, 1, 2, 2, 2, 2, 1, 1, 1},
{16, 1, 1, 1, 0, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 16},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 1},
{1, 16, 1, 16, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1},
{3, 3, 1, 16, 1, 1, 16, 1, 1, 1, 1, 1, 1, 2, 2, 1},
{16, 1, 1, 16, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 16},
{16, 1, 1, 1, 16, 1, 16, 16, 1, 1, 2, 1, 2, 1, 1, 1},
{16, 1, 1, 1, 3, 1, 1, 16, 1, 1, 1, 1, 1, 1, 2, 1},
{1, 1, 1, 1, 1, 2, 2, 2, 3, 1, 1, 1, 1, 1, 1, 1},
{16, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 16},
{3, 1, 1, 2, 1, 2, 16, 1, 3, 1, 1, 1, 1, 1, 1, 1},
{16, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16},
{16, 16, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{16, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 16, 16},
{16, 16, 1, 1, 3, 3, 3, 1, 1, 1, 1, 2, 1, 1, 16, 16},
{16, 16, 2, 2, 2, 3, 3, 1, 2, 1, 1, 1, 1, 16, 16, 16},
{1, 16, 16, 2, 2, 3, 3, 1, 1, 2, 2, 1, 1, 1, 1, 1},
{16, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 2, 1, 1, 1, 1},
{16, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
{3, 16, 1, 1, 1, 128, 144, 160, 1, 1, 1, 1, 1, 1, 1, 1},
{16, 3, 1, 2, 1, 129, 145, 161, 1, 1, 1, 1, 16, 16, 1, 16},
{1, 1, 1, 1, 1, 129, 145, 161, 2, 1, 1, 16, 16, 16, 16, 1},
{1, 1, 1, 1, 2, 130, 146, 162, 1, 1, 1, 1, 1, 1, 1, 16},
{1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 16},
{1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 16},
{1, 1, 1, 1, 1, 2, 3, 1, 1, 1, 1, 1, 16, 16, 16, 1},
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 1, 16, 16}}
obj = {
{0, 0, 325, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 376, 363, 379, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 377, 364, 380, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 377, 365, 381, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 377, 366, 382, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 378, 367, 383, 0, 0, 0, 0, 0, 0, 280, 0, 0, 0, 0},
{0, 0, 326, 53, 355, 356, 0, 69, 85, 101, 117, 133, 0, 0, 0, 0},
{0, 0, 326, 0, 356, 0, 0, 70, 86, 102, 118, 134, 0, 0, 0, 0},
{0, 0, 326, 0, 0, 0, 0, 71, 87, 103, 119, 135, 0, 0, 0, 0},
{0, 278, 311, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 326, 312, 328, 344, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 326, 313, 329, 345, 0, 0, 0, 0, 0, 155, 171, 187, 203, 0, 0},
{0, 326, 314, 330, 346, 0, 0, 0, 0, 0, 156, 172, 188, 204, 0, 0},
{0, 326, 315, 331, 347, 0, 0, 0, 0, 0, 157, 173, 189, 205, 0, 0},
{0, 279, 295, 295, 295, 295, 310, 0, 0, 0, 158, 174, 190, 206, 0, 0},
{0, 0, 316, 332, 348, 18, 326, 0, 0, 0, 159, 175, 191, 207, 0, 0},
{0, 0, 317, 333, 349, 0, 326, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 318, 334, 350, 0, 327, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 319, 335, 351, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{18, 0, 0, 18, 0, 0, 0, 0, 390, 384, 384, 384, 384, 384, 384, 384},
{0, 22, 38, 20, 36, 0, 0, 0, 368, 29, 45, 45, 45, 45, 45, 45},
{0, 23, 39, 21, 37, 0, 0, 0, 368, 30, 46, 46, 46, 46, 46, 46},
{0, 0, 0, 0, 0, 0, 0, 0, 368, 30, 46, 95, 47, 47, 47, 47},
{0, 0, 0, 0, 0, 0, 0, 0, 368, 30, 62, 17, 0, 0, 0, 0},
{0, 42, 25, 41, 0, 0, 0, 0, 368, 30, 62, 0, 0, 0, 0, 0},
{36, 28, 91, 107, 0, 0, 0, 0, 368, 30, 46, 94, 45, 45, 61, 0},
{37, 28, 92, 108, 0, 0, 0, 0, 368, 30, 46, 46, 46, 46, 62, 0},
{133, 28, 92, 125, 0, 0, 0, 0, 368, 30, 46, 46, 47, 47, 63, 0},
{134, 28, 92, 108, 52, 0, 0, 0, 368, 30, 46, 62, 0, 0, 0, 0},
{135, 28, 92, 108, 0, 0, 0, 0, 368, 30, 46, 62, 0, 0, 0, 0}}
vir={
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 360, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 361, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 361, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 361, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 362, 0, 0, 0, 0, 0, 0, 0, 0, 264, 0, 0, 0, 0, 0},
{0, 0, 323, 339, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 323, 340, 0, 0, 54, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 296, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 297, 0, 0, 0, 0, 0, 0, 0, 139, 0, 0, 0, 0, 0, 0},
{0, 298, 0, 0, 0, 0, 0, 0, 0, 140, 0, 0, 0, 0, 0, 0},
{0, 299, 0, 0, 0, 0, 0, 0, 0, 141, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 142, 0, 0, 0, 0, 0, 0},
{0, 300, 0, 0, 0, 0, 0, 0, 0, 143, 0, 0, 0, 0, 0, 0},
{0, 301, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 302, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 303, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}

return current