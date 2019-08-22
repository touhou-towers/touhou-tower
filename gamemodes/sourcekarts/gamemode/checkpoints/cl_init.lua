
-----------------------------------------------------
module( "checkpoints", package.seeall )

local AVATAR = {}
AVATAR.AvatarSize = 32
AVATAR.Padding = 4

function AVATAR:Init()

	self:SetSize( self.AvatarSize + self.Padding, self.AvatarSize + self.Padding )
	self:SetZPos( 0 )
	self:SetMouseInputEnabled( false )

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( self.AvatarSize, self.AvatarSize )
	self.Avatar:SetZPos( -1 )

end

function AVATAR:SetPlayer( ply )
	self.Avatar:SetPlayer( ply, self.AvatarSize )
	self.Player = ply
end

function AVATAR:PerformLayout()

	local half = self.Padding / 2
	local offsetX, offsetY = half, half
	self.Avatar:SetPos( offsetX, offsetY )

end

local vecTranslate = Vector()
local angRotate = Angle()

function AVATAR:Paint( w, h )

	if !IsValid( self.Player ) || self.Player:Team() != TEAM_PLAYING then
		self:Remove()
		return
	end

	local kart = self.Player:GetKart()

	-- TODO: Check if this still works for clients outside of PVS
	if IsValid( kart ) then

		if kart:IsSpinning() then
			if !self.SpinAmount then
				local rnd = math.random( 0, 1 )
				if rnd == 0 then rnd = -1 end
				self.SpinAmount = 360 * 3 * rnd
			end
		else
			self.SpinAmount = nil
		end

		if kart:IsSpinning() and self.SpinAmount then
			local x, y = self:GetPos()

			vecTranslate.x = x + w/2
			vecTranslate.y = y + h/2

			self.SpinAmount = ApproachSupport2( self.SpinAmount, 0, 1.5 )
			angRotate.y = self.SpinAmount

			local mat = Matrix()
			mat:Translate( vecTranslate )
			mat:Rotate( angRotate )
			mat:Translate( -vecTranslate )
			cam.PushModelMatrix( mat )
			self._PushedMatrix = true
		end

	end

	//local color = HSVToColor( 75 * self.Player:GetLap(), 1, 1 )
	local color = Color( 50, 50, 50 )
	if IsValid( self.Player ) then
		color = self.Player:GetPlayerColor2()
	end
	color = Color( math.Clamp( color.r, 30, 180 ), math.Clamp( color.g, 30, 180 ), math.Clamp( color.b, 30, 180 ), 255 )

	if self.Player:GetPosition() == 1 then
		color = colorutil.Rainbow( 300 )
	end

	surface.SetDrawColor( color )
	surface.DrawRect( 0, 0, w, h )

	if self.Player == LocalPlayer() then
		self:SetZPos( 1 )
	end

end

function AVATAR:PaintOver()

	if self._PushedMatrix then
		cam.PopModelMatrix()
		self._PushedMatrix = nil
	end

end

vgui.Register( "PlayerAvatar", AVATAR )


local function CreatePlayerBox( ply )

	if ValidPanel( ply._Avatar ) then return end

	ply._Avatar = vgui.Create( "PlayerAvatar" )
	ply._Avatar:SetPlayer( ply )

end

local function RemovePlayerBox( ply )

	if !ValidPanel( ply._Avatar ) then return end

	ply._Avatar:Remove()

end

surface.CreateFont( "CheckpointFont", { font = "AlphaFridgeMagnets ", size = 32, weight = 500 } )
surface.CreateFont( "CheckpointFontSmall", { font = "AlphaFridgeMagnets ", size = 16, weight = 500 } )

hook.Add( "HUDPaint", "PlayerPositions", function()

	for _, ply in pairs( player.GetAll() ) do

		if GAMEMODE:GetState() == STATE_PLAYING && ply:Team() == TEAM_PLAYING && LocalPlayer():Team() == TEAM_PLAYING then

			CreatePlayerBox( ply )

			if ValidPanel( ply._Avatar ) then

				local progress = CalculateRealPosition( ply, ply:GetKart() )
				local x = math.Clamp( ScrW() * progress, 5, ScrW() - 10 - 64 )

				if !ply._CurX then ply._CurX = x end
				ply._CurX = ApproachSupport2( ply._CurX, x, 5 )

				//print( "PROGRESS: " .. progress )
				//draw.SimpleShadowText( ply:GetPosition(), "CheckpointFont", ply._CurX + 16, 64, Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 ), nil, nil, 1 )

				ply._Avatar:SetPos( ply._CurX, 5 )

			end

		else
			RemovePlayerBox( ply )
		end

	end

	if GAMEMODE:GetState() == STATE_PLAYING && LocalPlayer():Team() == TEAM_PLAYING then

		surface.SetDrawColor( 7, 34, 48, 150 )
		surface.DrawRect( 5, 5, ScrW() - 10, 6 )

		// Show lap ticks
		for i=1, GAMEMODE.MaxLaps do

			local tx = ScrW() * ( i / GAMEMODE.MaxLaps )
			surface.DrawRect( tx, 11, 6, 16 )

			/*local off = 0
			if i == 1 then off = 20 end
			draw.SimpleShadowText( "Lap " .. i, "CheckpointFontSmall", ScrW() * ( ( i - 1 ) / GAMEMODE.MaxLaps ) + off, 9, Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 ), nil, nil, 1 )*/

		end

		// Draw check
		local size = 4
		for i=1, 20 do
			local y = i
			local x = 0
			local m = 0
			if i > 10 then x = size y = i - 10 m = 1 end
			if ( i % 2 ) == m then
				surface.SetDrawColor( 255, 255, 255, 255 )
			else
				surface.SetDrawColor( 50, 50, 50, 255 )
			end
			surface.DrawRect( ScrW() - 10 - ( size - x ), 45 - ( size * y ), size, size )
		end

	end

end )
