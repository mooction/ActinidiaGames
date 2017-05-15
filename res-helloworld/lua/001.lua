local current = {}

--[[ global
======================================================]]

--[[ messages
======================================================]]

function current.OnCreate()
	logo = GetImage("res\\actinidia.png")
	return ""
end

-- if need change map, return new map name
function current.OnPaint(WndGraphic)
	g= CreateImageEx(core.screenwidth,core.screenheight, 0xFFFFFFFF)
	
	local x = core.screenwidth - GetWidth(logo)
	local y = core.screenheight - GetHeight(logo)
	PasteToImage(g, logo, x//2, y//2)
	-- TODO: Add your code here.

	PasteToWnd(WndGraphic,g)
	DeleteImage(g)
	return ""
end

function current.OnClose()
	DeleteImage(logo)
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