--[[
Module:			rpgcommon
Description:	RPG common functions
Usage:
	global:		rpgcommon = load(GetText("res\\lua\\rpgcommon.lua"))()
	current.OnCreate:	rpgcommon.prepare(path_box, path_messagebox)
	current.OnClose:	rpgcommon.free()
]]
local rpgcommon = {
	g_box = nil,
	g_messagebox = nil,

	black = 0xFF181818,
	white = 0xFFFFFFFF,

	prepare = function(path_box, path_messagebox)
		rpgcommon.g_box = GetImage(path_box)
		rpgcommon.g_messagebox = GetImage(path_messagebox)
	end,

	-- 显示交谈框
	talk = function(g, g_portrait, id_title, id_text)
		local h = GetHeight(rpgcommon.g_box)
		PasteToImage(g, rpgcommon.g_box, 0, canvas_height-h)
		PasteToImage(g, g_portrait, 10, canvas_height-GetHeight(g_portrait))
		printer.out(g, 164, canvas_height-110, id_title, 0xff)
		printer.out(g, 164, canvas_height-80, id_text, 0xff)
	end,

	alpha = 255,
	fade = {
		fast = 5, 		-- 4倍速
		normal = 2.5, 	-- 2倍速
		slow = 1.25 	-- 1倍速
	},

	-- 显示消息框，显示完毕返回true，否则false
	message = function(g, id, fade)
		if rpgcommon.alpha ~= 45 then
			local dx = (canvas_width - GetWidth(rpgcommon.g_messagebox))//2
			local dy = (canvas_height - GetHeight(rpgcommon.g_messagebox))//2
			AlphaBlend(g, rpgcommon.g_messagebox, dx, dy, math.floor(rpgcommon.alpha))
			printer.out(g, dx+34, dy+34, id, math.floor(rpgcommon.alpha))
			rpgcommon.alpha = rpgcommon.alpha - fade
			return false
		else
			rpgcommon.alpha = 255
			return true
		end
	end,

	free = function()
		DeleteImage(g_box)
		DeleteImage(g_messagebox)
	end
}
return rpgcommon