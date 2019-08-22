local PANEL = {}
PANEL.DEBUG = false
local OpenTime = 1 / 0.25 // 0.5 seconds

local BorderSize = 5
local SpaceBetweenItems = 5.6

local BackButton = surface.GetTextureID( "inventory/inv_main_bottom_extended" )
local BackMiddle = surface.GetTextureID( "inventory/inv_main_middle_extended" )

function PANEL:Init()
	self.CurYPos = 0

	self.ButtonHeight = 0
	self.ButtonWidth = 100
	self.Changing = true

end

function PANEL:Think()

	if self.TimerClose && CurTime() > self.TimerClose then
		self:Close()
	end

	if self.Changing then
		self:ChangingThink()
	end

end

function PANEL:ChangingThink()

	local TargetPos = self:GetTargetYPos()
	local NewYPos = math.Approach( self.CurYPos, TargetPos, math.max( FrameTime(), 0.01 ) * self:GetTall() * OpenTime )

	if NewYPos == TargetPos then
		self.Changing = false

		if NewYPos < 0 then
			self:SetVisible( false )
		end
	end

	self:SetPos( self.x, NewYPos )
	self.CurYPos = NewYPos

end

function PANEL:Paint( w, h )

	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.SetTexture( BackMiddle )
	surface.DrawTexturedRect( 0, 0, self.ButtonWidth, self:GetTall() - self.ButtonHeight )

	surface.SetTexture( BackButton )
	surface.DrawTexturedRect( 0, self:GetTall() - self.ButtonHeight, self.ButtonWidth, self.ButtonHeight )

	//surface.SetDrawColor( 255, 0, 0, 255 )
	//surface.DrawOutlinedRect( 0,0, self:GetWide(), self:GetTall() )

end

function PANEL:StopDragging()
	for _, v in pairs( GTowerItems.GtowerItems[1] ) do
		if IsValid( v._VGUI ) && v._VGUI:IsDragging() then
			v._VGUI:StopDrag()
		end
	end
end

function PANEL:PerformLayout()

	self.ButtonWidth, self.ButtonHeight = surface.GetTextureSize( BackButton )

	local CurX, CurY = BorderSize, BorderSize
	local MaxHeight = 1
	local TotalWidth = 500
	local HasItemsOnRow = false

	for k, v in pairs( GTowerItems.GtowerItems[1] ) do

		if !v._VGUI then
			GTowerItems:CreateItemOfID( k )
		end

		if !v._VGUI:Equippable() then
			HasItemsOnRow = true

			v._VGUI:OriginalPos( CurX, CurY )

			CurX = CurX + v._VGUI:GetWide() + SpaceBetweenItems

			if v._VGUI:GetTall() > MaxHeight then
				MaxHeight = v._VGUI:GetTall()
			end

			if CurX >= TotalWidth - v._VGUI:GetWide() then
				CurX = BorderSize
				CurY = CurY + v._VGUI:GetTall() + SpaceBetweenItems
				HasItemsOnRow = false
			end

			v._VGUI:UpdateParent()
			v._VGUI:InvalidateLayout()

		end

	end

	local Tall = CurY + BorderSize + SpaceBetweenItems

	if HasItemsOnRow == true then
		Tall = Tall + MaxHeight
	end

	self:SetSize( TotalWidth, Tall )
	self:SetPos( ScrW() / 1.975 - self:GetWide() / 2, self.CurYPos )

end

function PANEL:OnCursorEntered()

end

function PANEL:OnCursorExited()
	self:CheckClose()
end


/*===========================
 == External functions
=============================*/

function PANEL:Open()

	self.IsOpen = true
	self:UpdateChanging()
	self.GetTargetYPos = self.GetTargetYPosOpen
	self.TimerClose = nil

	self:SetVisible( true )

end

function PANEL:CloseTimer()

	self.TimerClose = CurTime() + 5.0

end

function PANEL:Close()

	self.IsOpen = false
	self:UpdateChanging()
	self:StopDragging()
	self.GetTargetYPos = self.GetTargetYPosClosed

end


function PANEL:ForceClose()
	self.CurYPos = self:GetTall() * -1
	self:SetPos( self.x, self.CurYPos )
	self:SetVisible( false )
end


function PANEL:CheckClose()

	if self.DEBUG then Msg2("InvMainDrop: Checking for closing") end

	if self.IsOpen == false then
		return
	end

	if self:IsMouseInWindow() then
		return
	end

	if GTowerItems.MainInvPanel:IsMouseInWindow() then
		return
	end

	if IsValid( GTowerItems.EntGrab.VGUI ) then //Make sure one of the outside entites are not being grabbed
		return
	end

	for _, v in pairs( GTowerItems.GtowerItems[1] ) do
		if v._VGUI && v._VGUI:IsDragging() then
			if self.DEBUG then Msg2("InvMainDrop: Found item being dragged, iginoring") end
			return
		end
	end

	if hook.Call("InvDropCheckClose", GAMEMODE ) == false then
		return
	end

	self:CloseTimer()

end


/*===========================
 == Internal functions
=============================*/

function PANEL:GetTargetYPosOpen()
	if GTowerItems.MainInvPanel then
		return GTowerItems.MainInvPanel.y + GTowerItems.MainInvPanel:GetTall()
	end

	return 0
end

function PANEL:UpdateChanging()
	self.Changing = true
end

function PANEL:GetTargetYPosClosed()
	if GTowerItems.MainInvPanel then
		return GTowerItems.MainInvPanel.y - self:GetTall()
	end

	return -self:GetTall()
end
PANEL.GetTargetYPos = PANEL.GetTargetYPosClosed


function PANEL:IsMouseInWindow()
    local x,y = self:CursorPos()
    return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end


vgui.Register("GTowerInvDrop",PANEL, "Panel")
