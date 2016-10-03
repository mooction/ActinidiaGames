local core = load(GetText("res\\lua\\core.lua"))()

local current = {}
--encode: Chinese use GBK


--[[ global
======================================================]]

lBird 36
rBird (lBird/2)
xBird 350

wPipe=52
hPipe=4
divPipe=216

oriA=-0.396
oriG=0.001
oriPipeSpeed=0.160

BGSpeed 0.07f

z = {}           -- 柱子数组
for i=1,hPipe do
    z[i] = {}
	--int x;
	--int h;		-- 障碍物高度
	--int down;	-- 是底部的柱子还是顶部的柱子
end

bool updown = false;		-- 柱子上下循环

y = 20.0f;			-- 小球y坐标
vy = 0.0f;			-- 小球y速度

bgx=0;					-- 背景图偏移

score = 0;				-- 得分
gamestart = false;
ending = false;		-- 游戏结束动画的标记

v_g;					-- 实时重力加速度
v_f;					-- 实时突变速度
v_z;					-- 实时障碍物速度

gamepause = false;
TimerFlag = true;		-- Sleep()代替Timer，用作Timer标记
frames = 0;
nDemo = 0;			-- demo帧
detaTime = 0.02;		-- 时间差（秒）

CImage Screenshot;

-- 显示得分
function drawscore(d, g, score, xDest, yDest, wNum, hNum, NumberPerLine)
	if (score < 10)	then
		PasteToImage(d, g, xDest, yDest, wNum, hNum, score%NumberPerLine*wNum, score / NumberPerLine*hNum, wNum, hNum);
	elseif (score < 100) then
		PasteToImage(d, g, xDest, yDest, wNum, hNum, score / 10 % NumberPerLine*wNum, score / 10 / NumberPerLine*hNum, wNum, hNum);
		PasteToImage(d, g, xDest + wNum, yDest, wNum, hNum, score % 10 % NumberPerLine*wNum, score % 10 / NumberPerLine*hNum, wNum, hNum);
	else
		int tscore = score / 100;	-- 百位数
		PasteToImage(d, g, xDest, yDest, wNum, hNum, tscore % NumberPerLine*wNum, tscore / NumberPerLine*hNum, wNum, hNum);
		tscore = score % 100;		-- 后两位数
		PasteToImage(d, g, xDest + wNum, yDest, wNum, hNum, tscore / 10 % NumberPerLine*wNum, tscore / 10 / NumberPerLine*hNum, wNum, hNum);
		tscore %= 10;	-- 个位数
		PasteToImage(d, g, xDest + wNum + wNum, yDest, wNum, hNum, tscore % NumberPerLine*wNum, tscore / NumberPerLine*hNum, wNum, hNum);
	end
end

-- 显示“游戏结束”字样及分数
function DisplayGameOver(d)
	PasteToImage(d, caption, 250, 100, 300, 78, 0, 93, 300, 78);		-- 显示GameOver
	PasteToImage(d, scoreboard, 225, 200, 349, 182, 0, 0, 349, 182);	-- 显示得分面板
	drawscore(d, &numberss, score, (score < 10 and 383) or 372, 252, 25, 32, 5);	-- 显示当前得分
	int best = 0;			-- 获取历史最高分

	if io.input("usr.dat") then -- 以前有记录
			best = io.read();	-- 读取
			best = (best > 999 and 0) or best;		-- 分数转换为int（反作弊）
			if (score > best) then
				PasteToImage(d, scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);	-- 显示NEW
				io.output("usr.dat");
				io.write(score);	-- 保存
				io.close();
			end
	else	-- 第一次记录
		PasteToImage(d, scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);		-- 显示NEW
		io.output("usr.dat");
		io.write(score);	-- 保存
		io.close();
	end

	drawscore(d, &numberss, best, (best < 10 and 383) or 372, 320, 25, 32, 5);		-- 显示历史最高分
end

-- 碰撞判定+分数处理
function crash(detaTime)
	if y > core.screenheight then				-- 运动到屏幕底部
		y = core.screenheight;
		vy = 0;
		gamestart = false;	-- 游戏结束
		ending = false;		-- 结束动画播放完毕
		TimerFlag = false;	-- 关闭定时器
		PlaySound(s_die);
		do return end;
	end
	if ending then do return end

	local distance = 9999;	-- 最小横坐标差
	local closest = 0;		-- 最靠近的障碍物
	for i = 0, hPipe-1 do
		local a = z[i].x - xBird;
		if a < distance and a + wPipe > 0 then	-- 已经过去的不算
			distance = a;
			closest = i;
		end
	end

	if (z[closest].down) then
		if (distance < rBird and distance > 0 and y > core.screenheight - z[closest].h) or (distance < 0 and core.screenheight - z[closest].h - y < rBird) then
			gamestart = false;			-- 游戏结束
			ending = true;
			vy = 0;
			PlaySound(s_hit);
			do return end;						-- 避免下面的得分
		end
	else
		if (distance < rBird and distance > 0 and (int)y < z[closest].h) or (distance < 0 and (int)y - z[closest].h < rBird) then
			gamestart = false;			-- 游戏结束
			ending = true;
			vy = 0;
			PlaySound(s_hit);
			do return end;						-- 避免下面的得分
		end
	end

	if (z[closest].x >= xBird and z[closest].x - detaTime*v_z < xBird) then
		score = score + 1;
		v_g = v_g + 0.000005f;
		v_f = v_f - 0.0024f;
		v_z = v_z + 0.0002f;
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
	g_scoreboard= GetImage("res\\img\\bg.png")
	g_numberss= GetImage("res\\img\\number_s.png")
	g_demo= GetImage("res\\img\\refexon_demo.png")

	s_die = GetSound("res\\sound\die.wav", false)
	s_hit = GetSound("res\\sound\hit.wav", false)
	s_point = GetSound("res\\sound\point.wav", false)
	s_screenshot = GetSound("res\\sound\screenshot.wav", false)
	s_swooshing = GetSound("res\\sound\swooshing.wav", false)
	s_wing = GetSound("res\\sound\wing.wav", false)

	SetTimer(hWnd, 1, DEMO_INTERVAL, NULL);		-- 开启DEMO定时器
	math.randomseed(os.time())

	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	if (gamestart and not gamepause) or ending then
		-- 核心绘图（更新下一帧）
		y = y + detaTime * (vy + v_g / 2 * detaTime);-- 小鸟竖直方向运动
		vy = vy + v_g*detaTime;

		if not ending then		-- 游戏中，移动背景图
			bgx = bgx - BGSpeed*detaTime;		-- 背景图运动
			if (bgx <= -core.screenwidth) bgx = -1;

		crash(detaTime);					-- 碰撞判定+分数处理
				
		-- 双缓冲绘图准备
		HDC mdc = CreateCompatibleDC(NULL);
		HBITMAP bmp = CreateCompatibleBitmap(pDC, core.screenwidth, core.screenheight);
		SelectObject(mdc, bmp);
		-- 贴背景图(把到左边去的部分贴到右边)
		bg.Draw(mdc, 0, 0, core.screenwidth + bgx, core.screenheight, -bgx, 0, core.screenwidth + bgx, core.screenheight);
		bg.Draw(mdc, core.screenwidth + bgx, 0, -bgx, core.screenheight, 0, 0, -bgx, core.screenheight);

		for i = 0, hPipe-1 do
			local pp=z[i]
			-- 绘制障碍物，h是障碍物高度
			if pp.down then -- 在屏幕下方
				pipe_bottom.Draw(mdc, pp.x, core.screenheight-pp.h, wPipe, pp.h, 0, 0, wPipe, pp.h);
			else
				pipe_top.Draw(mdc, pp.x, 0, wPipe, pp.h, 0, 500 - pp.h, wPipe, pp.h);
			end

			if not ending then			-- 播放结束动画，不移动障碍物
				z[i].x = z[i].x - detaTime*v_z;
				if (z[i].x < -wPipe) then
					z[i].x = core.screenwidth;	-- 到屏幕外，退到最右边
					z[i].h = math.random(160,420);	-- 新随机高度
					updown = not updown;
					z[i].down = updown;
				end
			end
		end
		-- 绘制小鸟（坐标取整）
		WORD bird_frame;
		if (vy<v_f/3) then bird_frame = 2; end
		elseif (vy>-v_f/3) then bird_frame = 0; end
		else bird_frame = 1; end
		birds.Draw(mdc, xBird - rBird, y - rBird, lBird, lBird, bird_frame*lBird, 0, lBird, lBird);

		drawscore(mdc, &numbers, score, 10, 10, 40, 60, 5);		-- 绘制得分

		if not gamestart and not ending then				-- 结束动画播放完毕
			DisplayGameOver(mdc);				-- 显示“游戏结束”字样及分数
		end
		BitBlt(pDC, 0, 0, core.screenwidth, core.screenheight, mdc, 0, 0, SRCCOPY);
		DeleteDC(mdc);
		DeleteObject(bmp);
		frames = frames + 1;

		-- 计算FPS
		static float currenttime = 0.0f;	-- 当前时间（秒） 
		currenttime = timeGetTime() / 1000.0f; -- timeGetTime返回当前时间（从ms转换为s）

		static float fpslasttime = 0.0f;		-- 上次fps计算时间（秒）

		if currenttime - fpslasttime > 1.0f then	-- 计算帧速：1秒钟一次
			int fps = frames / (currenttime - fpslasttime);

			-- 在窗口标题显示帧速率
			wsprintf(buf, _T("FlappyBird fps:%d"), fps);
			SetWindowText(hWnd, buf);

			frames = 1;
			fpslasttime = currenttime;			-- 重新开始计算下一轮时间差
		end
	elseif (gamepause) then						-- 游戏暂停时
		Screenshot.Draw(hdc,0,0);
	else
		-- 游戏未开始的绘图
		-- 开始绘图（更新下一帧）
		bgx = bgx - BGSpeed*detaTime;		-- 背景图运动
		if (bgx <= -core.screenwidth) then bgx = -1; end
		if (nDemo > DEMO_FRAMES - 1) then
			if (nDemo == DEMO_FRAMES)	SetTimer(hWnd, 1, RENDER_INTERVAL, NULL);		-- 开启游戏定时器
			-- 双缓冲绘图准备
			HDC mdc = CreateCompatibleDC(NULL);
			HBITMAP bmp = CreateCompatibleBitmap(pDC, core.screenwidth, core.screenheight);
			SelectObject(mdc, bmp);
			-- 贴背景图(把到左边去的部分贴到右边)
			bg.Draw(mdc, 0, 0, core.screenwidth + bgx, core.screenheight, -bgx, 0, core.screenwidth + bgx, core.screenheight);
			bg.Draw(mdc, core.screenwidth + bgx, 0, -bgx, core.screenheight, 0, 0, -bgx, core.screenheight);
			-- 贴示意图
			caption.Draw(mdc, 250, 100, 300, 92, 0, 0, 300, 92);
			caption.Draw(mdc, 286, 200, 227, 134, 0, 174, 227, 134);

			BitBlt(pDC, 0, 0, core.screenwidth, core.screenheight, mdc, 0, 0, SRCCOPY);
			DeleteDC(mdc);
			DeleteObject(bmp);
		else
			-- 在屏幕中央显示demo w:400 h:225 => x = 200 y = 187
			FillSolidRect(pDC, &ClientRect, RGB(255, 255, 255));
			demo.Draw(pDC, 200, 187, 400, 225, 0, nDemo * 225, 400, 225);
			nDemo = nDemo +1;
		end
		frames = frames + 1;

		-- 计算FPS
		static float currenttime = 0.0f;	-- 当前时间（秒） 
		currenttime = timeGetTime() / 1000.0f; -- timeGetTime返回当前时间（从ms转换为s）
		
		static float fpslasttime = 0.0f;	-- 上次fps计算时间（秒）

		if (currenttime - fpslasttime > 1.0f) then	-- 计算帧速：1秒钟一次
			int fps = (int)(frames / (currenttime - fpslasttime));
			-- 在窗口标题显示帧速率
			WCHAR buf[20];
			wsprintf(buf, _T("FlappyBird fps:%d"), fps);
			SetWindowText(hWnd, buf);

			frames = 1;
			fpslasttime = currenttime;			-- 重新开始计算下一轮时间差
		end
	end
	return ""
end

function current.OnClose()
	return 0 -- 0 exit, 1 cancel
end

function current.OnKeyDown(nChar)
	switch (nChar)
	{
	case core.VK_ESCAPE:
		if (gamepause) then
			TimerFlag = true;	-- 继续游戏
			gamepause = false;
			SetTimer(hWnd, 1, RENDER_INTERVAL, NULL);		-- 开启定时器
		elseif (gamestart) then
			TimerFlag = false;	-- 暂停游戏
			gamepause = true;
			SetWindowText(hWnd, _T("游戏暂停"));
			hdc = GetDC(hWnd);
			GetScreenshot(&Screenshot, hdc, core.screenwidth, core.screenheight);	-- 备份一下屏幕截图到内存
			ReleaseDC(hWnd,hdc);
		end
		break;
	case core.VK_SPACE:
		current.OnLButtonDown(0,0);
		break;
	case core.VK_F4:
		PlaySound(s_screenshot);
		Screenshot();
		break;
	default:
		break;
	}
end

function current.OnKeyUp(nChar)

end

function current.OnLButtonDown(x,y)
	if (gamestart) then		-- 正在游戏 而不是播放结束动画
		if (gamepause) then
			TimerFlag = true;	-- 继续游戏
			gamepause = false;
			SetTimer(hWnd, 1, RENDER_INTERVAL, NULL);	-- 开启定时器
		else
			vy = v_f;	-- 已开始游戏 按下空格速度突变
			PlaySound(s_swooshing);
		end
	elseif (not ending and nDemo > DEMO_FRAMES-1) then	-- 游戏已结束且动画播放完，且DEMO播放完
		-- 开始新游戏
		y = -20.0f;							-- 位置初始化：在屏幕外
		vy = 0.12f;							-- 速度初始化：掉下
		v_g = oriG;
		v_f = oriA;
		v_z = oriPipeSpeed;

		for i = 0,hPipe+1 do	-- 障碍物位置初始化
			z[i].x = core.screenwidth + i*divPipe;
			z[i].h = math.random(160,420);
			updown = not updown;
			z[i].down = updown;
		end
		TimerFlag = true;		-- 开始游戏
		gamestart = true;
		score = 0;
		SetTimer(hWnd, 1, RENDER_INTERVAL, NULL);	-- 开启定时器
	end
end

function current.OnLButtonUp(x,y)

end

function current.OnRButtonDown(x,y)

end

function current.OnLButtonUp(x,y)

end

function current.OnSetFocus()

end

function current.OnKillFocus()
	if (gamestart and not gamepause) then
		TimerFlag = false;					-- 暂停游戏
		gamepause = true;
		
		hdc = GetDC(hWnd);
		GetScreenshot(&Screenshot, hdc, core.screenwidth, core.screenheight);	-- 备份一下屏幕截图到内存
		ReleaseDC(hWnd, hdc);
	end
end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current