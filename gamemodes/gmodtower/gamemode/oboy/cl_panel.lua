

-----------------------------------------------------
local PANEL = FindMetaTable("Panel")

function PANEL:DrawBorder( thick )

	local w, h = self:GetWide(), self:GetTall()
	surface.DrawRect( 0, 0, w, thick )
	surface.DrawRect( 0, h - thick, w, thick )

	surface.DrawRect( 0, thick, thick, h - ( thick * 2 ) )
	surface.DrawRect( w - thick, thick, thick, h - ( thick * 2 ) )

end

function PANEL:IsCursorWithinBounds()

	local w, h = self:GetSize()
	local mx, my = self:LocalCursorPos()

	return mx >= 0 && mx <= w && my >= 0 && my <= h

end

function PANEL:IsMouseOver()

	local x,y = self:CursorPos()
	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()

end

/*
function PANEL:UpdateMargins()

	self:SetPos( 
		self._MarginDistances.Right, 
		self._MarginDistances.Top
	)
	
	local Parent = self:GetParent()
	local PWidth, PHeight = Parent:GetSize()
	
	self:SetSize( 
		PWidth - self._MarginDistances.Right - self._MarginDistances.Left, 
		PHeight - self._MarginDistances.Top - self._MarginDistances.Bottom
	)
	
end


function PANEL:SetMargins( top, right, bottom, left )

	self._MarginDistances = {
		Top = top or 0,
		Right = right or 0,
		Bottom = bottom or 0,
		Left = left or 0	
	}
	
	self:UpdateMargins()

end
*/