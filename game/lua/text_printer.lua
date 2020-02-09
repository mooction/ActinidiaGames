--[[
Module:         printer
Description:    text printer
Usage:
    global:     obj = load(GetText("lua/printer.lua"))()
    current.OnCreate:   obj.prepare(obj, path_text_image, line_height)
    current.OnPaint:    obj.out(obj, g_temp, xDest, yDest, id_string, opacity)
    current.OnClose:    obj.free(obj)
]]
local printer = {
    g_text = nil,
    width = 0,
    line_height = 0,

    prepare = function(this, path_text_image, line_height)
        printer.g_text = GetImage(path_text_image)
        printer.line_height = line_height
        printer.width = GetWidth(printer.g_text)
    end,

    out = function(this, g, x, y, id, op)
        AlphaBlendEx(g, this.g_text, 
            x, y, this.width, this.line_height, 
            0, id*this.line_height, 
            this.width, this.line_height, op)
    end,

    free = function(this)
        DeleteImage(this.g_text)
    end
}

return printer
