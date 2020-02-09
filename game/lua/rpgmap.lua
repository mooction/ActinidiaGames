--[[
Module:         rpgmap
Description:    RPG Map
Usage:
    global:     rpgmap = load(GetText("lua/rpgmap.lua"))()
    current.OnCreate:   rpgmap.prepare(path_scene,logicwidth,logicheight,floor,obj,vir)
    current.OnClose:    rpgmap.free()
]]
local rpgmap = {
    sidelen = 32,       -- 常量：磁贴边长
    num_per_line = 16,  -- 常量：场景图片每行磁贴数量

    logicwidth = 0,     -- 逻辑大小
    logicheight = 0,
    pixelwidth = 0,     -- 地图总像素宽度
    pixelheight = 0,

    g_scene = nil,      -- 场景图
    g_floor = nil,      -- 地板缓冲层
    g_obj = nil,        -- 地板缓冲层
    g_vir = nil,        -- 虚拟缓冲层

    -- 初始化三层
    prepare = function(path_scene,lgw,lgh,floor,obj,vir)
        rpgmap.g_scene = GetImage(path_scene)   -- 加载场景
        rpgmap.logicwidth = lgw
        rpgmap.logicheight = lgh
        rpgmap.pixelwidth = lgw*rpgmap.sidelen
        rpgmap.pixelheight = lgh*rpgmap.sidelen
        rpgmap.g_floor = CreateImageEx(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight,0xFF000000)
        rpgmap.g_obj = CreateTransImage(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight)
        rpgmap.g_vir = CreateTransImage(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight)
        for i=1,rpgmap.logicwidth do
            for j=1,rpgmap.logicheight do
                PasteToImageEx(rpgmap.g_floor,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,floor[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    floor[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
                PasteToImageEx(rpgmap.g_obj,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,obj[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    obj[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
                PasteToImageEx(rpgmap.g_vir,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,vir[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    vir[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
            end
        end
    end,

    -- OnPaint中可能需要重建g_floor，删除旧的，返回新的
    reloadfloorlayer = function(floor)
        DeleteImage(rpgmap.g_floor)
        rpgmap.g_floor = CreateImageEx(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight,0xFF000000)
        for i=1,logicwidth do
            for j=1,logicheight do
                PasteToImageEx(rpgmap.g_floor,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,floor[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    floor[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
            end
        end
    end,

    -- OnPaint中可能需要重建g_obj，删除旧的，返回新的
    reloadobjlayer = function(obj)
        DeleteImage(rpgmap.g_obj)
        rpgmap.g_obj = CreateTransImage(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight)
        for i=1,logicwidth do
            for j=1,logicheight do
                PasteToImageEx(rpgmap.g_obj,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,obj[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    obj[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
            end
        end
    end,

    -- OnPaint中可能需要重建g_vir，删除旧的，返回新的
    reloadvirlayer = function(vir)
        DeleteImage(rpgmap.g_vir)
        rpgmap.g_vir = CreateTransImage(rpgmap.sidelen*rpgmap.logicwidth,rpgmap.sidelen*rpgmap.logicheight)
        for i=1,logicwidth do
            for j=1,logicheight do
                PasteToImageEx(rpgmap.g_vir,rpgmap.g_scene,(i-1)*rpgmap.sidelen,(j-1)*rpgmap.sidelen,
                    rpgmap.sidelen,rpgmap.sidelen,vir[i][j]%rpgmap.num_per_line*rpgmap.sidelen,
                    vir[i][j]//rpgmap.num_per_line*rpgmap.sidelen,rpgmap.sidelen,rpgmap.sidelen)
            end
        end
    end,

    free = function()
        DeleteImage(rpgmap.g_floor)
        DeleteImage(rpgmap.g_obj)
        DeleteImage(rpgmap.g_vir)
        DeleteImage(rpgmap.g_scene)
    end
}
return rpgmap