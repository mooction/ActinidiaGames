local core = load(GetText("res\\lua\\core.lua"))()

local current = {}
--encode: Chinese use GBK


--[[ global
======================================================]]



--[[ messages
======================================================]]

function current.OnCreate()
	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	g= CreateImageEx(300,200,core.white)
	PrintText(g, 20, 10, 'hello,world', 'Lucida Console', 14, core.black)
	PasteToWnd(WndGraphic,g)
	return ""
end

function current.OnClose()
	return 0 -- 0 exit, 1 cancel
end

function current.OnKeyDown(nChar)

end

function current.OnKeyUp(nChar)

end

function current.OnLButtonDown(x,y)

end

function current.OnLButtonUp(x,y)

end

function current.OnRButtonDown(x,y)

end

function current.OnLButtonUp(x,y)

end

function current.OnSetFocus()

end

function current.OnKillFocus()

end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current