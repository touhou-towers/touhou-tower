local SCORECARD = {}

SCORECARD.RowTall = 30

surface.CreateFont( "HudScoresTitle", { font = "FOP Title Style Font", size = 64 } )
surface.CreateFont( "HudScores", { font = "FOP Title Style Font", size = 20 } )

function SCORECARD:Init()

	self:SetSize( 1000, 600 )
	self:SetZPos( -1 )
	self:SetMouseInputEnabled( false )

	self.Avatars = {}

	for _, ply in pairs( player.GetAll() ) do

		local avatar = vgui.Create( "AvatarImage", self )

		/*if ply:IsHidden() then
			avatar:SetPlayer( nil )
		else*/
			avatar:SetPlayer( ply, 28 )
		//end

		avatar:SetSize( 28, 28 )
		self.Avatars[ply] = avatar

	end

end

function SCORECARD:Paint( w, h )

	local titleTall = 100
	local y = titleTall
	local x = self:DrawTitleRow( y - self.RowTall ) // Draw Title and get width

	self:DrawParRow( y ) // Draw par row

	y = y + self.RowTall

	// Draw player scores
	local players = player.GetAll()

	table.sort( players, function( a, b )
	
		local aScore, bScore = 0, 0
		local aSwing, bSwing = a:Swing(), b:Swing()
		local aFrag, bFrag = a:Frags(), b:Frags()

		if aSwing and aFrag then aScore = aSwing + aFrag end
		if bSwing and bFrag then bScore = bSwing + bFrag end

		return aScore < bScore

	end )

	for _, ply in pairs( players ) do

		self:DrawRow( ply, y, _ == 1 )
		y = y + self.RowTall

	end

	self:SetSize( x, y + 2 )

	draw.SimpleTextOutlined( "SCORES", "HudScoresTitle", x / 2, 32, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )

	// Bottom
	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( 0, self:GetTall() - 2, self:GetWide(), 2 )

	// Right
	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( self:GetWide() - 2, titleTall - self.RowTall, 2, self:GetTall() )

	// Left
	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( 0, titleTall - self.RowTall, 2, self:GetTall() )

end

function SCORECARD:DrawTitle( x, y, title, wide )

	local tall = 30
	surface.SetDrawColor( Color( 44, 83, 17, 255 ) )
	surface.DrawRect( x, y, wide, tall )

	surface.SetDrawColor( Color( 27, 42, 16, 255 ) )
	surface.DrawRect( x - 1, y, 2, tall )

	draw.SimpleText( title, "HudScores", x + wide / 2, y + tall / 2 + 2, Color( 61 + 100, 102 + 100, 31 + 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )

	return wide

end

local function reduce( str, font, width )



	surface.SetFont( font )



	local tw, th = surface.GetTextSize(str)

	while tw > width do

		str = string.sub( str, 1, string.len(str) - 1 )

		tw, th = surface.GetTextSize(str)

	end



	return str



end


function SCORECARD:DrawItem( x, y, title, wide, left, color )

	surface.SetDrawColor( Color( 27, 42, 16, 255 ) )
	surface.DrawRect( x - 1, y, 2, self.RowTall )

	local align = TEXT_ALIGN_CENTER

	if left then

		x = x + 10
		align = TEXT_ALIGN_LEFT

	else

		x = x + wide / 2

	end

	if title == 0 then

		title = "-"

	end

	if !color then

		color = Color( 255, 255, 255 )

	end

	draw.SimpleText( reduce(title, "HudScores", wide), "HudScores", x, y + self.RowTall / 2 + 2, color, align, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )

	return wide

end

function SCORECARD:DrawTitleRow( y )

	local x = 0

	// Title
	x = x + self:DrawTitle( x, y, "PLAYER", 200 )

	// Front Holes
	for i=1, 9 do

		x = x + self:DrawTitle( x, y, i, 32 )

	end
	x = x + self:DrawTitle( x, y, "FRONT", 80 )

	// Back Holes
	for i=10, 18 do

		x = x + self:DrawTitle( x, y, i, 32 )

	end
	x = x + self:DrawTitle( x, y, "BACK", 80 )

	// Total
	x = x + self:DrawTitle( x, y, "TOTAL", 100 )

	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( 0, y, self:GetWide(), 2 )

	return x

end

function SCORECARD:DrawParRow( y )

	local x = 0

	// Title
	x = x + self:DrawTitle( x, y, "PAR", 200 )

	// Front Holes
	local totalFront = 0

	for i=1, 9 do

		local val = GAMEMODE:GetParOfHole( i )
		totalFront = totalFront + val

		x = x + self:DrawTitle( x, y, val, 32 )

	end

	// Total Front
	x = x + self:DrawTitle( x, y, totalFront, 80 )



	// Back Holes
	local totalBack = 0

	for i=10, 18 do

		local val = GAMEMODE:GetParOfHole( i )
		totalBack = totalBack + val

		x = x + self:DrawTitle( x, y, val, 32 )

	end

	// Total Back
	x = x + self:DrawTitle( x, y, totalBack, 80 )

	// Total
	x = x + self:DrawTitle( x, y, totalFront + totalBack, 100 )

	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( 0, y, self:GetWide(), 2 )

end

function SCORECARD:DrawRow( ply, y, isFirst )

	// Background
	surface.SetDrawColor( Color( 61, 102, 31, 240 ) )
	surface.DrawRect( 0, y, self:GetWide(), self.RowTall )

	// Player
	if ply == LocalPlayer() then
	
		surface.SetDrawColor( Color( 255, 255, 255, SinBetween( 0, 10, CurTime() * 2 ) ) )
		surface.DrawRect( 0, y, self:GetWide(), self.RowTall )

	end

	local x = 0

	// Avatar
	local avatar = self.Avatars[ply]
	local avatarAdd = 0

	if ValidPanel( avatar ) then
	
		avatar:SetPos( 2, y + 2 )
		avatarAdd = avatar:GetWide() - 2

	end

	// Title
	x = x + self:DrawItem( avatarAdd + x, y, ply:Name(), 200-33, true ) + 33 -- HoleBoxSize + 1

	// Hole info...
	local function GetHoleInfo( i )

		local val = GAMEMODE:GetScoreOfPlayer( ply, i ) or 0
		local par = GAMEMODE:GetParOfHole( i )
		local color = Color( 255, 255, 255 )

		if val > par then

			color = Color( 250, 150, 150 )

		end

		return val, color

	end

	// Front Holes
	local totalFront = 0

	for i=1, 9 do

		local val, color = GetHoleInfo( i )
		totalFront = totalFront + val

		x = x + self:DrawItem( x, y, val, 32, false, color )

	end

	// Total Front
	x = x + self:DrawItem( x, y, totalFront, 80 )

	// Back Holes
	local totalBack = 0

	for i=10, 18 do

		local val, color = GetHoleInfo( i )
		totalBack = totalBack + val

		x = x + self:DrawItem( x, y, val, 32, false, color )

	end

	// Total Back
	x = x + self:DrawItem( x, y, totalBack, 80 )

	// Total
	x = x + self:DrawItem( x, y, totalFront + totalBack, 100 )

	surface.SetDrawColor( Color( 25, 49, 8, 255 ) )
	surface.DrawRect( 0, y, self:GetWide(), 2 )

	// First place
	if isFirst then

		surface.SetDrawColor( Color( 255, 0, 0, SinBetween( 0, 50, CurTime() * 10 ) ) )
		//surface.DrawRect( 0, y, self:GetWide(), self.RowTall )
		draw.RectBorder( 0, y + 2, self:GetWide() - 2, self.RowTall - 2, 2 )

	end

end

function SCORECARD:PerformLayout()

	self:Center()

end
vgui.Register( "Scorecard", SCORECARD )

function GM:DisplayScorecard( enable )

	if enable then

		if !ValidPanel( Scorecard ) then

			Scorecard = vgui.Create( "Scorecard" )
			self:RequestScores()

		end

	else

		if Scorecard && ValidPanel( Scorecard ) then

			Scorecard:Remove()
			Scorecard = nil

		end

	end

end