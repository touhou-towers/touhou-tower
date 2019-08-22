

-----------------------------------------------------

DUELSCREEN = {}

function DUELSCREEN:Init()

	self:SetSize( ScrW(), ScrH() )
	self:SetZPos( -1 )

	self.Title = Label( "DUEL TO THE DEATH", self )
	self.Title:SetFont( "DuelExtraLarge" )
	self.Title:SetTextColor( Color( 255, 255, 255, 255 ) )

	/*self.VS = Label( "VS", self )
	self.VS:SetFont( "DuelExtraLarge" )
	self.VS:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.VS:SetVisible( false )*/

	self.Bet = Label( "", self )
	self.Bet:SetFont( "DuelExtraLarge" )
	self.Bet:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Bet:SetVisible( false )

	self.Player1 = vgui.Create( "DuelName", self )
	self.Player1:InvalidateLayout()

	self.Player2 = vgui.Create( "DuelName", self )
	self.Player2:InvalidateLayout()

	local wager = CreateSound( LocalPlayer(), Sounds.Wager )
	wager:Play()

	timer.Simple(DuelStartDelay,function()
		if wager then
			wager:Stop()
		end

		self:Remove()

	end)

end

function DUELSCREEN:SetPlayers( ply1, ply2 )

	self.Player1:SetPlayer( ply1 )
	self.Player2:SetPlayer( ply2 )

	if DuelAmount > 0 then
		self.Bet:SetText( "FOR " .. string.FormatNumber( DuelAmount ) .. " GMC" )
	end

end

function DUELSCREEN:PerformLayout()

	if self.Title then

		self.Title:SizeToContents()
		self.Title:SetPos( 0, ScrH() * .05 )
		self.Title:CenterHorizontal()

	end

	//self.VS:SizeToContents()
	//self.VS:Center()

	if self.Bet then

		self.Bet:SizeToContents()
		self.Bet:SetPos( 0, ScrH() * .85 )
		self.Bet:CenterHorizontal()

	end

	if IsValid(self.Player1) && IsValid(self.Player2) then
		self.Player1:SizeToContents()
		self.Player1:CenterVertical()

		self.Player2:SizeToContents()
		self.Player2:CenterVertical()
	end

end

function DUELSCREEN:Think()
	if !IsValid(self.Player1) || !IsValid(self.Player2) then return end

	if !self.Player1FinalPosX then
		self.Player1:AlignLeft()
		self.Player1FinalPosX = self.Player1.x
		self.Player1.x = ( self.Player1:GetWide() + 10 ) * - 1
	end

	if !self.Player2FinalPosX then
		self.Player2:AlignRight()
		self.Player2FinalPosX = self.Player2.x
		self.Player2.x = ScrW() + self.Player2:GetWide() + 10
	end

	if !self.Player1FinalPosY then
		self.Player1.y = ( ScrH() / 2 )
		self.Player1FinalPosY = ( ScrH() / 2 ) - 200
	end

	if !self.Player2FinalPosY then
		self.Player2.y = ( ScrH() / 2 )
		self.Player2FinalPosY = ( ScrH() / 2 ) + 200
	end

	self.Player1.x = math.Approach( self.Player1.x, self.Player1FinalPosX, FrameTime() * 1600 )
	self.Player2.x = math.Approach( self.Player2.x, self.Player2FinalPosX, FrameTime() * 1600 )

	if self.Player1.x == self.Player1FinalPosX && self.Player2.x == self.Player2FinalPosX then
		//self.VS:SetVisible( true )
		self.Bet:SetVisible( true )
		//surface.PlaySound( Dueling.Sounds.Hit )
	end

end

local gradientUp = surface.GetTextureID( "VGUI/gradient_up" )
local gradientDown = surface.GetTextureID( "VGUI/gradient_down" )

function DUELSCREEN:Paint( w, h )

	surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, ScrW(), 120 )

	surface.SetTexture( gradientDown )
	surface.DrawTexturedRect( 0, 120, ScrW(), 80 )

	surface.DrawRect( 0, ScrH() - 120, ScrW(), 120 )

	surface.SetTexture( gradientUp )
	surface.DrawTexturedRect( 0, ScrH() - ( 120 + 80 ), ScrW(), 80 )

	if self.Player1.x == self.Player1FinalPosX && self.Player2.x == self.Player2FinalPosX then
		local tx, ty = ScrW() / 2, ScrH() / 2
		draw.SimpleText( "VS", "DuelExtraLarge", tx + 2, ty + 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "VS", "DuelExtraLarge", tx, ty, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

end

vgui.Register( "DuelScreen", DUELSCREEN )


local DUELNAME = {}
DUELNAME.AvatarSize = 180
DUELNAME.Padding = 4

function DUELNAME:Init()

	self:SetSize( self.AvatarSize + self.Padding + ( ScrW() * .35 ), self.AvatarSize + self.Padding )
	self:SetZPos( 1 )
	self:SetMouseInputEnabled( false )

	self.AvatarBGY = 128
	self.AvatarBGYEnd = -128

	self.Title = Label( "", self )
	self.Title:SetFont( "DuelBigName" )
	self.Title:SetTextColor( Color( 255, 255, 255, 255 ) )

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( self.AvatarSize, self.AvatarSize )
	self.Avatar:SetZPos( -1 )

	/*self.AvatarBG = vgui.Create( "AvatarImage", self )
	self.AvatarBG:SetSize( 512, 512 )
	self.AvatarBG:SetZPos( -2 )*/

end

function DUELNAME:SetPlayer( ply )

	if !IsValid( ply ) then return end

		self.Avatar:SetPlayer( ply, 64 )
	//self.AvatarBG:SetPlayer( ply, 512 )
	self.Player = ply

	//self.AvatarBGY = 128
	//self.AvatarBGYEnd = -128

	local name = ply:Name() or ""
	if ply == LocalPlayer() then
		name = "YOU"
	end

	self.Title:SetText( name )

end

function DUELNAME:PerformLayout()

	local half = self.Padding / 2
	local offsetX, offsetY = half, half

	self.Avatar:SetPos( offsetX, offsetY )

	/*self.AvatarBGY = math.Approach( self.AvatarBGY, self.AvatarBGYEnd, FrameTime() * 40 )
	self.AvatarBG:SetPos( 0, self.AvatarBGY )*/

	self.Title:SizeToContents()
	self.Title:CenterVertical()
	self.Title:AlignLeft( self.Avatar:GetWide() + ( self.Padding * 2 ) )

	self:InvalidateLayout()

end

function DUELNAME:Paint( w, h )

	if !IsValid( self.Player ) then
		self:Remove()
		return
	end

	surface.SetDrawColor( 0, 0, 0, 225 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

end

vgui.Register( "DuelName", DUELNAME )
