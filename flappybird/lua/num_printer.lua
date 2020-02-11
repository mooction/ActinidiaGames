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

    __xpos__ = function(this, n)
        return n % this.numberPerLine * this.wNum
    end,

    __ypos__ = function(this, n)
        return n // this.numberPerLine * this.hNum
    end,

    out = function(this, g_temp, xDest, yDest, number)
        local i = number
        local n = 0
        local arr = {}
        while i//10 ~= 0 do
            arr[n] = i % 10
            i = i//10
            n = n + 1
        end
        arr[n] = i
        for i=0, n do
            PasteToImageEx(g_temp, this.g_num,
                xDest + this.wNum*i, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, arr[n-i]), this.__ypos__(this, arr[n-i]),
                this.wNum, this.hNum)
        end
    end,

    free = function(this)
        DeleteImage(this.g_num)
    end
}
return printer
