local rpg = load(GetText("res\\lua\\rpg.lua"))()
local current = {}
--注意保存lua编码为GBK


--[[ 全局定义
======================================================]]
screenwidth = core.screenwidth
screenheight = core.screenheight
core.screenwidth=768
core.screenheight=512

g_scene = nil	-- 场景图

g_floor = nil	-- 地板缓冲层
g_obj = nil 	-- 地板缓冲层
g_vir = nil		-- 虚拟缓冲层
g_hero = nil	-- 主角图像

xoffset = 0 	-- x视野偏移
yoffset = 0 	-- y视野偏移

xhero = 0 		-- 主角左下角初始坐标
yhero = 5*rpg.sidelen-1
hero_speed = 0 			-- 主角运动速度（走2，跑4）
hero_direct = 0 		-- 主角朝向（下左右上0123）
hero_frame = 0
hero_slowfeet = 0 		-- 防止脚发生鬼畜

do_event = false -- 表明正在处理事件，将禁用人物移动
do_id = 0

isSpaceKeyDown = false
isLMouseDown = false
isRMouseDown = false
isFocus = true


--[[ 消息响应
======================================================]]

function current.OnCreate()
	g_scene = GetImage("res\\scene\\LAND1.png")	--加载场景

	g_floor,g_obj,g_vir = rpg.preparelayers(
		floor,obj,vir,g_scene,logicwidth,logicheight)

	g_hero = GetImage("res\\role\\npc\\01.png")	-- 加载主角

	bgm = GetSound("res\\sound\\bgm\\In the Night Garden Closing Theme.mp3",true)
	SetVolume(bgm,0.5)
	PlaySound(bgm)


	-- 自定义加载内容（注意在OnClose中删除使用的资源）
	g_box = GetImage("res\\pics\\skin\\conversation-box.png")
	g_portrait = GetImage("res\\role\\portrait\\01-1.png")
	g_portrait2 = GetImage("res\\role\\portrait\\01-3.png")

	g_loading = GetImage("res\\pics\\sceneloading\\pkq.jpg")
	return ""
end

alpha = 255

--[[ 注意只有PasteToWnd接受WndGraphic指针，
	其余的只接受ImageGraphic指针 

	OnPaint中处理事件，如果需要切换地图，返回新地图的文件名
]]
function current.OnPaint(WndGraphic)
	local g_temp = CreateImage(core.screenwidth,core.screenheight)	-- 缓冲层
	local x = 0 	-- 正前方逻辑x坐标
	local y = 0 	-- y
	
	if hero_speed ~= 0 and not do_event then
		local pixelwidth = GetWidth(g_floor)
		local pixelheight = GetHeight(g_floor)

		xhero,yhero,x,y = rpg.heromove(xhero,yhero,hero_speed,hero_direct,
			obj,pixelwidth,pixelheight)	-- 主角运动

		if hero_direct == 1 or hero_direct == 2 then		-- 视野偏移
			xoffset = rpg.getxoffset(xhero,pixelwidth)
		else
			yoffset = rpg.getyoffset(yhero,pixelheight)
		end

		hero_slowfeet = hero_slowfeet + 1
		if hero_slowfeet == 7 then
			hero_frame = hero_frame + 1
			hero_frame = hero_frame % 4
			hero_slowfeet = 0
		end
	end

	rpg.overlaylayers(g_temp,g_floor,g_obj,
		g_hero,xhero,yhero,hero_frame,hero_direct,g_vir,xoffset,yoffset) -- 四层叠加

	if do_event then	-- 自定义事件处理，两个连续事件的id是连续的，两个独立事件之间id间隔一个
		if do_id == 1 then
			rpg.talk(g_temp,g_box,g_portrait,"克里斯特尔","忍者村？")
		elseif do_id == 3 then
			rpg.talk(g_temp,g_box,g_portrait,"克里斯特尔","隧道完工，今天免费？")
		elseif do_id == 4 then
			rpg.talk(g_temp,g_box,g_portrait2,"克里斯特尔","太棒了！")
		elseif do_id == 6 then
			do return "res\\lua\\002.lua" end	-- 切换场景
		else
			do_event = false
			do_id = 0
		end
		
	elseif x==6 and y==12  then	-- 事件捕获
		do_event = true
		do_id = 1
	elseif x==29 and y==5 then
		do_event = true
		do_id = 3
	elseif x==28 and y==4 then
		do_event = true
		do_id = 6
	end


	if alpha ~= 5 then
		AlphaBlend(g_temp,g_loading,0,0,alpha)
		alpha = alpha -rpg.fadefast
	end


	PasteToWndEx(WndGraphic,g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight)	-- 显示
	DeleteImage(g_temp)
	return ""
end

function current.OnClose()
	DeleteImage(g_floor)
	DeleteImage(g_obj)
	DeleteImage(g_vir)
	DeleteImage(g_hero)
	DeleteImage(g_scene)
	StopSound(bgm)


	-- 自定义卸载内容
	DeleteImage(g_box)
	DeleteImage(g_portrait)
	DeleteImage(g_portrait2)
	DeleteImage(g_loading)
end

function current.OnKeyDown(nChar)
	if nChar == core.vk["VK_DOWN"] then	
		if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
		hero_direct = 0
	elseif nChar == core.vk["VK_UP"] then
		if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
		hero_direct = 3
	elseif nChar == core.vk["VK_LEFT"] then
		if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
		hero_direct = 1
	elseif nChar == core.vk["VK_RIGHT"] then
		if isSpaceKeyDown then hero_speed = 4 else hero_speed =  2 end
		hero_direct = 2
	elseif nChar == core.vk["VK_SPACE"] then
		isSpaceKeyDown = true
		if (2 == hero_speed) then hero_speed = 4 end
	end
end

function current.OnKeyUp(nChar)
	if nChar == core.vk["VK_RETURN"] then
		if (do_event == true) then do_id = do_id +1 end
	elseif nChar == core.vk["VK_DOWN"] then
		if (0 == hero_direct) then hero_speed = 0 end
	elseif nChar == core.vk["VK_UP"] then
		if (3 == hero_direct) then hero_speed = 0 end
	elseif nChar == core.vk["VK_LEFT"] then
		if (1 == hero_direct) then hero_speed = 0 end
	elseif nChar == core.vk["VK_RIGHT"] then
		if (2 == hero_direct) then hero_speed = 0 end
	elseif nChar == core.vk["VK_SPACE"] then
		isSpaceKeyDown = false
		if (4 == hero_speed) then hero_speed = 2 end
	elseif nChar == core.vk["VK_F4"] then
		if Screenshot() then
			local bgm = GetSound("res\\sound\\core\\拍照.wav",false)
			PlaySound(bgm)
		end
	end
end

function current.OnLButtonDown(x,y)
	isLMouseDown = true
end

function current.OnLButtonUp(x,y)
	isLMouseDown = false
end

function current.OnRButtonDown(x,y)
	isRMouseDown = true
end

function current.OnRButtonUp(x,y)
	isRMouseDown = false
end

function current.OnMouseMove(x,y)

end

function current.OnSetFocus()
	isFocus = true
end

function current.OnKillFocus()
	isFocus = false
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
{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16, 1, 16, 16}

}
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
{135, 28, 92, 108, 0, 0, 0, 0, 368, 30, 46, 62, 0, 0, 0, 0}

}
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
{0, 76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

}

return current