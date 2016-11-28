local current = {}
--注意保存lua编码为UTF-8

--[[ global
======================================================]]
screenwidth = core.screenwidth
screenheight = core.screenheight
core.screenwidth=768		-- 重置分辨率到768x512
core.screenheight=512		-- 绘制到屏幕上再拉伸

lBird=36
rBird=18
xBird=350
wPipe=52
hPipe=4
divPipe=200

z = {}          	-- 柱子数组
for i=1,hPipe do
    z[i] = {}
	-- x;
	-- h;			-- 障碍物高度
	-- down;		-- 是底部的柱子还是顶部的柱子
end

updown = false;		-- 柱子上下循环

y = 20;				-- 小球y坐标
BGSpeed = 5;		-- 背景图速度
bgx = 0;			-- 背景图偏移

score = 0;			-- 得分
gamestart = false;
ending = false;		-- 游戏结束动画的标记

gamepause = false;
TimerFlag = true;	-- Sleep()代替Timer，用作Timer标记
nDemo = 0;			-- demo帧

-- 显示得分
function drawscore(d, g, score, xDest, yDest, wNum, hNum, NumberPerLine)
	if (score < 10)	then
		PasteToImageEx(d, g, xDest, yDest, wNum, hNum, score%NumberPerLine*wNum, math.floor(score/NumberPerLine)*hNum, wNum, hNum);
	elseif (score < 100) then
		PasteToImageEx(d, g, xDest, yDest, wNum, hNum, math.floor(score/10) % NumberPerLine*wNum, math.floor(math.floor(score/10)/NumberPerLine)*hNum, wNum, hNum);
		PasteToImageEx(d, g, xDest + wNum, yDest, wNum, hNum, score % 10 % NumberPerLine*wNum, math.floor(score%10/NumberPerLine)*hNum, wNum, hNum);
	else
		tscore = math.floor(score/100);	-- 百位数
		PasteToImageEx(d, g, xDest, yDest, wNum, hNum, tscore % NumberPerLine*wNum, math.floor(tscore/NumberPerLine)*hNum, wNum, hNum);
		tscore = score % 100;			-- 后两位数
		PasteToImageEx(d, g, xDest + wNum, yDest, wNum, hNum, math.floor(tscore/10) % NumberPerLine*wNum, math.floor(math.floor(tscore/10)/NumberPerLine)*hNum, wNum, hNum);
		tscore = tscore % 10;			-- 个位数
		PasteToImageEx(d, g, xDest + wNum + wNum, yDest, wNum, hNum, tscore % NumberPerLine*wNum, math.floor(tscore/NumberPerLine)*hNum, wNum, hNum);
	end
end

-- 显示“游戏结束”字样及分数
function DisplayGameOver(d)
	PasteToImageEx(d, g_caption, 250, 100, 300, 78, 0, 93, 300, 78);		-- 显示GameOver
	PasteToImageEx(d, g_scoreboard, 225, 200, 349, 182, 0, 0, 349, 182);	-- 显示得分面板
	drawscore(d, g_numberss, score, (score < 10 and 383) or 372, 252, 25, 32, 5);	-- 显示当前得分
	best = 0;		-- 获取历史最高分

	local f = io.open("usr.dat","r");
	if f then 	-- 以前有记录
		best = f:read()+0;		-- 读取
		f:close();
		best = (best > 999 and 0) or best;		-- 分数转换为int（反作弊）
		if (score > best) then
			PasteToImageEx(d, g_scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);		-- 显示NEW
			io.output("usr.dat");
			io.write(score);	-- 保存
			io.close();
		end
	else			-- 第一次记录
        PasteToImageEx(d, g_scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);			-- 显示NEW
		io.output("usr.dat");
		io.write(score);		-- 保存
		io.close();
	end

	drawscore(d, g_numberss, best, (best < 10 and 383) or 372, 320, 25, 32, 5);		-- 显示历史最高分
end

-- 碰撞判定+分数处理
function crash()
	if y > core.screenheight + 50 then				-- 运动到屏幕底部,50px余地
		y = -20;
		vy = 0;
		TimerFlag = false;			-- 关闭定时器
		gamestart = false;			-- 游戏结束
		ending = false;				-- 结束动画播放完毕
		PlaySound(s_die);
		do return end;
	end
	if ending then do return end end;

	local distance = 9999;			-- 最小横坐标差
	local closest = 0;				-- 最靠近的障碍物
	for i=1,hPipe do
		local a = z[i].x - xBird;
		if (a < distance) and (a + wPipe > 0) then	-- 已经过去的不算
			distance = a;
			closest = i;
		end
	end

	if (z[closest].down) then
		if ((distance < rBird) and (distance > 0) and (y > core.screenheight - z[closest].h)) or ((distance < 0) and (core.screenheight - z[closest].h - y < rBird)) then
			gamestart = false;		-- 游戏结束
			ending = true;
			vy = 0;
			PlaySound(s_hit);
			do return end;			-- 避免下面的得分
		end
	else
		if ((distance < rBird) and (distance > 0) and (y < z[closest].h)) or ((distance < 0) and (y - z[closest].h < rBird)) then
			gamestart = false;		-- 游戏结束
			ending = true;
			vy = 0;
			PlaySound(s_hit);
			do return end;			-- 避免下面的得分
		end
	end

    if (z[closest].x >= xBird) and (z[closest].x - math.floor(v_z) < xBird) then
		v_z = v_z + 0.01;	-- 障碍加速
		v_g = v_g + 0.01;	-- 重力增大'
		v_f = v_f - 0.02;	-- 跳跃力增大
		score = score + 1;
		PlaySound(s_point);
	end
end

--[[ messages
======================================================]]

function current.OnCreate()
	-- 加载资源
	g_bg= GetImage("res\\img\\bg.png")
	g_caption= GetImage("res\\img\\caption.png")
	g_numbers= GetImage("res\\img\\number.png")
	g_pipe_top= GetImage("res\\img\\pipe_top.png")
	g_pipe_bottom= GetImage("res\\img\\pipe_bottom.png")
	g_birds= GetImage("res\\img\\birds.png")
	g_scoreboard= GetImage("res\\img\\score.png")
	g_numberss= GetImage("res\\img\\number_s.png")
	g_demo= GetImage("res\\img\\refexon_demo.png")

	s_die = GetSound("res\\sound\\die.wav", false)
	s_hit = GetSound("res\\sound\\hit.wav", false)
	s_point = GetSound("res\\sound\\point.wav", false)
	s_screenshot = GetSound("res\\sound\\screenshot.wav", false)
	s_swooshing = GetSound("res\\sound\\swooshing.wav", false)
	s_wing = GetSound("res\\sound\\wing.wav", false)

	-- 准备
	g_temp = CreateImageEx(core.screenwidth, core.screenheight, core.white);	-- 缓冲层
	math.randomseed(os.time())
	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	if not TimerFlag then		-- 游戏结束，显示得分
		PasteToWndEx(WndGraphic,g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight);
		do return"" end
	end;
	if (gamestart and not gamepause) or ending then 	-- 核心绘图（更新下一帧）
		y = math.floor(y + vy);					-- 小鸟竖直方向运动
		vy = vy + v_g;
		-- 游戏中，移动背景图
		if not ending then
			bgx = bgx - BGSpeed;	-- 背景图运动
			if bgx <= -core.screenwidth then bgx = -1 end
		end
		-- 碰撞判定+分数处理
		crash();
		-- 贴背景图(把到左边去的部分贴到右边)
		PasteToImageEx(g_temp, g_bg, 0, 0, core.screenwidth + bgx, core.screenheight, -bgx, 0, core.screenwidth + bgx, core.screenheight);
		PasteToImageEx(g_temp, g_bg, core.screenwidth + bgx, 0, -bgx, core.screenheight, 0, 0, -bgx, core.screenheight);
		-- 绘制障碍物
		for i=1,hPipe do
			if z[i].down then		 -- 在屏幕下方
				PasteToImageEx(g_temp, g_pipe_bottom, z[i].x, core.screenheight-z[i].h, wPipe, z[i].h, 0, 0, wPipe, z[i].h);
			else
				PasteToImageEx(g_temp, g_pipe_top, z[i].x, 0, wPipe, z[i].h, 0, 500 - z[i].h, wPipe, z[i].h);
			end
			if not ending then		-- 播放结束动画，不移动障碍物
				z[i].x = z[i].x - math.floor(v_z);
				if z[i].x < -wPipe then
					z[i].x = core.screenwidth;		-- 到屏幕外，退到最右边
					z[i].h = math.random(160,400);	-- 新随机高度
					updown = not updown;
					z[i].down = updown;
				end
			end
		end
		local bird_frame;
		if (vy<v_f/3) then
			bird_frame = 2 
		elseif (vy>-v_f/3) then
			bird_frame = 0 
		else
			bird_frame = 1
		end
		-- 绘制小鸟（坐标取整）
		PasteToImageEx(g_temp, g_birds, xBird - rBird, y - rBird, lBird, lBird, bird_frame*lBird, 0, lBird, lBird);
		-- 绘制得分
		drawscore(g_temp, g_numbers, score, 10, 10, 40, 60, 5);	
		-- 结束动画播放完毕
		if not gamestart and not ending then
			DisplayGameOver(g_temp);		-- 显示“游戏结束”字样及分数
		end
		-- 显示
		PasteToWndEx(WndGraphic,g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight);
	elseif gamepause then					-- 游戏暂停时
		PasteToWndEx(WndGraphic,g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight);		-- 显示
	else
		-- 游戏未开始，显示DEMO
		-- 开始绘图（更新下一帧）
		bgx = bgx - BGSpeed;				-- 背景图运动
		if bgx <= -core.screenwidth then bgx = -1 end
		if nDemo > 74 then
			-- 贴背景图(把到左边去的部分贴到右边)
			PasteToImageEx(g_temp, g_bg, 0, 0, core.screenwidth + bgx, core.screenheight, -bgx, 0, core.screenwidth + bgx, core.screenheight);
			PasteToImageEx(g_temp, g_bg, core.screenwidth + bgx, 0, -bgx, core.screenheight, 0, 0, -bgx, core.screenheight);
			-- 贴示意图
			PasteToImageEx(g_temp, g_caption, 250, 100, 300, 92, 0, 0, 300, 92);
			PasteToImageEx(g_temp, g_caption, 250, 200, 227, 134, 0, 174, 227, 134);

			PasteToWndEx(WndGraphic, g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight)	-- 显示
		else
			if demo_skip then
				demo_skip=false;
				-- 在屏幕中央显示demo w:400 h:225 => x = 184 y = 143
				PasteToImageEx(g_temp, g_demo, 184, 143, 400, 225, 0, nDemo * 225, 400, 225);
				PasteToWndEx(WndGraphic, g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight);		-- 显示
				nDemo = nDemo +1;
			else
				demo_skip=true
				PasteToImageEx(g_temp, g_demo, 184, 143, 400, 225, 0, nDemo * 225, 400, 225);
				PasteToWndEx(WndGraphic, g_temp,0,0,screenwidth,screenheight,0,0,core.screenwidth,core.screenheight);		-- 显示
			end
		end
	end
	return ""
end

function current.OnClose()
	DeleteImage(g_bg)
	DeleteImage(g_caption) 
	DeleteImage(g_numbers)
	DeleteImage(g_pipe_top)
	DeleteImage(g_pipe_bottom)
	DeleteImage(g_birds) 
	DeleteImage(g_scoreboard)
	DeleteImage(g_numberss)
	DeleteImage(g_demo)

	DeleteImage(g_temp)
end

function current.OnKeyDown(nChar)
	if nChar == core.vk["VK_ESCAPE"] then
		if (gamepause) then
			TimerFlag = true;		-- 继续游戏
			gamepause = false;
		elseif (gamestart) then
			TimerFlag = false;		-- 暂停游戏
			gamepause = true;
		end
	elseif nChar == core.vk["VK_SPACE"] then
		current.OnLButtonDown(0,0);
	elseif nChar == core.vk["VK_F4"] then
		PlaySound(s_screenshot);
		Screenshot();
	end
end

function current.OnKeyUp(nChar)

end

function current.OnLButtonDown(x,y)
	if gamestart then			-- 正在游戏 而不是播放结束动画
		if gamepause then
			TimerFlag = true;	-- 继续游戏
			gamepause = false;
		else
			vy = v_f;			-- 已开始游戏 按下空格速度突变
			PlaySound(s_swooshing);
		end
	elseif not ending and nDemo > 74 then	-- 游戏已结束且动画播放完，且DEMO播放完，开始新游戏
		y = 0;					-- 位置初始化：在屏幕外
		vy = 3;					-- 速度初始化：掉下
		v_f = -17.0				-- 突变速度
		v_g = 1.3				-- 初始重力加速度
		v_z = 6.4 				-- 初始障碍物速度
		
		for i=1,hPipe do		-- 障碍物位置初始化
			z[i].x = core.screenwidth + i*divPipe;
			z[i].h = math.random(160,400);
			updown = not updown;
			z[i].down = updown;
		end
		gamestart = true;
		TimerFlag = true;		-- 开始游戏
		
		score = 0;
	end
end

function current.OnLButtonUp(x,y)

end

function current.OnRButtonDown(x,y)

end

function current.OnRButtonUp(x,y)

end

function current.OnMouseMove(x,y)
	
end

function current.OnSetFocus()

end

function current.OnKillFocus()
	if gamestart and not gamepause then
		TimerFlag = false;		-- 暂停游戏
		gamepause = true;
	end
end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current