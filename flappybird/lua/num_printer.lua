--[[
Module:         num_printer
Description:    number printer
Usage:
    global:     obj = load(GetText("lua/num_printer.lua"))()
    current.OnCreate:   obj.prepare(obj, path_numImage, wNum, hNum)
    current.OnPaint:    obj.out(obj, g_temp, xDest, yDest, number)
    current.OnClose:    obj.free(obj)
]]
local printer = {
    g_num = nil,
    wNum=0,
    hNum=0,
    numberPerLine=0,

    prepare = function(this, path_numImage, wNum, hNum)
        this.g_num = GetImage(path_numImage)
        this.wNum = wNum
        this.hNum = hNum
        this.numberPerLine = GetWidth(this.g_num) // wNum
    end,

    __xpos__ = function( this, n )
        return n % this.numberPerLine * this.wNum
    end,

    __ypos__ = function( this, n )
        return n // this.numberPerLine * this.hNum
    end,

    out = function(this, g_temp, xDest, yDest, number)
        if number < 10 then
            PasteToImageEx(g_temp, this.g_num,
                xDest, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, number), this.__ypos__(this, number),
                this.wNum, this.hNum)
        elseif number < 100 then
            PasteToImageEx(g_temp, this.g_num,
                xDest, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, number//10), this.__ypos__(this, number//10),
                this.wNum, this.hNum)
            PasteToImageEx(g_temp, this.g_num,
                xDest + this.wNum, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, number % 10), this.__ypos__(this, number%10),
                this.wNum, this.hNum)
        else
            tnumber = number//100;  -- 百位数
            PasteToImageEx(g_temp, this.g_num,
                xDest, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, tnumber), this.__ypos__(this, tnumber),
                this.wNum, this.hNum)
            tnumber = number % 100;         -- 后两位数
            PasteToImageEx(g_temp, this.g_num,
                xDest + this.wNum, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, tnumber//10), this.__ypos__(this, tnumber//10),
                this.wNum, this.hNum)
            tnumber = tnumber % 10;         -- 个位数
            PasteToImageEx(g_temp, this.g_num,
                xDest + this.wNum + this.wNum, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, tnumber), this.__ypos__(this, tnumber),
                this.wNum, this.hNum)
        end
    end,

    free = function(this)
        DeleteImage(this.g_num)
    end
}
return printer
