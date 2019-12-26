--[[
Module:			printer
Description:	text printer
Usage:
	global:		printer = load(GetText("lua/printer.lua"))()
	current.OnCreate:	printer.prepare(path_text_image, line_height)
	current.OnPaint:	printer.out(g_temp, xDest, yDest, id_string, opacity)
	current.OnClose:	printer.free()
]]
local printer = {
	g_text = nil,
	width = 0,
	line_height = 0,

	prepare = function(path_text_image, line_height)
		printer.g_text = GetImage(path_text_image)
		printer.line_height = line_height
		printer.width = GetWidth(printer.g_text)
	end,

	out = function(g, x, y, id, op)
		AlphaBlendEx(g, printer.g_text, x, y, printer.width, printer.line_height, 0, id*printer.line_height, printer.width, printer.line_height, op)
	end,

	free = function()
		DeleteImage(printer.g_text)
	end
}
return printer