local PANEL = {}
local OpenTime = 2 / 0.5 // 0.5 seconds
local WepSelection = surface.GetTextureID( "inventory/inv_equip_extended" )

function PANEL:Init()

	self.TargeYPos = 0
	self.CurYPos = self.TargeYPos

	self.TextureW = 1
	self.TextureH = 1

	self.WeaponPlaces = {19,86, 153, 220, 288, 355,422,489}
end

function PANEL:ChangingThink()

	local NewYPos = math.Approach( self.CurYPos, self.TargeYPos, FrameTime() * self:GetTall() * OpenTime )

	if NewYPos == self.TargeYPos then
		self.Think = EmptyFunction

		if NewYPos < 0 then
			self:SetVisible( false )
		end
	end

	self:SetPos( self.x, NewYPos )
	self.CurYPos = NewYPos

end

function PANEL:Paint( w, h )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( WepSelection )
	surface.DrawTexturedRect( 0,0, self.TextureW, self.TextureH )

	//surface.SetDrawColor( 255, 0, 0, 255 )
	//surface.DrawOutlinedRect( 0,0, self:GetWide(), self:GetTall() )

end

function PANEL:PerformLayout()

	self.TextureW, self.TextureH = surface.GetTextureSize( WepSelection )

	self:SetSize( 565.33, 58 )
	self:SetPos( ScrW() / 2 - self:GetWide() / 2, self.CurYPos )
	self:SetZPos( 1 )

	for k, v in pairs( GTowerItems.GtowerItems[1] ) do

		if !v._VGUI then
			GTowerItems:CreateItemOfID( k )
		end

		if v._VGUI:Equippable() then

			if self.WeaponPlaces[ k ] then
				v._VGUI:OriginalPos( self.WeaponPlaces[ k ], 4 )
			end

			v._VGUI:UpdateParent()
			v._VGUI:InvalidateLayout()

		end

	end

end

function PANEL:OnCursorEntered()
	GTowerItems:OpenDropInventory()
end

function PANEL:OnCursorExited()
	GTowerItems:CheckSubClose()
end


/*===========================
 == External functions
=============================*/

function PANEL:Open()

	self.IsOpen = true
	self:UpdateChangingThink()
	self.TargeYPos = 0

	self:SetVisible( true )

end

function PANEL:Close()

	self.IsOpen = false
	self:UpdateChangingThink()
	self.TargeYPos = -self:GetTall()

end

function PANEL:ForceClose()
	self.CurYPos = self:GetTall() * -1
	self:SetPos( self.x, self.CurYPos )
	self:SetVisible( false )
end


/*===========================
 == Internal functions
=============================*/

function PANEL:UpdateChangingThink()
	self.Think = self.ChangingThink
end

function PANEL:IsMouseInWindow()
    local x,y = self:CursorPos()
    return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end



vgui.Register("GTowerInvMain",PANEL, "Panel")
