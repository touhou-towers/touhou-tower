
//local BackgroundColor = Color( 0x16, 0x34, 0x55, 0.5 * 255 )
local BackgroundColorOnline = Color( 0x16, 0x70, 0x55, 0.5 * 255 )
local BackgroundColorOffline = Color( 0x70, 0x00, 0x00, 0.5 * 255 )
local BackgroundColor = Color( 0x16, 0x34, 0x55, 0.5 * 255 )

local MainTextFont = "GTowerHUDHuge"

function ENT:GetMainText()
	if !self.ServerOnline then
		return "OFFLINE"
	end
	
	if !self.ServerName || self.ServerName == nil then
		return "NO GAMEMODE NAME"
	end
	
	return self.ServerName
end

function ENT:ProcessMain()

	surface.SetFont( MainTextFont )
	local w,h = surface.GetTextSize( self:GetMainText() )

	self.MainTextTitleX = self.TotalMinX + self.TotalWidth / 2 - w / 2
	self.MainTextTitleY = self.TotalMinY + 15

	if !self.ServerOnline then
		self.MainTextTitleY = self.TotalMinY + 30
	end

	//local w,h = surface.GetTextSize( self.ServerStatus )

end

function ENT:DrawMain()

	local Server = self:GetServer()
	local BGColor = BackgroundColorOnline

	if Server && Server.Ready then
		BGColor = BackgroundColorOnline
	elseif !self.ServerOnline then
		BGColor = BackgroundColorOffline
	else
		BGColor = BackgroundColor
	end

	draw.RoundedBox( 2, self.TotalMinX + 5, self.TotalMinY + 5, self.TotalWidth  - 10, self.TopHeight - 5, BGColor  )

	//draw.RoundedBox( 2, self.TotalMinX + 5, self.TotalMinY + 5, self.TotalWidth  - 10, self.TopHeight - 5, BackgroundColor  )

	surface.SetFont( MainTextFont )
	surface.SetTextColor( 0xFF, 0xFF, 0xFF, 0xFF )

	/*if self.ServerOnline then
		surface.SetTextColor( 0xFF, 0xFF, 0xFF, 0xFF )
	else
		surface.SetTextColor( 0xFF, 0x0, 0x0, 0xFF )
	end*/

	surface.SetTextPos( self.MainTextTitleX,  self.MainTextTitleY )
	surface.DrawText( self:GetMainText() )

	if self.DrawGamemodeData then
		self:DrawGamemodeData()
	end

	local Server = self:GetServer()

	if Server && Server.RedirectingTime  then
		local TimeLeft = math.Clamp( Server.RedirectingTime - CurTime(), 0, 15 ) / 15

		surface.SetDrawColor( 30, 200, 30, 150 )
		surface.DrawRect( self.TotalMinX + 5, self.TotalMinY + self.TopHeight + 5, TimeLeft * (self.TotalWidth-10), 10 )

	end

end
