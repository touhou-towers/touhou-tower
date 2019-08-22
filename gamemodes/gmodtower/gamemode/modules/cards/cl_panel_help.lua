
-----------------------------------------------------
// ========================================================
// POKER BOARD HELP PANEL
// ========================================================
local PANEL = {}
PANEL.Help = Material( "gmod_tower/casino/pokerguide.png" )

function PANEL:Init()

	self.Button = vgui.Create( "DButton", self )
	self.Button:SetText( "" )
	self.Button.Paint = function() end
	self.Button.DoClick = function()
		self:Remove()
	end

end

function PANEL:Paint( w, h )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( self.Help )
	surface.DrawTexturedRect( 0, 0, w, h )

end

function PANEL:PerformLayout()

	self.Button:SetSize( self:GetSize() )

end

vgui.Register( "PokerHelpPanel", PANEL )