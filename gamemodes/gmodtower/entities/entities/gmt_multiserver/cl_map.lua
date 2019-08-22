
local  BackgroundColor = Color( 0x05, 0x015, 0x026, 0.8 * 255 )
local  smallerBackgroundColor = Color( 0x0, 0x0, 0x0, 0.4 * 255 )

local CurrentMapFont = "GTowerHUDMainTiny"
local CurrentMapFontHeight = 10

local MapFont = "GTowerHUDMainSmall"
local MapFontHeight = 16

function ENT:ProcessMapPos()

	local MapBoxHeight = self.PlayerWidth * 0.9
	local SmallerBox = MapBoxHeight * 0.7

	local MapBoxYPos = math.max(
		self.PlayerStartY,
		self.TotalMinY + self.TopHeight + (self.TotalHeight-self.TopHeight) / 2 - MapBoxHeight / 2
	)
	local MapBoxXpos = self.TotalMinX + self.TotalWidth * (5/6) - MapBoxHeight / 2

	self.MapBoxSize = MapBoxHeight
	self.MapBoxXpos = MapBoxXpos
	self.MapBoxYPos = MapBoxYPos

	self.SmallerBoxSize = SmallerBox
	self.SmallerBoxX = self.MapBoxXpos + MapBoxHeight * 0.5 - SmallerBox * 0.5
	self.SmallerBoxY = self.MapBoxYPos + MapBoxHeight - SmallerBox - 5

	surface.SetFont( CurrentMapFont )
	CurrentMapFontHeight = draw.GetFontHeight( CurrentMapFont )

	self.CurrentMapWidthSize = surface.GetTextSize( "CURRENT MAP" )

	surface.SetFont( MapFont )
	MapFontHeight = draw.GetFontHeight( MapFont )

	self.MapWidthSize = surface.GetTextSize( string.upper( self.ServerMap ) )

end


function ENT:DrawMap()

	draw.RoundedBox( 2, self.MapBoxXpos, self.MapBoxYPos, self.MapBoxSize, self.MapBoxSize, BackgroundColor  )


	if self.MapTexture then
		surface.SetMaterial( self.MapTexture )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( self.SmallerBoxX, self.SmallerBoxY, self.SmallerBoxSize, self.SmallerBoxSize )
	else
		draw.RoundedBox( 2, self.SmallerBoxX, self.SmallerBoxY, self.SmallerBoxSize, self.SmallerBoxSize, smallerBackgroundColor  )
	end

	surface.SetFont( CurrentMapFont )
	surface.SetTextColor( 0xAB, 0xBA, 0xCA, 0xFF )
	surface.SetTextPos( self.MapBoxXpos + self.MapBoxSize / 2 - self.CurrentMapWidthSize / 2,  self.MapBoxYPos + 4 )
	surface.DrawText( "CURRENT MAP" )

	surface.SetFont( MapFont )
	surface.SetTextColor( 0xFF, 0xFF, 0xFF, 0xFF )
	surface.SetTextPos( self.MapBoxXpos + self.MapBoxSize / 2 - self.MapWidthSize / 2,  self.MapBoxYPos + 4 + CurrentMapFontHeight + 4 )
	surface.DrawText( string.upper( self.ServerMap ) )


end
