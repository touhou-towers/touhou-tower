

-----------------------------------------------------
--[[   _                                
	( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 


--]]
local PANEL = {}

function PANEL:Init()

	self.BaseClass.Init( self )

	self:EnableVerticalScrollbar()

	self.VBar.btnUp:Remove()
	self.VBar.btnDown:Remove()

	self.VBar.OnCursorMoved = function( self, x, y )

		if ( !self.Enabled ) then return end
		if ( !self.Dragging ) then return end

		local x = 0
		local y = gui.MouseY()
		local x, y = self:ScreenToLocal( x, y )

		-- Uck.
		y = y - self.HoldPos

		local TrackSize = self:GetTall() - self:GetWide() * 2 - self.btnGrip:GetTall()

		y = y / TrackSize

		self:SetScroll( y * self.CanvasSize )	

	end

	self.VBar.PerformLayout = function( self )

		local Wide = self:GetWide()
		local Scroll = self:GetScroll() / self.CanvasSize
		local BarSize = math.max( self:BarScale() * (self:GetTall()), 10 )
		local Track = self:GetTall() - BarSize
		Track = Track + 1

		Scroll = Scroll * Track

		self.btnGrip:SetPos( 0, Scroll )
		self.btnGrip:SetSize( Wide, BarSize )

	end

end

--[[---------------------------------------------------------
   List Dragging
-----------------------------------------------------------]]

function PANEL:Think()

	if !self.ListDrag and self:IsCursorWithinBounds() and input.IsMouseDown(MOUSE_LEFT) then

		if ValidPanel(self.VBar) then

			-- Don't drag panel list if the scrollbar is already dragging
			if self.VBar.Dragging then
				return
			end

			self.DragScrollOffset = self.VBar:GetScroll()

		else
			local x, y = self.pnlCanvas:GetPos()
			self.DragScrollOffset = y
		end

		self.DragStartPos = gui.MouseY()
		self.ListDrag = true

	end

	if self.ListDrag then
		
		if input.IsMouseDown(MOUSE_LEFT) then

			local ydiff = self.DragStartPos - gui.MouseY()

			if ValidPanel(self.VBar) then
				self.VBar:SetScroll( self.DragScrollOffset + ydiff )
			else
				self.pnlCanvas:SetPos( 0, self.DragScrollOffset + ydiff )
			end

		else
			self.ListDrag = nil
		end

	end

end

derma.DefineControl( "DPanelList3", "", PANEL, "DPanelList" )
