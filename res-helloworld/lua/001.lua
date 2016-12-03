local current = {}

--[[ global
======================================================]]

z=0

--[[ messages
======================================================]]

function current.OnCreate()
	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	g= CreateImageEx(core.screenwidth,core.screenheight,core.white)
	z=z+1
	PrintText(g, 20, 10, z, 'Lucida Console', 14, core.black)
	PasteToWnd(WndGraphic,g)
	if z>1000 then z=0 end
	DeleteImage(g)
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

function current.OnMouseMove(x,y)
	
end

function current.OnSetFocus()

end

function current.OnKillFocus()

end

function current.OnMouseWheel(zDeta,x,y)
	
end

return current