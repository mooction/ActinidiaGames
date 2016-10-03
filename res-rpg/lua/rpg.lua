local rpg = {
	sidelen = 32,
	herowidth = 32,
	heroheight = 48,
	nperline = 16,

	txtsmall = 18,
	txtnormal = 22,
	txtbig = 27,
	txtfont = "΢���ź�",

-- defined in core.lua
	screenwidth = 768,
	screenheight = 512,

	black = 0x00181818,
	white = 0x00FFFFFF
}


--[[luaʵ��
=======================================================]]


-- OnCreate�г�ʼ������ͼ��
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

-- OnPaint�п�����Ҫ�ؽ�g_floor��ɾ���ɵģ������µ�
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

-- OnPaint�п�����Ҫ�ؽ�g_obj��ɾ���ɵģ������µ�
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

-- OnPaint�п�����Ҫ�ؽ�g_vir��ɾ���ɵģ������µ�
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

-- OnPaint�н�����ͼ�β���ӵ�g_temp
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


-- OnPaint�м�����Ұxƫ����
function rpg.getxoffset(_xhero,_pixelwidth)
	local _xoffset = 0
	if _xhero<rpg.screenwidth/2 then _xoffset = 0
	elseif _xhero > _pixelwidth - rpg.screenwidth/2 then _xoffset = _pixelwidth - rpg.screenwidth
	else _xoffset = _xhero - rpg.screenwidth /2 
	end
	return _xoffset
end


-- OnPaint�м�����Ұyƫ����
function rpg.getyoffset(_yhero,_pixelheight)
	local _yoffset = 0
	if _yhero<rpg.screenheight/2 then _yoffset = 0
	elseif _yhero > _pixelheight - rpg.screenheight/2 then	 _yoffset = _pixelheight - rpg.screenheight
	else _yoffset = _yhero - rpg.screenheight /2 
	end
	return _yoffset
end


-- ����������ת��Ϊ�߼�����
function rpg.pixeltologic(_x,_y)
	_x = math.floor(_x/rpg.sidelen)+1
	_y = math.floor(_y/rpg.sidelen)+1
	return _x,_y
end


-- OnPaint�д��������˶��������µ�����xy���꼰������ǰ���߼�pq����
function rpg.heromove(_xhero,_yhero,_hero_speed,_hero_direct,_obj,_pixelwidth,_pixelheight)
	local i = 0
	local j = 0
	local m = 0
	local n = 0

	local p = 0 -- ��ǰ��obj���߼�����
	local q = 0 -- �����ж��¼�

	if _hero_direct == 0 then		-- ��
		_yhero = _yhero+_hero_speed
		if _yhero > _pixelheight then 
		 	_yhero = _pixelheight-1
		 	do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero) -- ���½�
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero) -- ���½�
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen/2,_yhero)	-- ��ǰ��
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _xhero = _xhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _xhero = _xhero+1
		else
			_yhero = (j-1)*rpg.sidelen-1
		end
	elseif _hero_direct == 3 then	-- ��
		_yhero = _yhero-_hero_speed
		if _yhero < rpg.sidelen then 
		 	_yhero = rpg.sidelen-1
		 	do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen+1) -- ���Ͻ�
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen+1) -- ���Ͻ�
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen/2,_yhero-rpg.sidelen+1)	-- ��ǰ��
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _xhero = _xhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _xhero = _xhero+1
		else
			_yhero = (j+1)*rpg.sidelen-1
		end
	elseif _hero_direct == 1 then	-- ��
		_xhero = _xhero-_hero_speed
		if _xhero < 0 then 
			_xhero = 0
			do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen+1) -- ���Ͻ�
		m,n= rpg.pixeltologic(_xhero,_yhero) -- ���½�
		p,q= rpg.pixeltologic(_xhero,_yhero-rpg.sidelen/2)	-- ��ǰ��
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _yhero = _yhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _yhero = _yhero+1
		else
			_xhero = i*rpg.sidelen
		end
	elseif _hero_direct == 2 then	-- ��
		_xhero = _xhero+_hero_speed
		if _xhero > _pixelwidth - rpg.sidelen then 
			_xhero = _pixelwidth - rpg.sidelen -1
			do return _xhero,_yhero,0,0 end 
		end
		i,j= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen+1) -- ���Ͻ�
		m,n= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero) -- ���½�
		p,q= rpg.pixeltologic(_xhero+rpg.sidelen-1,_yhero-rpg.sidelen/2)	-- ��ǰ��
		if _obj[i][j] == 0 and _obj[m][n] == 0 then do return _xhero,_yhero,p,q end 
		elseif _obj[i][j] == 0 and _obj[m][n] ~= 0 then _yhero = _yhero-1
		elseif _obj[i][j] ~= 0 and _obj[m][n] == 0 then _yhero = _yhero+1
		else
			_xhero = (i-2)*rpg.sidelen
		end
	end
	return _xhero,_yhero,p,q
end

-- ����������ǰ�����������꣬����xy�����ǰ��Խ�緵��0,0
function rpg.heroforward(_xhero,_yhero,_hero_direct,_pixelwidth,_pixelheight)
	if _hero_direct == 0 then		-- ��
		if _yhero+2 > _pixelheight then 
		 	do return 0,0 end 
		end
		do return _xhero+rpg.sidelen/2,_yhero end
	elseif _hero_direct == 3 then	-- ��
		if _yhero-2 < rpg.sidelen then 
		 	do return 0,0 end 
		end
		do return _xhero+rpg.sidelen/2,_yhero-rpg.sidelen+1 end
	elseif _hero_direct == 1 then	-- ��
		if _xhero-2 < 0 then 
			do return 0,0 end 
		end
		do return _xhero,_yhero-rpg.sidelen/2 end
	elseif _hero_direct == 2 then	-- ��
		if _xhero+2 > _pixelwidth - rpg.sidelen then 
			do return 0,0 end 
		end
		do return _xhero+rpg.sidelen-1,_yhero-rpg.sidelen/2 end
	end
end

--[[����NPC����
============================================================
Ī�Ů��
������Ů��
���ף�Ů��
�����ȣ�Ů��
����˹�ض���Ů��

���ף��У�
�������У�
����У�
Ƥ�������У�
���׵£��У�
����ɭ���У�
Τ��˹���У�
�����£��У�
���ز������У�
������£��У�

]]

-- ��ʾ��̸��
function rpg.talk(_g_temp,_g_box,_g_portrait,_title,_text)
	PasteToImage(_g_temp,_g_box,0,rpg.screenheight-GetHeight(_g_box));
	PasteToImage(_g_temp,_g_portrait,10,rpg.screenheight-GetHeight(_g_portrait));
	PrintText(_g_temp, GetWidth(_g_portrait)-50, rpg.screenheight-GetHeight(_g_box)+6,
			 _title, rpg.txtfont, rpg.txtbig, rpg.black)
	PrintText(_g_temp, GetWidth(_g_portrait)-50, rpg.screenheight-GetHeight(_g_box)+38,
			 _text, rpg.txtfont, rpg.txtnormal, rpg.black)
end


local alpha = 255
rpg.fadefast = 5 		-- 4����
rpg.fadenormal = 2.5 	-- 2����
rpg.fadeslow = 1.25 	-- 1����
-- ��ʾ��Ϣ����ʾ��Ϸ���true������false
-- _deta ������ rpg.fadefast,rpg.fadenormal,rpg.fadeslow �е�һ��
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