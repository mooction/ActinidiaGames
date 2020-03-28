--[[
Module:         num_printer
Description:    number printer, also be used as image printer
Usage:
    global:     obj = load(GetText("lua/num_printer.lua"))()
    current.OnCreate:   obj.prepare(obj, path_numImage, wNum, hNum)
    current.OnPaint:    obj.out(obj, g_temp, xDest, yDest, number, length=nil)
                        obj.out_(obj, g_temp, xDest, yDest, index, alpha=255)
                        obj.scale_out_(obj, g_temp, xDest, yDest, index, ratio, alpha=255)
    current.OnClose:    obj.free(obj)
]]
local printer = {
    g_num = nil,
    wNum=0,
    hNum=0,
    nItemsPerLine=0,

    prepare = function(this, path_numImage, wNum, hNum)
        this.g_num = GetImage(path_numImage)
        this.wNum = wNum
        this.hNum = hNum
        this.nItemsPerLine = GetWidth(this.g_num) // wNum
    end,

    __xpos__ = function(this, n)
        return n % this.nItemsPerLine * this.wNum
    end,

    __ypos__ = function(this, n)
        return n // this.nItemsPerLine * this.hNum
    end,

    -- print a series of integers
    out = function(this, g_temp, xDest, yDest, number, length)
        if number < 0 then
            do return end
        end
        local i = number
        local n = 0
        local arr = {}
        while i//10 ~= 0 do
            arr[n] = i % 10
            i = i//10
            n = n + 1
        end
        arr[n] = i
        if length and length > n+1 then
            for i=n+1, length-1 do
                arr[i] = 0 -- Zero prefix
                n=length-1
            end
        end
        for i=0, n do
            PasteToImageEx(g_temp, this.g_num,
                xDest + this.wNum*i, yDest,
                this.wNum, this.hNum,
                this.__xpos__(this, arr[n-i]), this.__ypos__(this, arr[n-i]),
                this.wNum, this.hNum)
        end
    end,

    -- print a single symbol
    out_ = function(this, g_temp, xDest, yDest, index, alpha)
        if index < 0 then
            do return end
        end
        if alpha then
            AlphaBlendEx(g_temp, this.g_num,
                xDest, yDest, this.wNum, this.hNum, 
                this.__xpos__(this, index), this.__ypos__(this, index),
                this.wNum, this.hNum, alpha)
        else
            PasteToImageEx(g_temp, this.g_num,
                xDest, yDest, this.wNum, this.hNum, 
                this.__xpos__(this, index), this.__ypos__(this, index),
                this.wNum, this.hNum)
        end
    end,

    -- print a single symbol
    scale_out_ = function(this, g_temp, xDest, yDest, index, ratio, alpha)
        local n_w = math.floor(this.wNum * ratio)
        local n_h = math.floor(this.hNum * ratio)
        if alpha then
            AlphaBlendEx(g_temp, this.g_num,
                xDest, yDest, n_w, n_h, 
                this.__xpos__(this, index), this.__ypos__(this, index),
                this.wNum, this.hNum, alpha)
        else
            PasteToImageEx(g_temp, this.g_num,
                xDest, yDest, n_w, n_h, 
                this.__xpos__(this, index), this.__ypos__(this, index),
                this.wNum, this.hNum)
        end
    end,

    free = function(this)
        DeleteImage(this.g_num)
    end
}
return printer
