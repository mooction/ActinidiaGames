--[[
Module:			abkey
Description:	AB Key
TODO:
	global:		abkey = load(GetText("res\\lua\\abkey.lua"))()
	current.OnCreate:	abkey.prepare(path_keya, path_keyb)
	current.OnPaint:	abkey.draw(g_temp)
	current.OnClose:	abkey.free()
]]
local abkey = {
	right_a = 160,
	bottom_a = 120,
	right_b = 60,
	bottom_b = 60,

	prepare = function(path_keya, path_keyb)
		abkey_g_keya = GetImage(path_keya)
		abkey_keya_r = math.floor(GetHeight(abkey_g_keya) / 2)
		abkey_keya_x = core.screenwidth - abkey.right_a - abkey_keya_r
		abkey_keya_y = core.screenheight - abkey.bottom_a - abkey_keya_r

		abkey_g_keyb = GetImage(path_keyb)
		abkey_keyb_r = math.floor(GetHeight(abkey_g_keyb) / 2)
		abkey_keyb_x = core.screenwidth - abkey.right_b - abkey_keyb_r
		abkey_keyb_y = core.screenheight - abkey.bottom_b - abkey_keyb_r
	end,

	draw = function(g)
		PasteToImage(g,abkey_g_keya,abkey_keya_x-abkey_keya_r,abkey_keya_y-abkey_keya_r)
		PasteToImage(g,abkey_g_keyb,abkey_keyb_x-abkey_keyb_r,abkey_keyb_y-abkey_keyb_r)
	end,

	inKeyA = function()
		return ((abkey_keya_x - mouse_x)*(abkey_keya_x - mouse_x) + 
			(abkey_keya_y - mouse_y)*(abkey_keya_y - mouse_y) <= 
			abkey_keya_r*abkey_keya_r)
	end,

	inKeyB = function()
		return ((abkey_keyb_x - mouse_x)*(abkey_keyb_x - mouse_x) + 
			(abkey_keyb_y - mouse_y)*(abkey_keyb_y - mouse_y) <= 
			abkey_keyb_r*abkey_keyb_r)
	end,

	free = function()
		DeleteImage(abkey_g_keya)
		DeleteImage(abkey_g_keyb)
	end
}
return abkey