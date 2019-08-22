
-----------------------------------------------------
include( "shared.lua" )

SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.ViewModelFOV			= 64
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes		= false

SWEP.IronHUD				= surface.GetTextureID( "gmod_tower/virus/zoom" )

function SWEP:BulletCallback() end

function SWEP:DrawHUD()

	if ( !self.IronHUD ) then return end

	if self.Owner.Iron && self.IronZoom && !self.IronPost && ( self.HideViewModel && CurTime() > self.HideViewModel ) then

		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, 0, math.random( 230, 255 ), math.random(10, 15) ) )
		surface.SetTexture( self.IronHUD )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawLine( 0, ScrH() / 2, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW(), ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, 0, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW() / 2, ScrH() )

	end

end

local IRONSIGHT_TIME = .25
function SWEP:GetViewModelPosition( pos, ang )

	if !self.IronSightsPos then return pos, ang end

	local bIron = self.Owner.Iron
	
	if ( bIron != self.bLastIron ) then
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
	end

	local fIronTime = self.fIronTime or 0
	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		if (!bIron) then Mul = 1 - Mul end
	end

	local Offset = self.IronSightsPos
	if ( self.IronSightsAng ) then
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang

end