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
	g_msgbox = nil,
	dx_box = 0,
	dy_box = 0,
	dx_msg = 0,
	dy_msg = 0,
	
	prepare = function(path_box, path_msgbox)
		rpgcommon.g_box = GetImage(path_box)
		rpgcommon.g_msgbox = GetImage(path_msgbox)

		rpgcommon.dx_box = (canvas_width - GetWidth(rpgcommon.g_box))//2
		rpgcommon.dy_box = canvas_height - GetHeight(rpgcommon.g_box)

		rpgcommon.dx_msg = (canvas_width - GetWidth(rpgcommon.g_msgbox))//2
		rpgcommon.dy_msg = (canvas_height - GetHeight(rpgcommon.g_msgbox))//2
	end,

	-- 显示交谈框
	talk = function(g, g_portrait, id_title, id_text)
		PasteToImage(g, rpgcommon.g_box, rpgcommon.dx_box, rpgcommon.dy_box)
		PasteToImage(g, g_portrait, rpgcommon.dx_box, canvas_height-GetHeight(g_portrait))
		printer.out(g, rpgcommon.dx_box+160, rpgcommon.dy_box+16, id_title, 0xff)
		printer.out(g, rpgcommon.dx_box+160, rpgcommon.dy_box+46, id_text, 0xff)
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
			AlphaBlend(g, rpgcommon.g_msgbox, rpgcommon.dx_msg, rpgcommon.dy_msg, math.floor(rpgcommon.alpha))
			printer.out(g, rpgcommon.dx_msg+34, rpgcommon.dy_msg+34, id, math.floor(rpgcommon.alpha))
			rpgcommon.alpha = rpgcommon.alpha - fade
			return false
		else
			rpgcommon.alpha = 255
			return true
		end
	end,

	free = function()
		DeleteImage(rpgcommon.g_box)
		DeleteImage(rpgcommon.g_msgbox)
	end
}
return rpgcommon