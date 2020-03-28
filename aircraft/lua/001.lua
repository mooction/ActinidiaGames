local current = {}

--[[ global
======================================================]]
canvas_width = 480
canvas_height = 852
num_printer = load(GetText("lua/num_printer.lua"))

-- Constants
MOVE_SPEED_BULLET = 10
MOVE_SPEED_ENEMIY1 = 10
MOVE_SPEED_ENEMIY2 = 10
MOVE_SPEED_ENEMIY3 = 10

INTERVAL_ENEMY1 = 20
-- INTERVAL_ENEMY2 = 10
-- INTERVAL_ENEMY3 = 10
HERO_HEALTH = 5
ENEMY1_HEALTH = 1
-- ENEMY2_HEALTH = 4
-- ENEMY3_HEALTH = 50

hero = {
    x_center = canvas_width//2,
    y_center = canvas_height-20,
    health = HERO_HEALTH,
    left_bullets = {},
    right_bullets = {}
}
bMouseDown = false
bPause = false
counter = 0

function game_start()
    -- the counter is used for all animations, and a rand value makes the game more random.
    counter = math.random(0, 17)
    bPause = false
    hero = {
        move_speed = 6, -- px/17ms
        shoot_interval = 20,
        x_center = canvas_width//2,
        y_center = canvas_height-20,
        health = HERO_HEALTH,
        left_bullets = {},
        right_bullets = {}
    }
    enemies_1 = {}
    -- enemies_2 = {}
    -- enemies_3 = {}
end

function draw(g)
    PasteToWndEx(g,g_temp,0,0,core.screenwidth,core.screenheight,0,0,canvas_width,canvas_height)
end

--[[ messages
======================================================]]

function current.OnCreate()
    g_bg = GetImage("img/background.png")

    g_num_hero = num_printer()
    g_num_hero.prepare(g_num_hero, "img/hero.png", 102, 126)
    g_num_hero_blow = num_printer()
    g_num_hero_blow.prepare(g_num_hero_blow, "img/hero_blowup.png", 102, 126)
    g_num_button = num_printer()
    g_num_button.prepare(g_num_button, "img/button.png", 60, 45)

    g_enemy1 = GetImage("img/enemy1.png")
    g_num_enemy1_blow = num_printer()
    g_num_enemy1_blow.prepare(g_num_enemy1_blow, "img/enemy1_blowup.png", 57, 51)
    g_num_enemy2 = num_printer()
    g_num_enemy2.prepare(g_num_enemy2, "img/enemy2.png", 69, 99)
    g_num_enemy2_blow = num_printer()
    g_num_enemy2_blow.prepare(g_num_enemy2_blow, "img/enemy2_blowup.png", 69, 95)
    g_num_enemy3 = num_printer()
    g_num_enemy3.prepare(g_num_enemy3, "img/enemy3.png", 169, 258)
    g_num_enemy3_blow = num_printer()
    g_num_enemy3_blow.prepare(g_num_enemy3_blow, "img/enemy3_blowup.png", 165, 261)

    g_bullet1 = GetImage("img/bullet1.png")
    g_bullet2 = GetImage("img/bullet2.png")
    g_temp = CreateImage(canvas_width, canvas_height)

    s_bgm = GetSound("sound/game_music.mp3", true)
    s_gameover = GetSound("sound/game_over.mp3", false)
    s_btn = GetSound("sound/button.mp3", false)
    s_bullet = GetSound("sound/bullet.mp3", false)
    s_e1_blow = GetSound("sound/enemy1_down.mp3", false)
    --s_e2_blow = GetSound("sound/enemy2_down.mp3",false)
    --s_e3_blow = GetSound("sound/enemy3_down.mp3",false)

    math.randomseed(os.time())
    game_start()
    PlaySound(s_bgm)
    return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
    if bPause then 
        draw(WndGraphic)
        return ""
    end
    -- background
    PasteToImage(g_temp, g_bg, 0, 0)
    -- for all animations, this is necessary
    counter = counter + 1

    -- hero alive
    if hero.health > 0 then
        if bMouseDown then
            -- move hero
            if math.abs(mouse_x - hero.x_center) > hero.move_speed then
                if mouse_x > hero.x_center then
                    hero.x_center = hero.x_center + hero.move_speed
                else
                    hero.x_center = hero.x_center - hero.move_speed
                end
            end
            if math.abs(mouse_y - hero.y_center) > hero.move_speed then
                if mouse_y > hero.y_center then
                    hero.y_center = hero.y_center + hero.move_speed
                else
                    hero.y_center = hero.y_center - hero.move_speed
                end
            end
        end
        g_num_hero.out_(g_num_hero, g_temp,
            hero.x_center - g_num_hero.wNum//2,
            hero.y_center - g_num_hero.hNum//2, 0)
    else
        -- hero died
        g_num_hero_blow.out_(g_num_hero_blow, g_temp,
            hero.x_center - g_num_hero_blow.wNum//2,
            hero.y_center - g_num_hero_blow.hNum//2, 0)
        draw(WndGraphic)
        return ""
    end

    if counter % hero.shoot_interval == 0 then
        PlaySound(s_bullet)
        -- add bullets
        hero.left_bullets[#hero.left_bullets + 1] = {
            x = hero.x_center - 36,
            y = hero.y_center - 12
        }
        hero.right_bullets[#hero.right_bullets + 1] = {
            x = hero.x_center + 30,
            y = hero.y_center - 12
        }
    end

    -- move bullets and delete those bullets out of screen
    local out_of_screen_id = nil
    for k,v in pairs(hero.left_bullets) do
        v.y = v.y - MOVE_SPEED_BULLET
        if v.y < 0 then
            out_of_screen_id = k
        end
    end
    if out_of_screen_id then
        table.remove(hero.left_bullets, out_of_screen_id)
    end
    -- there's only one bullet will be deleted
    out_of_screen_id = nil
    for k,v in pairs(hero.right_bullets) do
        v.y = v.y - MOVE_SPEED_BULLET
        if v.y < 0 then
            out_of_screen_id = k
        end
    end
    if out_of_screen_id then
        table.remove(hero.right_bullets, out_of_screen_id)
    end

    -- draw bullets
    for k,v in pairs(hero.left_bullets) do 
        PasteToImage(g_temp, g_bullet1, v.x, v.y)
    end
    for k,v in pairs(hero.right_bullets) do 
        PasteToImage(g_temp, g_bullet1, v.x, v.y)
    end

    -- TODO: bullets hit to enemies. not implemented yet.



    -- generate some enemies 
    if counter % INTERVAL_ENEMY1 == 0 then
        enemies_1[#enemies_1 + 1] = {
            x_center = math.random(1, canvas_width),
            y_center = 0
        }
    end

    -- move enemies and delete those enemies out of screen
    local out_of_screen_id = nil
    for k,v in pairs(enemies_1) do
        v.y_center = v.y_center + MOVE_SPEED_ENEMIY1
        if v.y_center < 0 then
            out_of_screen_id = k
        end
    end
    if out_of_screen_id then
        table.remove(enemies_1, out_of_screen_id)
    end
    -- draw enemies
    for k,v in pairs(enemies_1) do 
        PasteToImage(g_temp, g_enemy1, v.x_center + GetWidth(g_enemy1)//2, v.y_center + GetHeight(g_enemy1)//2)
    end

    -- draw pause button
    if mouse_x < g_num_button.wNum and mouse_y < g_num_button.hNum then
        -- button pressed
        g_num_button.out_(g_num_button, g_temp, 0, 0, 3)
    else
        g_num_button.out_(g_num_button, g_temp, 0, 0, 2)
    end
    draw(WndGraphic)
    return ""
end

function current.OnClose()
    DeleteImage(g_bg)
    DeleteImage(g_bullet1)
    DeleteImage(g_bullet2)
    DeleteImage(g_enemy1)
    DeleteImage(g_temp)
    g_num_button.free(g_num_button)
    g_num_hero.free(g_num_hero)
    g_num_hero_blow.free(g_num_hero_blow)
    g_num_enemy1_blow.free(g_num_enemy1_blow)
    g_num_enemy2.free(g_num_enemy2)
    g_num_enemy2_blow.free(g_num_enemy2_blow)
    g_num_enemy3.free(g_num_enemy3)
    g_num_enemy3_blow.free(g_num_enemy3_blow)
    StopSound(s_bgm)
end

function current.OnKeyDown(nChar)

end

function current.OnKeyUp(nChar)

end

function current.OnLButtonDown(x,y)
    if hero.health == 0 then
        game_start()
    elseif x < g_num_button.wNum and y < g_num_button.hNum then
        -- click pause
    else
        bMouseDown=true
        mouse_x = x
        mouse_y = y
    end
end

function current.OnLButtonUp(x,y)
    bMouseDown=false
    if x < g_num_button.wNum and y < g_num_button.hNum then
        -- click pause
        bPause = not bPause
    end
end

function current.OnMouseMove(x,y)
    mouse_x=x
    mouse_y=y
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
