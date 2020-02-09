local current = {}
--注意保存lua编码为UTF-8

--[[ global
======================================================]]
canvas_width=800        -- 重置分辨率到800x600
canvas_height=600       -- 绘制到屏幕上再拉伸

lBird=36
rBird=18
xBird=350
wPipe=52
hPipe=4
divPipe=200

z = {}              -- 柱子数组
for i=1,hPipe do
    z[i] = {}
    -- x;
    -- h;           -- 障碍物高度
    -- down;        -- 是底部的柱子还是顶部的柱子
end

updown = false;     -- 柱子上下循环

y = 20;             -- 小球y坐标
BGSpeed = 5;        -- 背景图速度
bgx = 0;            -- 背景图偏移

score = 0;          -- 得分
gamestart = false;
ending = false;     -- 游戏结束动画的标记

gamepause = false;
TimerFlag = true;   -- Sleep()代替Timer，用作Timer标记
nDemo = 0;          -- demo帧

-- 显示“游戏结束”字样及分数
function DisplayGameOver(d)
    PasteToImageEx(d, g_caption, 250, 100, 300, 78, 0, 93, 300, 78);        -- 显示GameOver
    PasteToImageEx(d, g_scoreboard, 225, 200, 349, 182, 0, 0, 349, 182);    -- 显示得分面板
    num_printer_s.out(num_printer_s, d, (score < 10 and 383) or 372, 252, score);   -- 显示当前得分
    best = 0;       -- 获取历史最高分
    best = GetSetting("best")
    if best then    -- 不为nil，以前有记录
        best=best+0 -- 转换为数字
        best = (best > 999 and 0) or best;      -- 分数转换为int（反作弊）
        if (score > best) then
            PasteToImageEx(d, g_scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);      -- 显示NEW
            SaveSetting("best",tostring(score))
        end
    else            -- 第一次记录
        PasteToImageEx(d, g_scoreboard, 431, 290, 48, 21, 0, 182, 48, 21);          -- 显示NEW
        SaveSetting("best",tostring(score))
    end

    num_printer_s.out(num_printer_s, d, (best < 10 and 383) or 372, 320, best);     -- 显示历史最高分
end

-- 碰撞判定+分数处理
function crash()
    if y > canvas_height + 50 then              -- 运动到屏幕底部,50px余地
        y = -20;
        vy = 0;
        TimerFlag = false;          -- 关闭定时器
        gamestart = false;          -- 游戏结束
        ending = false;             -- 结束动画播放完毕
        PlaySound(s_die);
        do return end;
    end
    if ending then do return end end;

    local distance = 9999;          -- 最小横坐标差
    local closest = 0;              -- 最靠近的障碍物
    for i=1,hPipe do
        local a = z[i].x - xBird;
        if (a < distance) and (a + wPipe > 0) then  -- 已经过去的不算
            distance = a;
            closest = i;
        end
    end

    if (z[closest].down) then
        if ((distance < rBird) and (distance > 0) and (y > canvas_height - z[closest].h)) or ((distance < 0) and (canvas_height - z[closest].h - y < rBird)) then
            gamestart = false;      -- 游戏结束
            ending = true;
            vy = 0;
            PlaySound(s_hit);
            do return end;          -- 避免下面的得分
        end
    else
        if ((distance < rBird) and (distance > 0) and (y < z[closest].h)) or ((distance < 0) and (y - z[closest].h < rBird)) then
            gamestart = false;      -- 游戏结束
            ending = true;
            vy = 0;
            PlaySound(s_hit);
            do return end;          -- 避免下面的得分
        end
    end

    if (z[closest].x >= xBird) and (z[closest].x - math.floor(v_z) < xBird) then
        v_z = v_z + 0.01;   -- 障碍加速
        v_g = v_g + 0.01;   -- 重力增大'
        v_f = v_f - 0.02;   -- 跳跃力增大
        score = score + 1;
        PlaySound(s_point);
    end
end

--[[ messages
======================================================]]

function current.OnCreate()
    g_bg= GetImage("img/bg.png")
    g_caption= GetImage("img/caption.png")
    g_pipe_top= GetImage("img/pipe_top.png")
    g_pipe_bottom= GetImage("img/pipe_bottom.png")
    g_birds= GetImage("img/birds.png")
    g_scoreboard= GetImage("img/score.png")
    g_demo= GetImage("img/refexon_demo.png")

    s_die = GetSound("sound/die.wav", false)
    s_hit = GetSound("sound/hit.wav", false)
    s_point = GetSound("sound/point.wav", false)
    s_screenshot = GetSound("sound/screenshot.wav", false)
    s_swooshing = GetSound("sound/swooshing.wav", false)
    s_wing = GetSound("sound/wing.wav", false)

    num_printer_s = load(GetText("lua/num_printer.lua"))()
    num_printer_s.prepare(num_printer_s, "img/number_s.png", 25, 32)
    num_printer = load(GetText("lua/num_printer.lua"))()
    num_printer.prepare(num_printer, "img/number.png", 40, 60)

    g_temp = CreateImageEx(canvas_width, canvas_height, 0xFFFFFFFF);    -- 缓冲层
    math.randomseed(os.time())
    return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
    if not TimerFlag then       -- 游戏结束，显示得分
        PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height);
        do return"" end
    end;
    if (gamestart and not gamepause) or ending then     -- 核心绘图（更新下一帧）
        y = math.floor(y + vy);                 -- 小鸟竖直方向运动
        vy = vy + v_g;
        -- 游戏中，移动背景图
        if not ending then
            bgx = bgx - BGSpeed;    -- 背景图运动
            if bgx <= -canvas_width then bgx = -1 end
        end
        -- 碰撞判定+分数处理
        crash();
        -- 贴背景图(把到左边去的部分贴到右边)
        PasteToImageEx(g_temp, g_bg, 0, 0, canvas_width + bgx, canvas_height, -bgx, 0, canvas_width + bgx, canvas_height);
        PasteToImageEx(g_temp, g_bg, canvas_width + bgx, 0, -bgx, canvas_height, 0, 0, -bgx, canvas_height);
        -- 绘制障碍物
        for i=1,hPipe do
            if z[i].down then        -- 在屏幕下方
                PasteToImageEx(g_temp, g_pipe_bottom, z[i].x, canvas_height-z[i].h, wPipe, z[i].h, 0, 0, wPipe, z[i].h);
            else
                PasteToImageEx(g_temp, g_pipe_top, z[i].x, 0, wPipe, z[i].h, 0, 500 - z[i].h, wPipe, z[i].h);
            end
            if not ending then      -- 播放结束动画，不移动障碍物
                z[i].x = z[i].x - math.floor(v_z);
                if z[i].x < -wPipe then
                    z[i].x = canvas_width;      -- 到屏幕外，退到最右边
                    z[i].h = math.random(160,400);  -- 新随机高度
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
        num_printer.out(num_printer, g_temp, 10, 10, score);
        -- 结束动画播放完毕
        if not gamestart and not ending then
            DisplayGameOver(g_temp);        -- 显示“游戏结束”字样及分数
        end
        -- 显示
        PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height);
    elseif gamepause then                   -- 游戏暂停时
        PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height);      -- 显示
    else
        -- 游戏未开始，显示DEMO
        -- 开始绘图（更新下一帧）
        bgx = bgx - BGSpeed;                -- 背景图运动
        if bgx <= -canvas_width then bgx = -1 end
        if nDemo > 74 then
            -- 贴背景图(把到左边去的部分贴到右边)
            PasteToImageEx(g_temp, g_bg, 0, 0, canvas_width + bgx, canvas_height, -bgx, 0, canvas_width + bgx, canvas_height);
            PasteToImageEx(g_temp, g_bg, canvas_width + bgx, 0, -bgx, canvas_height, 0, 0, -bgx, canvas_height);
            -- 贴示意图
            PasteToImageEx(g_temp, g_caption, 250, 100, 300, 92, 0, 0, 300, 92);
            PasteToImageEx(g_temp, g_caption, 250, 200, 227, 134, 0, 174, 227, 134);

            PasteToWndEx(WndGraphic, g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height)  -- 显示
        else
            if demo_skip then
                demo_skip=false;
                -- 在屏幕中央显示demo w:400 h:225 => x = 184 y = 143
                PasteToImageEx(g_temp, g_demo, 184, 143, 400, 225, 0, nDemo * 225, 400, 225);
                PasteToWndEx(WndGraphic, g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height);     -- 显示
                nDemo = nDemo +1;
            else
                demo_skip=true
                PasteToImageEx(g_temp, g_demo, 184, 143, 400, 225, 0, nDemo * 225, 400, 225);
                PasteToWndEx(WndGraphic, g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height);     -- 显示
            end
        end
    end
    return ""
end

function current.OnClose()
    DeleteImage(g_bg)
    DeleteImage(g_caption)
    DeleteImage(g_pipe_top)
    DeleteImage(g_pipe_bottom)
    DeleteImage(g_birds) 
    DeleteImage(g_scoreboard)
    DeleteImage(g_demo)

    DeleteImage(g_temp)
    num_printer_s.free(num_printer_s)
    num_printer.free(num_printer)
end

function current.OnKeyDown(nChar)
    if nChar == core.vk["VK_ESCAPE"] then
        if (gamepause) then
            TimerFlag = true;       -- 继续游戏
            gamepause = false;
        elseif (gamestart) then
            TimerFlag = false;      -- 暂停游戏
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
    if gamestart then           -- 正在游戏 而不是播放结束动画
        if gamepause then
            TimerFlag = true;   -- 继续游戏
            gamepause = false;
        else
            vy = v_f;           -- 已开始游戏 按下空格速度突变
            PlaySound(s_swooshing);
        end
    elseif not ending and nDemo > 74 then   -- 游戏已结束且动画播放完，且DEMO播放完，开始新游戏
        y = 0;                  -- 位置初始化：在屏幕外
        vy = 3;                 -- 速度初始化：掉下
        v_f = -8.0              -- 初始跳跃力
        v_g = 0.5               -- 初始重力加速度
        v_z = 3.4               -- 初始障碍物速度
        
        for i=1,hPipe do        -- 障碍物位置初始化
            z[i].x = canvas_width + i*divPipe;
            z[i].h = math.random(160,400);
            updown = not updown;
            z[i].down = updown;
        end
        gamestart = true;
        TimerFlag = true;       -- 开始游戏
        
        score = 0;
    end
end

function current.OnLButtonUp(x,y)

end

function current.OnMouseMove(x,y)
    
end

function current.OnSetFocus()

end

function current.OnKillFocus()
    if gamestart and not gamepause then
        TimerFlag = false;      -- 暂停游戏
        gamepause = true;
    end
end

function current.OnMouseWheel(zDeta,x,y)
    
end

return current