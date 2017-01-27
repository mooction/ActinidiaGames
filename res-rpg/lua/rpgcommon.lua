--[[
Module:			rpgcommon
Description:	RPG common functions
TODO:
	global:		rpgcommon = load(GetText("res\\lua\\rpgcommon.lua"))()
	current.OnCreate:	rpgcommon.prepare(path_box, path_messagebox)
	current.OnClose:	rpgcommon.free()
]]
local rpgcommon = {
	screenwidth = 768,
	screenheight = 512,

	g_box = nil,
	g_messagebox = nil,

	-- 常量
	txtsmall = 18,
	txtnormal = 22,
	txtbig = 27,
	txtfont = "微软雅黑",
	black = 0x00181818,
	white = 0x00FFFFFF,

	prepare = function(path_box, path_messagebox)
		rpgcommon.g_box = GetImage(path_box)
		rpgcommon.g_messagebox = GetImage(path_messagebox)
	end,

	-- 显示交谈框
	talk = function(g_temp,g_portrait,title,text)
		local h = GetHeight(rpgcommon.g_box)
		PasteToImage(g_temp,rpgcommon.g_box,0,rpgcommon.screenheight-h)
		PasteToImage(g_temp,g_portrait,10,rpgcommon.screenheight-GetHeight(g_portrait))
		PrintText(g_temp, GetWidth(g_portrait)-50, rpgcommon.screenheight-h+6,
				 title, rpgcommon.txtfont, rpgcommon.txtbig, rpgcommon.black)
		PrintText(g_temp, GetWidth(g_portrait)-50, rpgcommon.screenheight-h+38,
				 text, rpgcommon.txtfont, rpgcommon.txtnormal, rpgcommon.black)
	end,

	alpha = 255,
	fade = {
		fast = 5, 		-- 4倍速
		normal = 2.5, 	-- 2倍速
		slow = 1.25 	-- 1倍速
	},

	-- 显示消息框，显示完毕返回true，否则false
	message = function(g_temp,text,fade)
		if rpgcommon.alpha ~= 45 then
			local dx = (rpgcommon.screenwidth - GetWidth(rpgcommon.g_messagebox))/2
			local dy = (rpgcommon.screenheight - GetHeight(rpgcommon.g_messagebox))/2
			AlphaBlend(g_temp,rpgcommon.g_messagebox,dx,dy,math.floor(rpgcommon.alpha))
			PrintText(g_temp,dx+32,dy+36,text,rpgcommon.txtfont,rpgcommon.txtnormal,rpgcommon.black)
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