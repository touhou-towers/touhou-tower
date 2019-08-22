
local PANEL = {}
surface.CreateFont( "GTowerHUDMainMedium", { font = "Oswald", size = 20, weight = 400 } )
surface.CreateFont( "GTowerToolTip", { font = "Tahoma", size = 16, weight = 400 } )
local TitleFont = "GTowerHUDMainMedium"
local SmallFont = "GTowerToolTip"

function PANEL:Init()
	self.Markup = nil
	self.IsHidding = false
	self.Alpha = 0
	
	self.Title = ""
	
	self.MarkupY = draw.GetFontHeight(TitleFont)
	self.PosX, self.PosY = gui.MousePos()
	self.TargetPosX, self.TargetPosY = 0, 0
	
	self:SetMouseInputEnabled( false )
end

function PANEL:GetTargetAlpha()
	if self.IsHidding then
		return 0
	end
	return 1
end

function PANEL:SetHidding( state )
	if self.IsHidding == state then
		return
	end

	self.IsHidding = state
	
	if vgui.CursorVisible() then
		self.TargetPosX, self.TargetPosY = gui.MousePos()
	else
		self.TargetPosX, self.TargetPosY = self.x, self.y
	end
	
	self.TargetPosX = self.TargetPosX + 20
	self.TargetPosY = self.TargetPosY + 20
end

function PANEL:PaintOver()
	local w, h = self:GetSize()
	local TextAlpha = self.Alpha * 255

	surface.SetDrawColor( 16, 70, 101, 220 )
	surface.DrawRect( 0, 0, w, h )

	surface.SetDrawColor( 16, 70, 101, 255 )
	surface.DrawRect( 0, 0, w, 2 )
	surface.DrawRect( 0, 0, 2, h )

	surface.DrawRect( w - 2, 0, 2, h )
	surface.DrawRect( 0, h - 2, w, 2 )

	surface.SetDrawColor( 6, 60, 90, 255 )
	surface.DrawRect( 0, 0, w, 20 )
	
	surface.SetFont( TitleFont )
	surface.SetTextColor( 255, 255, 255, TextAlpha )

	surface.SetTextPos( 4, 0 )
	surface.DrawText( self.Title )
	
	if self.Markup then
		self.Markup:Draw( 4, self.MarkupY, nil, nil, TextAlpha )
	end
end

function PANEL:SetText( title, description )

	surface.SetFont( TitleFont )
	
	self.Title = title or ""
	
	local w,h = surface.GetTextSize( self.Title )
	local MaxWidth = math.max( w + 8, 200 )

	self.Markup = markup.Parse( "<font=GTowerToolTip>" .. description or "" .. "</font>", MaxWidth - 8 )
	
	local MarkupWide = self.Markup:GetWidth()
	
	if MarkupWide + 8 < MaxWidth && w + 8 < MaxWidth then
		MaxWidth = math.max( MarkupWide + 8, w + 8 )
	end
	
	self:SetSize( MaxWidth, self.MarkupY + self.Markup:GetHeight() + 4 )

end

function PANEL:UpdatePos()
	self:SetPos( self.PosX, self.PosY )
end

function PANEL:Think()
	
	if self.IsHidding then
		self.PosX = ApproachSupport2( self.PosX, self.TargetPosX, 4 )
		self.PosY = ApproachSupport2( self.PosY, self.TargetPosY, 4 )
	else
		local MouseX, MouseY = gui.MousePos()
		
		self.PosX = ApproachSupport2( math.max( self.PosX, MouseX), MouseX + 10, 8 )
		self.PosY = ApproachSupport2( math.max( self.PosY, MouseY), MouseY + 10, 8 )
	end
	
	self.Alpha = ApproachSupport2( self.Alpha, self:GetTargetAlpha(), 8 )
	
	self:UpdatePos()
	
	if self.Alpha < (1/255) then
		GTowerItems:RemoveTooltip()
	end
end

function PANEL:PerformLayout()
	self:SetZPos( 3 )
end
	
vgui.Register("InvToolTip",PANEL, "Panel") 