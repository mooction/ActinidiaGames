--[[
Module:			rpghero
Description:	RPG hero
Require:		rpgmap
TODO:
	global:		rpghero = load(GetText("res\\lua\\rpghero.lua"))()
	current.OnCreate:	rpghero.prepare(path_circle, path_circle_touch)
	current.OnPaint:	rpghero.draw(g_temp)
	current.OnClose:	rpghero.free()
]]
local rpghero = {
	xhero = 0, 			-- 主角左下角初始坐标
	yhero = 0,

	herowidth = 32,		-- 常量：英雄图宽度
	heroheight = 48,
	direct = 0, 		-- 主角朝向（下左右上0123）
	frame = 0,

	g_hero = nil,
	xoffset = 0,		-- x视野偏移
	yoffset = 0,		-- y视野偏移

	prepare = function(path_hero)
		rpghero.yhero = 5*rpgmap.sidelen-1
		rpghero.g_hero = GetImage(path_hero)
	end,

	-- OnPaint中将三个图形层叠加到g_temp
	draw = function(g_temp, canvas_width, canvas_height)
		PasteToImageEx(g_temp,rpgmap.g_floor,0,0,canvas_width,canvas_height,
			rpghero.xoffset,rpghero.yoffset,canvas_width,canvas_height)
		PasteToImageEx(g_temp,rpgmap.g_obj,0,0,canvas_width,canvas_height,
			rpghero.xoffset,rpghero.yoffset,canvas_width,canvas_height)
		PasteToImageEx(g_temp,rpghero.g_hero,rpghero.xhero-rpghero.xoffset,rpghero.yhero-rpghero.heroheight-rpghero.yoffset,rpghero.herowidth,rpghero.heroheight,
			rpghero.herowidth*rpghero.frame,rpghero.heroheight*rpghero.direct,rpghero.herowidth,rpghero.heroheight)
		PasteToImageEx(g_temp,rpgmap.g_vir,0,0,canvas_width,canvas_height,
			rpghero.xoffset,rpghero.yoffset,canvas_width,canvas_height)
	end,

	-- OnPaint中计算视野偏移量
	calcoffset = function(canvas_width, canvas_height)
		if rpghero.direct == 1 or rpghero.direct == 2 then
			if rpghero.xhero<canvas_width//2 then
				rpghero.xoffset = 0
			elseif rpghero.xhero > rpgmap.pixelwidth - canvas_width//2 then
				rpghero.xoffset = rpgmap.pixelwidth - canvas_width
			else
				rpghero.xoffset = rpghero.xhero - canvas_width//2 
			end
		else
			if rpghero.yhero<canvas_height//2 then
				rpghero.yoffset = 0
			elseif rpghero.yhero > rpgmap.pixelheight - canvas_height//2 then
				rpghero.yoffset = rpgmap.pixelheight - canvas_height
			else
				rpghero.yoffset = rpghero.yhero - canvas_height//2 
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

		if rpghero.direct == 0 then		-- 下
			rpghero.yhero = rpghero.yhero+hero_speed
			if rpghero.yhero > rpgmap.pixelheight then 
			 	rpghero.yhero = rpgmap.pixelheight-1
			 	do return rpghero.xhero,rpghero.yhero,0,0 end 
			end
			i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero) -- 左下角
			m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero) -- 右下角
			p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero)	-- 正前方
			if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end
			elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.xhero = rpghero.xhero-1
			elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.xhero = rpghero.xhero+1
			else
				rpghero.yhero = (j-1)*rpgmap.sidelen-1
			end
		elseif rpghero.direct == 3 then	-- 上
			rpghero.yhero = rpghero.yhero-hero_speed
			if rpghero.yhero < rpgmap.sidelen then 
			 	rpghero.yhero = rpgmap.sidelen-1
			 	do return rpghero.xhero,rpghero.yhero,0,0 end 
			end
			i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen+1) -- 左上角
			m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen+1) -- 右上角
			p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero-rpgmap.sidelen+1)	-- 正前方
			if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end 
			elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.xhero = rpghero.xhero-1
			elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.xhero = rpghero.xhero+1
			else
				rpghero.yhero = (j+1)*rpgmap.sidelen-1
			end
		elseif rpghero.direct == 1 then	-- 左
			rpghero.xhero = rpghero.xhero-hero_speed
			if rpghero.xhero < 0 then 
				rpghero.xhero = 0
				do return rpghero.xhero,rpghero.yhero,0,0 end 
			end
			i,j= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen+1) -- 左上角
			m,n= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero) -- 左下角
			p,q= rpghero.pixeltologic(rpghero.xhero,rpghero.yhero-rpgmap.sidelen//2)	-- 正前方
			if obj[i][j] == 0 and obj[m][n] == 0 then do return rpghero.xhero,rpghero.yhero,p,q end 
			elseif obj[i][j] == 0 and obj[m][n] ~= 0 then rpghero.yhero = rpghero.yhero-1
			elseif obj[i][j] ~= 0 and obj[m][n] == 0 then rpghero.yhero = rpghero.yhero+1
			else
				rpghero.xhero = i*rpgmap.sidelen
			end
		elseif rpghero.direct == 2 then	-- 右
			rpghero.xhero = rpghero.xhero+hero_speed
			if rpghero.xhero > rpgmap.pixelwidth - rpgmap.sidelen then 
				rpghero.xhero = rpgmap.pixelwidth - rpgmap.sidelen -1
				do return rpghero.xhero,rpghero.yhero,0,0 end 
			end
			i,j= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen+1) -- 右上角
			m,n= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero) -- 右下角
			p,q= rpghero.pixeltologic(rpghero.xhero+rpgmap.sidelen-1,rpghero.yhero-rpgmap.sidelen//2)	-- 正前方
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
		if rpghero.direct == 0 then		-- 下
			if rpghero.yhero+2 > rpgmap.pixelheight then 
			 	do return 0,0 end 
			end
			do return rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero end
		elseif rpghero.direct == 3 then	-- 上
			if rpghero.yhero-2 < rpgmap.sidelen then 
			 	do return 0,0 end 
			end
			do return rpghero.xhero+rpgmap.sidelen//2,rpghero.yhero-rpgmap.sidelen+1 end
		elseif rpghero.direct == 1 then	-- 左
			if rpghero.xhero-2 < 0 then 
				do return 0,0 end 
			end
			do return rpghero.xhero,rpghero.yhero-rpgmap.sidelen//2 end
		elseif rpghero.direct == 2 then	-- 右
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