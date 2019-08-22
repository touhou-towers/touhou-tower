
local PANEL = {}

function PANEL:Init() 
	self:SetFont( "GTowerbigbold" )
	self:SetText( "Close" )
	self:SetContentAlignment( 5 )
	self:SetSize( PvpBattle.HighestWidth * 0.75, 30 )
	self:Center()

	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
end

function PANEL:OnCursorEntered()
	self:SetTextColor( Color(255,255,255,255) )
end

function PANEL:OnCursorExited()
	self:SetTextColor( Color(180,180,180,255) )
end

function PANEL:OnMouseReleased()
	PvpBattle:CloseSelection()
end
	
function PANEL:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color(41,86,125,255) )
end

function PANEL:PerformLayout()

end

vgui.Register("PvpBtClose", PANEL, "DLabel")