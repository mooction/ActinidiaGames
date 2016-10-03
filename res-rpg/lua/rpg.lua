local rpg = {
	sidelen = 32,
	herowidth = 32,
	heroheight = 48,
	nperline = 16,

	txtsmall = 18,
	txtnormal = 22,
	txtbig = 27,
	txtfont = "微软雅黑",

-- defined in core.lua
	screenwidth = 768,
	screenheight = 512,

	black = 0x00181818,
	white = 0x00FFFFFF
}


--[[lua实现
=======================================================]]


-- OnCreate中初始化三层图形
function rpg.preparelayers(_floor,_obj,_vir,_g_scene,_logicwidth,_logicheight)
	local _g_floor = CreateImageEx(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight,0x00000000)
	local _g_obj = CreateTransImage(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight)
	local _g_vir = CreateTransImage(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight)
	for i=1,logicwidth do
		for j=1,logicheight do
			PasteToImageEx(_g_floor,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_floor[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_floor[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
			PasteToImageEx(_g_obj,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_obj[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_obj[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
			PasteToImageEx(_g_vir,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_vir[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_vir[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
		end
	end
	return _g_floor,_g_obj,_g_vir
end

-- OnPaint中可能需要重建g_floor，删除旧的，返回新的
function rpg.reloadfloorlayer(_g_floor,_floor,_g_scene,_logicwidth,_logicheight)
	DeleteImage(_g_floor)
	_g_floor = CreateImageEx(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight,0x00000000)
	for i=1,logicwidth do
		for j=1,logicheight do
			PasteToImageEx(_g_floor,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_floor[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_floor[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
		end
	end
	return _g_floor
end

-- OnPaint中可能需要重建g_obj，删除旧的，返回新的
function rpg.reloadobjlayer(_g_obj,_obj,_g_scene,_logicwidth,_logicheight)
	DeleteImage(_g_obj)
	_g_obj = CreateTransImage(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight)
	for i=1,logicwidth do
		for j=1,logicheight do
			PasteToImageEx(_g_obj,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_obj[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_obj[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
		end
	end
	return _g_obj
end

-- OnPaint中可能需要重建g_vir，删除旧的，返回新的
function rpg.reloadvirlayer(_g_vir,_vir,_g_scene,_logicwidth,_logicheight)
	DeleteImage(_g_vir)
	_g_vir = CreateTransImage(rpg.sidelen*_logicwidth,rpg.sidelen*_logicheight)
	for i=1,logicwidth do
		for j=1,logicheight do
			PasteToImageEx(_g_vir,_g_scene,(i-1)*rpg.sidelen,(j-1)*rpg.sidelen,
				rpg.sidelen,rpg.sidelen,_vir[i][j]%rpg.nperline*rpg.sidelen,
				math.floor(_vir[i][j]/rpg.nperline)*rpg.sidelen,rpg.sidelen,rpg.sidelen)
		end
	end
	return _g_vir
end

-- OnPaint中将三个图形层叠加到g_temp
function rpg.overlaylayers(_g_temp,_g_floor,_g_obj,_g_hero,_xhero,_yhero,_hero_frame,_hero_direct,_g_vir,_xoffset,_yoffset)
	PasteToImageEx(_g_temp,_g_floor,0,0,rpg.screenwidth,rpg.screenheight,
		_xoffset,_yoffset,rpg.screenwidth,rpg.screenheight)
	PasteToImageEx(_g_temp,_g_obj,0,0,rpg.screenwidth,rpg.screenheight,
		_xoffset,_yoffset,rpg.screenwidth,rpg.screenheight)
	PasteToImageEx(_g_temp,_g_hero,_xhero-_xoffset,_yhero-rpg.heroheight-_yoffset,rpg.herowidth,rpg.heroheight,
		rpg.herowidth*_hero_frame,rpg.heroheight*_hero_direct,rpg.herowidth,rpg.heroheight)
	PasteToImageEx(_g_temp,_g_vir,0,0,rpg.screenwidth,rpg.screenheight,
		_xoffset,_yoffset,rpg.screenwidth,rpg.screenheight)
end


-- OnPaint中计算视野x偏移量
function rpg.getxoffset(_xhero,_pixelwidth)
	local _xoffset = 0
	if _xhero<rpg.screenwidth/2 then _xoffset = 0
	elseif _xhero > _pixelwidth - rpg.screenwidth/2 then _xoffset = _pixelwidth - rpg.screenwidth
	else _xoffset = _xhero - rpg.screenwidth /2 
	end
	return _xoffset
end


-- OnPaint中计算视野y偏移量
function rpg.getyoffset(_yhero,_pixelheight)
	local _yoffset = 0
	if _yhero<rpg.screenheight/2 then _yoffset = 0
	elseif _yhero > _pixelheight - rpg.screenheight/2 then	 _yoffset = _pixelheight - rpg.screenheight
	else _yoffset = _yhero - rpg.screenheight /2 
	end
	return _yoffset
end


-- 将像素坐标转换为逻辑坐标
function rpg.pixeltologic(_x,_y)
	_x = math.floor(_x/rpg.sidelen)+1
	_y = math.floor(_y/rpg.sidelen)+1
	return _x,_y
end


-- OnPaint中处理人物运动，返回新的像素xy坐标及人物正前方逻辑pq坐标
function rpg.heromove(_xhero,_yhero,_hero_speed,_hero_direct,_obj,_pixelwidth,_pixelheight)
	local i = 0
	local j = 0
	local m = 0
	local n = 0

	local p = 0 -- 正前方obj的逻辑坐标
	local q = 0 -- 用于判断事件

	if _hero_direct == 0 then		-- 下
		_yhero = _yhero+_hero_speed
		if _yhero > _pixelheight then 
		 	_yhero = _pixelheight-1
		 	do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero) -- 左下角
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero) -- 右下角
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen/2,_yhero)	-- 正前方
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _xhero = _xhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _xhero = _xhero+1
		else
			_yhero = (j-1)*rpg.sidelen-1
		end
	elseif _hero_direct == 3 then	-- 上
		_yhero = _yhero-_hero_speed
		if _yhero < rpg.sidelen then 
		 	_yhero = rpg.sidelen-1
		 	do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen+1) -- 左上角
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen+1) -- 右上角
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen/2,_yhero-rpg.sidelen+1)	-- 正前方
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _xhero = _xhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _xhero = _xhero+1
		else
			_yhero = (j+1)*rpg.sidelen-1
		end
	elseif _hero_direct == 1 then	-- 左
		_xhero = _xhero-_hero_speed
		if _xhero < 0 then 
			_xhero = 0
			do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen+1) -- 左上角
		m,n= rpg.pixeltologic(_xhero,_yhero) -- 左下角
		p,q= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen/2)	-- 正前方
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _yhero = _yhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _yhero = _yhero+1
		else
			_xhero = i*rpg.sidelen
		end
	elseif _hero_direct == 2 then	-- 右
		_xhero = _xhero+_hero_speed
		if _xhero > _pixelwidth - rpg.sidelen then 
			_xhero = _pixelwidth - rpg.sidelen -1
			do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen+1) -- 右上角
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero) -- 右下角
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen/2)	-- 正前方
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _yhero = _yhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _yhero = _yhero+1
		else
			_xhero = (i-2)*rpg.sidelen
		end
	end
	return _xhero,_yhero,p,q
end

-- 计算人物正前方的像素坐标，返回xy，如果前方越界返回0,0
function rpg.heroforward(_xhero,_yhero,_hero_direct,_pixelwidth,_pixelheight)
	if _hero_direct == 0 then		-- 下
		if _yhero+2 > _pixelheight then 
		 	do return 0,0 end 
		end
		do return _xhero+rpg.sidelen/2,_yhero end
	elseif _hero_direct == 3 then	-- 上
		if _yhero-2 < rpg.sidelen then 
		 	do return 0,0 end 
		end
		do return _xhero+rpg.sidelen/2,_yhero-rpg.sidelen+1 end
	elseif _hero_direct == 1 then	-- 左
		if _xhero-2 < 0 then 
			do return 0,0 end 
		end
		do return _xhero,_yhero-rpg.sidelen/2 end
	elseif _hero_direct == 2 then	-- 右
		if _xhero+2 > _pixelwidth - rpg.sidelen then 
			do return 0,0 end 
		end
		do return _xhero+rpg.sidelen-1,_yhero-rpg.sidelen/2 end
	end
end

--[[常用NPC名称
============================================================
莫里（女）
萨利（女）
艾米（女）
戴安娜（女）
克里斯特尔（女）

汤米（男）
莱恩（男）
达夫（男）
皮埃尔（男）
弗雷德（男）
汤普森（男）
韦尔斯（男）
布兰德（男）
温特伯恩（男）
安东尼奥（男）

]]

-- 显示交谈框
function rpg.talk(_g_temp,_g_box,_g_portrait,_title,_text)
	PasteToImage(_g_temp,_g_box,0,rpg.screenheight-GetHeight(_g_box));
	PasteToImage(_g_temp,_g_portrait,10,rpg.screenheight-GetHeight(_g_portrait));
	PrintText(_g_temp, GetWidth(_g_portrait)-50, rpg.screenheight-GetHeight(_g_box)+6,
			 _title, rpg.txtfont, rpg.txtbig, rpg.black)
	PrintText(_g_temp, GetWidth(_g_portrait)-50, rpg.screenheight-GetHeight(_g_box)+38,
			 _text, rpg.txtfont, rpg.txtnormal, rpg.black)
end


local alpha = 255
rpg.fadefast = 5 		-- 4倍速
rpg.fadenormal = 2.5 	-- 2倍速
rpg.fadeslow = 1.25 	-- 1倍速
-- 显示消息框，显示完毕返回true，否则false
-- _deta 必须是 rpg.fadefast,rpg.fadenormal,rpg.fadeslow 中的一种
function rpg.message(_g_temp,_g_messagebox,_text,_deta)
	if alpha ~= 45 then
		local dx = (rpg.screenwidth - GetWidth(_g_messagebox))/2
		local dy = (rpg.screenheight - GetHeight(_g_messagebox))/2
		AlphaBlend(_g_temp,_g_messagebox,dx,dy,math.floor(alpha))
		PrintText(_g_temp,dx+32,dy+36,_text,rpg.txtfont,rpg.txtnormal,rpg.black)
		alpha = alpha -_deta
		return false
	else
		alpha = 255
		return true
	end
end


--***

return rpg