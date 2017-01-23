--[[
Module:			rocker
Description:	Rocker implement
TODO:
	global:		rocker = load(GetText("res\\lua\\rocker.lua"))()
	current.OnCreate:	rocker.prepare(path_circle, path_circle_touch)
	current.OnPaint:	rocker.draw(g_temp,mouse_x,mouse_y)
	current.OnClose:	rocker.free()
]]
local rocker = {
	left = 60,
	bottom = 60,

	prepare = function(path_circle, path_circle_touch)
		rocker_g_circle = GetImage(path_circle)
		rocker_circle_r = math.floor(GetHeight(rocker_g_circle) / 2)
		rocker_circle_x = rocker.left + rocker_circle_r
		rocker_circle_y = core.screenheight - rocker_circle_r - rocker.bottom

		rocker_g_circle_touch = GetImage(path_circle_touch)
		rocker_circle_touch_r = math.floor(GetHeight(rocker_g_circle_touch) / 2)
	end,

	-- get the degree from mouse position to center of the circle, range(-90 ~ 270)
	getDegree = function(mouse_x,mouse_y)
		-- devide zero
		if mouse_x == rocker_circle_x then
			do return ((mouse_y<rocker_circle_y and 90) or -90) end
		end
		local temp = (rocker_circle_y - mouse_y)/(mouse_x - rocker_circle_x)
		if mouse_x > rocker_circle_x then
			do return math.deg(math.atan(temp)) end
		else
			do return (math.deg(math.atan(temp))+180) end
		end
	end,

	draw = function(g, mouse_x, mouse_y)
		-- rocker area
		PasteToImage(g,rocker_g_circle,rocker.left,rocker_circle_y-rocker_circle_r)
		-- inside
		if (rocker_circle_x - mouse_x)*(rocker_circle_x - mouse_x) + 
			(rocker_circle_y - mouse_y)*(rocker_circle_y - mouse_y) <= 
			rocker_circle_r*rocker_circle_r then
			PasteToImage(g, rocker_g_circle_touch,
				mouse_x - rocker_circle_touch_r, mouse_y - rocker_circle_touch_r)
			do return end
		end
		-- devide zero
		if mouse_x == rocker_circle_x then
			do return end
		end
		-- outside
		local temp = (rocker_circle_y - mouse_y)/(mouse_x - rocker_circle_x)	-- 除数不为零
		local circle_touch_x = rocker_circle_x - rocker_circle_touch_r
		local circle_touch_y = rocker_circle_y - rocker_circle_touch_r
		if mouse_x > rocker_circle_x then
			PasteToImage(g,rocker_g_circle_touch,
				circle_touch_x + math.floor(rocker_circle_r/math.sqrt(1+temp*temp)),
				circle_touch_y - math.floor(rocker_circle_r*temp/math.sqrt(1+temp*temp)))
		else
			PasteToImage(g,rocker_g_circle_touch,
				circle_touch_x - math.floor(rocker_circle_r/math.sqrt(1+temp*temp)),
				circle_touch_y + math.floor(rocker_circle_r*temp/math.sqrt(1+temp*temp)))
		end
	end,

	free = function()
		DeleteImage(rocker_g_circle)
		DeleteImage(rocker_g_circle_touch)
	end
}
return rocker