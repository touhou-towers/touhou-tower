

-----------------------------------------------------
local PANEL = {}
function PANEL:Init()

	self:SetZPos( 100 )
	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )
	self:SetSize( ScrW(), ScrH() )

end

function PANEL:SetOrigin( x, y )

	self.OriginX = x
	self.OriginY = y

end

function PANEL:SetLimits( xlimit, ylimit )

	self.XLimit = xlimit
	self.YLimit = ylimit

end

local Circle = surface.GetTextureID( "gui/faceposer_indicator" )

function PANEL:Paint()

	local x, y = gui.MouseX(), gui.MouseY()

	if self.XLimit then x = self.OriginX end
	if self.YLimit then y = self.OriginY end

	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.DrawLine( self.OriginX, self.OriginY, x, y )

	// Origin
	local size = 10
	surface.SetTexture( Circle )
	surface.DrawTexturedRect( self.OriginX - size, self.OriginY - size, size*2, size*2 )

	// Mouse
	local size = 5
	surface.SetTexture( Circle )
	surface.DrawTexturedRect( x-size, y-size, size*2, size*2 )

end

derma.DefineControl( "DModelMouseDrag", "Mouse Drag Panel", PANEL )


module( "MouseDrag", package.seeall )

Panel = nil

function Enable( bool, originX, originY, popup, xlimit, ylimit )

	if bool then

		if ValidPanel( Panel ) then return end
		Panel = vgui.Create( "DModelMouseDrag" )
		Panel:SetOrigin( originX, originY )
		Panel:SetLimits( xlimit, ylimit )

		if popup then
			Panel:MakePopup()
		end

	else

		if !ValidPanel( Panel ) then return end
		Panel:Remove()
		Panel = nil

	end

end