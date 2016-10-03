local core = load(GetText("res\\lua\\core.lua"))()
local rpg = load(GetText("res\\lua\\rpg.lua"))()
local current = {}
--ע�Ᵽ��lua����ΪGBK


--[[ ȫ�ֶ���
======================================================]]

g_scene = nil	-- ����ͼ

g_floor = nil	-- �ذ建���
g_obj = nil 	-- �ذ建���
g_vir = nil		-- ���⻺���
g_hero = nil	-- ����ͼ��

xoffset = 0 	-- x��Ұƫ��
yoffset = 0 	-- y��Ұƫ��

xhero = 0 		-- �������½ǳ�ʼ����
yhero = rpg.sidelen-1
hero_speed = 0 			-- �����˶��ٶȣ���2����4��
hero_direct = 0 		-- ���ǳ�����������0123��
hero_frame = 0
hero_slowfeet = 0 		-- ��ֹ�ŷ�������

do_event = false -- �������ڴ����¼��������������ƶ�
do_id = 0

isSpaceKeyDown = false
isLMouseDown = false
isRMouseDown = false
isFocus = true


--[[ ��Ϣ��Ӧ
======================================================]]

function current.OnCreate()
	g_scene = GetImage("res\\scene\\LAND0.png")	--���س���

	g_floor,g_obj,g_vir = rpg.preparelayers(floor,obj,vir,g_scene,logicwidth,logicheight)

	g_hero = GetImage("res\\role\\npc\\01.png")	-- ��������

	bgm = GetSound("res\\sound\\bgm\\In the Night Garden Closing Theme.mp3",true)
	SetVolume(bgm,0.5)
	PlaySound(bgm)


	-- �Զ���������ݣ�ע����OnClose��ɾ��ʹ�õ���Դ��
	g_box = GetImage("res\\pics\\skin\\conversation-box.png")
	g_portrait = GetImage("res\\role\\portrait\\01-3.png")
	g_portrait2 = GetImage("res\\role\\portrait\\01-2.png")
	g_portrait3 = GetImage("res\\role\\portrait\\01-4.png")

	g_messagebox = GetImage("res\\pics\\skin\\message.png")
	return ""
end

--[[ ע��ֻ��PasteToWnd����WndGraphicָ�룬
	�����ֻ����ImageGraphicָ�� 

	OnPaint�д����¼��������Ҫ�л���ͼ�������µ�ͼ���ļ���
]]
function current.OnPaint(WndGraphic)
	local g_temp = CreateImage(core.screenwidth,core.screenheight)	-- �����
	local x = 0 	-- ��ǰ���߼�x����
	local y = 0 	-- y
	
	if hero_speed ~= 0 and not do_event then
		local pixelwidth = GetWidth(g_floor)
		local pixelheight = GetHeight(g_floor)

		xhero,yhero,x,y = rpg.heromove(xhero,yhero,hero_speed,hero_direct,
			obj,pixelwidth,pixelheight)	-- �����˶�

		if hero_direct == 1 or hero_direct == 2 then		-- ��Ұƫ��
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
		g_hero,xhero,yhero,hero_frame,hero_direct,g_vir,xoffset,yoffset) -- �Ĳ����


	if do_event then	-- �Զ����¼��������������¼���id�������ģ����������¼�֮��id���һ��
		if do_id == 1 then
			if rpg.message(g_temp,g_messagebox,"������һ���컨��",rpg.fadenormal) then
				do_event = false
				do_id = 0
				obj[4][3] = 0
				g_obj = rpg.reloadobjlayer(g_obj,obj,g_scene,logicwidth,logicheight)
			end
		elseif do_id == 3 then
			rpg.talk(g_temp,g_box,g_portrait2,"����˹�ض�","��������á�")
		elseif do_id == 4 then
			rpg.talk(g_temp,g_box,g_portrait3,"����˹�ض�","ѽ��")
		elseif do_id == 5 then
			do return "res\\lua\\001.lua" end	-- �л�����		
		else
			do_event = false
			do_id = 0
		end 

	elseif x==4 and y==3  then	-- �¼�����
		if obj[4][3] ~= 0 then
			do_event = true
			do_id = 1
		end
	elseif x==16 and y==9 then 
		do_event = true
		do_id = 3
	end

	
	PasteToWnd(WndGraphic,g_temp)	-- ��ʾ
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

	-- �Զ���ж������
	DeleteImage(g_box)
	DeleteImage(g_portrait)
	DeleteImage(g_portrait2)
	DeleteImage(g_portrait3)

	DeleteImage(g_messagebox)
	return 0 -- 0�˳�1ȡ��
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
			local bgm = GetSound("res\\sound\\core\\����.wav",false)
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

function current.OnLButtonUp(x,y)
	isRMouseDown = false
end

function current.OnSetFocus()
	isFocus = true
end

function current.OnKillFocus()
	isFocus = false
end

function current.OnMouseWheel(zDeta,x,y)
	
end

logicwidth = 26 -- ��Ȧ��������(24-32)
logicheight = 18 -- �����������֣�16-24��
-- ���µ�ͼ��Ϣ��ActinidiaMapEditor����
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