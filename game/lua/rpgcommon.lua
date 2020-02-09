--[[
Module:         rpgcommon
Description:    RPG common functions
Usage:
    global:     rpgcommon = load(GetText("lua/rpgcommon.lua"))()
    current.OnCreate:   rpgcommon.prepare(path_box, path_messagebox)
    current.OnClose:    rpgcommon.free()
]]
local rpgcommon = {
    g_box = nil,
    g_msgbox = nil,
    g_dlg = nil,
    g_dlgbtn = nil,
    dx_box = 0,
    dy_box = 0,
    dx_msg = 0,
    dy_msg = 0,
    dx_dlg = 0,
    dy_dlg = 0,
    dy_dlgbtn = 0,
    btn_width = 0,
    btn_height = 0,

    prepare = function(path_box, path_msgbox, path_dlg, path_dlgbtn)
        rpgcommon.g_box = GetImage(path_box)
        rpgcommon.g_msgbox = GetImage(path_msgbox)
        rpgcommon.g_dlg = GetImage(path_dlg)
        rpgcommon.g_dlgbtn = GetImage(path_dlgbtn)

        rpgcommon.dx_box = (canvas_width - GetWidth(rpgcommon.g_box))//2
        rpgcommon.dy_box = canvas_height - GetHeight(rpgcommon.g_box)

        rpgcommon.dx_msg = (canvas_width - GetWidth(rpgcommon.g_msgbox))//2
        rpgcommon.dy_msg = (canvas_height - GetHeight(rpgcommon.g_msgbox))//2

        rpgcommon.dx_dlg = (canvas_width - GetWidth(rpgcommon.g_dlg))//2
        rpgcommon.dy_dlg = (canvas_height - GetHeight(rpgcommon.g_dlg))//2

        rpgcommon.dy_dlgbtn = (canvas_height + GetHeight(rpgcommon.g_dlg))//2 - 50
        rpgcommon.btn_width = GetWidth(rpgcommon.g_dlgbtn)//2
        rpgcommon.btn_height = GetHeight(rpgcommon.g_dlgbtn)//2
    end,

    -- 显示交谈框
    talk = function(g, g_portrait, id_title, id_text)
        PasteToImage(g, rpgcommon.g_box, rpgcommon.dx_box, rpgcommon.dy_box)
        PasteToImage(g, g_portrait, rpgcommon.dx_box, canvas_height-GetHeight(g_portrait))
        printer.out(printer, g, rpgcommon.dx_box+160, rpgcommon.dy_box+16, id_title, 0xff)
        printer.out(printer, g, rpgcommon.dx_box+160, rpgcommon.dy_box+46, id_text, 0xff)
    end,

    alpha = 255,
    fade = {
        fast = 5,       -- 4倍速
        normal = 2.5,   -- 2倍速
        slow = 1.25     -- 1倍速
    },

    -- 显示消息框，显示完毕返回true，否则false
    message = function(g, id, fade)
        if rpgcommon.alpha ~= 45 then
            AlphaBlend(g, rpgcommon.g_msgbox, rpgcommon.dx_msg, rpgcommon.dy_msg, math.floor(rpgcommon.alpha))
            printer.out(printer, g, rpgcommon.dx_msg+34, rpgcommon.dy_msg+34, id, math.floor(rpgcommon.alpha))
            rpgcommon.alpha = rpgcommon.alpha - fade
            return false
        else
            rpgcommon.alpha = 255
            return true
        end
    end,

    -- 显示对话框，鼠标在确定上返回1，取消上返回-1，其他位置返回0
    dialog = function(g, id, mouse_x, mouse_y)
        PasteToImage(g, rpgcommon.g_dlg, rpgcommon.dx_dlg, rpgcommon.dy_dlg)
        printer.out(printer, g, rpgcommon.dx_dlg+34, rpgcommon.dy_dlg+48, id, 0xff)
        local retval = 0
        if mouse_y>rpgcommon.dy_dlgbtn and mouse_y<rpgcommon.dy_dlgbtn+rpgcommon.btn_height then
            if mouse_x>rpgcommon.dx_dlg+150 and mouse_x<rpgcommon.dx_dlg+150+rpgcommon.btn_width then
                PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+150, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                    rpgcommon.btn_width,0,rpgcommon.btn_width,rpgcommon.btn_height)
                retval=1
            else
                PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+150, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                    0,0,rpgcommon.btn_width,rpgcommon.btn_height)
            end

            if mouse_x>rpgcommon.dx_dlg+280 and mouse_x<rpgcommon.dx_dlg+280+rpgcommon.btn_width then
                PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+280, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                    rpgcommon.btn_width,rpgcommon.btn_height,rpgcommon.btn_width,rpgcommon.btn_height)
                retval=-1
            else
                PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+280, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                    0,rpgcommon.btn_height,rpgcommon.btn_width,rpgcommon.btn_height)
            end
        else
            PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+150, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                0,0,rpgcommon.btn_width,rpgcommon.btn_height)
            PasteToImageEx(g, rpgcommon.g_dlgbtn, rpgcommon.dx_dlg+280, rpgcommon.dy_dlgbtn, rpgcommon.btn_width, rpgcommon.btn_height,
                0,rpgcommon.btn_height,rpgcommon.btn_width,rpgcommon.btn_height)
        end
        return retval
    end,

    free = function()
        DeleteImage(rpgcommon.g_box)
        DeleteImage(rpgcommon.g_msgbox)
        DeleteImage(rpgcommon.g_dlg)
    end
}
return rpgcommon