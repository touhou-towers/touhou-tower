
-----------------------------------------------------
local OFFSCREEN = {}
OFFSCREEN.AvatarSize = 32
OFFSCREEN.Padding = 4
OFFSCREEN.ArrowSize = 12
OFFSCREEN.HealthSize = 5
function OFFSCREEN:Init()
	self:SetSize( self.AvatarSize + self.Padding, self.AvatarSize + self.Padding + self.HealthSize )
	self:SetZPos( 1 )
	self:SetMouseInputEnabled( false )
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( self.AvatarSize, self.AvatarSize )
	self.Avatar:SetZPos( -1 )
end
function OFFSCREEN:SetPlayer( ply )
	self.Player = ply
	if ply:IsHidden() then
		self.Avatar:SetPlayer( nil )
	else
		self.Avatar:SetPlayer( ply, self.AvatarSize )
	end
end
function OFFSCREEN:Think()
	if !IsValid( self.Player ) then self:Remove() return end
	local size = self.AvatarSize
	if !self.Player:Alive() then
		size = SinBetween( self.AvatarSize, self.AvatarSize * 1.5, RealTime() * 10 )
	end
	self:SetSize( size + self.Padding, size + self.Padding )
	self.Avatar:SetSize( size, size )
end
function OFFSCREEN:PerformLayout()
	local half = self.Padding / 2
	local offsetX, offsetY = half, half
	self.Avatar:SetPos( offsetX, offsetY )
	// Arrow code... failed!
	/*self:SetSize( self.AvatarSize + self.Padding, self.AvatarSize + self.Padding )
	// Resize for direction player is
	local pos = self.Player:GetPos():ToScreen()
	local dirX, dirY = 0, 0
	if pos.x < 0 then dirX = -1 end
	if pos.x > ScrW() then dirX = 1 end
	if pos.y < 0 then dirY = -1 end
	if pos.y > ScrH() then dirY = 1 end
	if dirX != 0 then
		self:SetWide( self.AvatarSize + self.Padding + self.ArrowSize )
	end
	if dirY != 0 then
		self:SetTall( self.AvatarSize + self.Padding + self.ArrowSize )
	end
	// Center avatar
	local half = self.Padding / 2
	local offsetX, offsetY = half, half
	if dirX == -1 then offsetX = self:GetWide() - self.AvatarSize - half end
	if dirY == -1 then offsetY = self:GetTall() - self.AvatarSize - half end*/
end
function OFFSCREEN:Paint( w, h )
	if !IsValid( self.Player ) then
		self:Remove()
		return
	end
	// BG
	surface.SetDrawColor( 50, 50, 50, 255 )
	if !self.Player:Alive() then
		surface.SetDrawColor( Color( SinBetween( 50, 255, CurTime() * 20 ), 0, 0, 255 ) )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	// Health BG
	surface.SetDrawColor( 255, 50, 50, 150 )
	surface.DrawRect( 0, self.AvatarSize, self:GetWide(), self.HealthSize )
	// Health bar
	local healthwide = ( self.Player:Health() / 100 ) * self:GetWide()
	surface.SetDrawColor( 50, 255, 50, 150 )
	surface.DrawRect( 0, self.AvatarSize, healthwide, self.HealthSize )
end
vgui.Register( "ZMOffscreenPlayer", OFFSCREEN )
local function CreatePlayerBox( ply, pos )
	if ValidPanel( ply._RadarAvatar ) then return end
	ply._RadarAvatar = vgui.Create( "ZMOffscreenPlayer" )
	ply._RadarAvatar:SetPos( pos.x, pos.y )
	ply._RadarAvatar:SetPlayer( ply )
end
local function IsOffScreen( pos )
	if pos.x > ScrW() || pos.x < 0 then
		return true
	end
	if pos.y > ScrH() || pos.y < 0 then
		return true
	end
	
	return false
end
function GM:DrawRadar()
	for _, ply in pairs( player.GetAll() ) do
		if ply == LocalPlayer() then continue end
		local pos = ply:GetPos():ToScreen()
		// Get head bone
		/*local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )
		if head then
			bonepos, boneang = ply:GetBonePosition( head )
			if bonepos then
				pos = bonepos:ToScreen()
			end
		end*/
		if IsOffScreen( pos ) then
			CreatePlayerBox( ply, pos )
		end
		if ValidPanel( ply._RadarAvatar ) then
			ply._RadarAvatar:SetVisible( IsOffScreen( pos ) && GAMEMODE:IsPlaying() )
			// Clamp
			//local sizeX, sizeY = ply._RadarAvatar:GetWide(), ply._RadarAvatar:GetTall()
			local size = ply._RadarAvatar:GetSize()
			local x, y = math.ScreenRadialClamp( pos.x, pos.y )
			//pos.x = math.Clamp( pos.x, 0, ScrW() - size )
			//pos.y = math.Clamp( pos.y, 0, ScrH() - size )
			ply._RadarAvatar:SetPos( x, y )
			if !ply:Alive() then
				draw.SimpleText( "HELP!", "ZomNorm", x + 20, y - 15, Color( SinBetween( 50, 255, CurTime() * 20 ), 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
			end
		end
	end
end