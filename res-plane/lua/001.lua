local current = {}

--[[ global
======================================================]]
shoot_delay = 30
bullet_delay = 10
enemy_delay = 10
frame_delay = 8

max_bullets = 30
bullet_left = {}
bullet_right = {}
bullet_power = 1

max_enemy1 = 10
enemy1 = {}
enemy2 = {}
-- enemy3 is only one
enemy1_health = 1
enemy2_health = 4
enemy3_health = 50

function game_start()
	shoot_count = 0
	hero_frame_count = 0
	hero_life = 1

	bMouseDown = 0
	bPause = false

	-- initial position
	last_mouse_x = bg_w//2
	last_mouse_y = bg_h-20
	mouse_x = last_mouse_x
	mouse_y = last_mouse_y

	-- initialize bullets
	for i=1,max_bullets do
		bullet_left[i] = {y=0,x=0}
		bullet_right[i] = {y=0,x=hero_w}
	end

	-- initialize enemies
	for i=1,max_enemy1 do
		enemy1[i] = {
			y = -e1_h*i*2,
			x = math.random(bg_w),
			health = enemy1_health,
			frame = 0
		}
	end
end

--[[ messages
======================================================]]

function current.OnCreate()
	g_bg = GetImage("res\\img\\background.png")
	bg_w = GetWidth(g_bg)
	bg_h = GetHeight(g_bg)
	g_hero = GetImage("res\\img\\hero.png")
	g_hero_blowup = GetImage("res\\img\\hero_blowup.png")
	hero_w = GetWidth(g_hero)
	hero_h = GetHeight(g_hero)//2

	g_button = GetImage("res\\img\\button.png")
	btn_w = GetWidth(g_button)
	btn_h = GetHeight(g_button)//4

	g_enemy1 = GetImage("res\\img\\enemy1.png")
	e1_h = GetHeight(g_enemy1)
	--g_enemy2 = GetImage("res\\img\\enemy2.png")
	--e2_w = GetWidth(g_enemy2)
	--e2_h = GetHeight(g_enemy2)//2
	--g_enemy3 = GetImage("res\\img\\enemy3.png")

	g_enemy1_blowup = GetImage("res\\img\\enemy1_blowup.png")
	e1_blow_w = GetWidth(g_enemy1_blowup)
	e1_blow_h = GetHeight(g_enemy1_blowup)//4
	e1_crash_r = e1_blow_w - 4

	g_bullet1 = GetImage("res\\img\\bullet1.png")
	g_bullet2 = GetImage("res\\img\\bullet2.png")

	g_temp = CreateImage(bg_w,bg_h)

	s_bgm = GetSound("res\\sound\\game_music.mp3",true)
	PlaySound(s_bgm)
	s_btn = GetSound("res\\sound\\button.mp3",false)
	s_bullet = GetSound("res\\sound\\bullet.mp3",false)
	s_gameover = GetSound("res\\sound\\game_over.mp3",false)

	--s_big_spaceship_flying = GetSound("res\\sound\\big_spaceship_flying.mp3",false)
	s_e1_down = GetSound("res\\sound\\enemy1_down.mp3",false)
	s_e2_down = GetSound("res\\sound\\enemy2_down.mp3",false)
	--s_e3_down = GetSound("res\\sound\\enemy3_down.mp3",false)

	game_start()

	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	if bPause then 
		PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,bg_w,bg_h)
		return ""
	end
	PasteToImage(g_temp,g_bg,0,0)
	----------------------hero-------------------------------
	local hero_x, hero_y
	if bMouseDown==1 then
		hero_x = mouse_x
		hero_y = mouse_y
	else
		hero_x = last_mouse_x
		hero_y = last_mouse_y
	end
	if hero_life>0 then
		for j=1,max_enemy1 do 											-- hero crash
			if (enemy1[j].health>0) and (hero_x-enemy1[j].x)*(hero_x-enemy1[j].x)+(hero_y-enemy1[j].y)*(hero_y-enemy1[j].y)<(e1_crash_r*e1_crash_r) then
				enemy1[j].health = 0		-- remove the enemy
				hero_life = hero_life-1
				if hero_life>0 then PlaySound(s_e2_down) else PlaySound(s_gameover);break end
			end
		end
	end
	hero_frame_count = hero_frame_count+1
	if hero_life==0 then
		if hero_frame_count ~= frame_delay*4 then
			PasteToImageEx(g_temp,g_hero_blowup,hero_x-hero_w//2,hero_y-hero_h//2,hero_w,hero_h,
				0,hero_frame_count//frame_delay*hero_h,hero_w,hero_h)
		end
		PrintText(g_temp, 36, bg_h//3, "Game Over", "Arial", 72, 0x00333333)
		PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,bg_w,bg_h)
		return ""
	else
		if hero_frame_count == frame_delay*4 then
			hero_frame_count = 0
		end
		PasteToImageEx(g_temp,g_hero,hero_x-hero_w//2,hero_y-hero_h//2,hero_w,hero_h,
			0,(hero_frame_count<frame_delay*2)and 0 or hero_h,hero_w,hero_h)
	end
	
	----------------------bullets-----------------------------
	for i=1,max_bullets do
		bullet_left[i].y = bullet_left[i].y - bullet_delay
		bullet_right[i].y = bullet_right[i].y - bullet_delay
		if bullet_left[i].y >= 0 then
			PasteToImage(g_temp,g_bullet1,bullet_left[i].x,bullet_left[i].y)	-- left
			for j=1,max_enemy1 do
				if (bullet_left[i].x-enemy1[j].x)*(bullet_left[i].x-enemy1[j].x)
					+ (bullet_left[i].y-enemy1[j].y)*(bullet_left[i].y-enemy1[j].y)
					< (e1_crash_r*e1_crash_r) then 
					PlaySound(s_e1_down)
					enemy1[j].health = enemy1[j].health - bullet_power			-- hit the target
					bullet_left[i].y = -1										-- remove this bullet
				end
			end
		end
		if bullet_right[i].y >= 0 then
			PasteToImage(g_temp,g_bullet1,bullet_right[i].x,bullet_right[i].y)	-- right
			for j=1,max_enemy1 do
				if (bullet_right[i].x-enemy1[j].x)*(bullet_right[i].x-enemy1[j].x)
					+ (bullet_right[i].y-enemy1[j].y)*(bullet_right[i].y-enemy1[j].y)
					< (e1_crash_r*e1_crash_r) then 
					PlaySound(s_e1_down)
					enemy1[j].health = enemy1[j].health - bullet_power			-- hit the target
					bullet_right[i].y = -1										-- remove this bullet
				end
			end
		end
	end

	if shoot_count == shoot_delay then 
		-- find an invalid(out of screen) bullet, set as a new bullet.
		for i=1,max_bullets do
			if bullet_left[i].y < 0 then
				bullet_left[i].x = hero_x-36
				bullet_left[i].y = hero_y-12
				bullet_right[i].x = hero_x+30
				bullet_right[i].y = hero_y-12
				PlaySound(s_bullet)
				break
			end
		end
		shoot_count = 0
	end
	shoot_count = shoot_count + 1

	----------------------enemies--------------------------------
	for i=1,max_enemy1 do
		if enemy1[i].health <= 0 then				-- enemy died
			enemy1[i].frame = enemy1[i].frame+1
			if enemy1[i].frame==frame_delay*4 then	-- reset
				enemy1[i].frame = 0
				enemy1[i].health = enemy1_health
				enemy1[i].y = -e1_h
				enemy1[i].x = math.random(bg_w)
			else
				PasteToImageEx(g_temp,g_enemy1_blowup,enemy1[i].x,enemy1[i].y,e1_blow_w,e1_blow_h,
					0,enemy1[i].frame//frame_delay*e1_blow_h,e1_blow_w,e1_blow_h)
			end
		else
			enemy1[i].y = enemy1[i].y + enemy_delay	-- enemy move
			if enemy1[i].y < bg_h then
				PasteToImage(g_temp,g_enemy1,enemy1[i].x,enemy1[i].y)
			else									-- out of screen, reset
				enemy1[i].y = -e1_h
				enemy1[i].x = math.random(bg_w)
			end
		end
	end

	-----------------------button--------------------------------
	if mouse_x < btn_w and mouse_y < btn_h + 4 then
		PasteToImageEx(g_temp,g_button,0,4,btn_w,btn_h,0,btn_h*3,btn_w,btn_h)
	else
		PasteToImageEx(g_temp,g_button,0,4,btn_w,btn_h,0,btn_h*2,btn_w,btn_h)
	end

	PasteToWndEx(WndGraphic,g_temp,0,0,core.screenwidth,core.screenheight,0,0,bg_w,bg_h)
	return ""
end

function current.OnClose()
	DeleteImage(g_hero)
	DeleteImage(g_hero_blowup)
	DeleteImage(g_bg)
	DeleteImage(g_button)
	DeleteImage(g_bullet1)
	DeleteImage(g_bullet2)
	DeleteImage(g_enemy1)
	--DeleteImage(g_enemy2)
	--DeleteImage(g_enemy3)
	DeleteImage(g_enemy1_blowup)

	DeleteImage(g_temp)
	StopSound(s_bgm)
end

function current.OnKeyDown(nChar)

end

function current.OnKeyUp(nChar)

end

function current.OnLButtonDown(x,y)
	if hero_life == 0 then
		game_start()
	elseif mouse_x < btn_w and mouse_y < btn_h + 4 then
		do return end 		-- pause clicked
	else
		bMouseDown=1
	end
end

function current.OnLButtonUp(x,y)
	bMouseDown=0
	if mouse_x < btn_w and mouse_y < btn_h + 4 then
		bPause = not bPause
	else
		last_mouse_x=x*bg_w//core.screenwidth
		last_mouse_y=y*bg_h//core.screenheight
	end
end

function current.OnMouseMove(x,y)
	mouse_x=x*bg_w//core.screenwidth	-- stretch convert
	mouse_y=y*bg_h//core.screenheight
end

function current.OnSetFocus()
	bPause = false
end

function current.OnKillFocus()
	bPause = true
end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current