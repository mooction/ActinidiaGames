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
	g= CreateImageEx(core.screenwidth,core.screenheight,core.white)
	PrintText(g, 20, 10, 'hello,world', 'Lucida Console', 14, core.black)
	PasteToWnd(WndGraphic,g)
	return ""
end

function current.OnClose()

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

function current.OnRButtonUp(x,y)

end

function current.OnMouseMove(x,y)
	
end

function current.OnSetFocus()

end

function current.OnKillFocus()

end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current