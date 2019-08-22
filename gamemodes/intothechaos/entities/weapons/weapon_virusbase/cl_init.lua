include( "shared.lua" )

SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.ViewModelFOV			= 64
SWEP.ViewModelFlip			= true
SWEP.CSMuzzleFlashes		= false

SWEP.IronHUD				= surface.GetTextureID( "gmod_tower/virus/zoom" )

function SWEP:BulletCallback() end

/*function SWEP:DrawHUD()

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

end*/

function SWEP:PostDrawViewModel( vm, weapon, ply )

	local viewModel = vm
	if not IsValid( viewModel ) then return end
	local attachmentIndex = viewModel:LookupAttachment("muzzle")
	local at = viewModel:GetAttachment( attachmentIndex )

	local pos = Vector(0,0,0)
	local angle = Angle(0,0,0)

	if at then
		pos = at.Pos + at.Ang:Right() * -5 --+ at.Ang:Forward() * -20 + at.Ang:Up() * -5 + at.Ang:Right() * -4
		pos = at.Pos + at.Ang:Forward() * -6
		angle = at.Ang
		angle:RotateAroundAxis(angle:Forward(), 90)
		angle.r = ply:EyeAngles().r + 90
		--angle:RotateAroundAxis(angle:Right(), 90)
	end

	--render.DepthRange( 0, 0.1 )
	--DrawStencilScreen( pos, angle )

	cam.Start3D2D( pos, angle, 0.035 )
		surface.SetFont("HalloweenFontSmaller")
		surface.SetDrawColor( Color( 46, 47, 99, 125 ) )

		local MaxAmmo = LocalPlayer():GetAmmoCount( "XBowBolt" )
		local CurAmmo = self.Weapon:Clip1()

		local textpos = surface.GetTextSize( "|00/00|" )

		surface.DrawRect(0,0,textpos,30)

		surface.SetTextColor(255,255,255,255)
		surface.SetFont("HalloweenFontSmaller")
		surface.SetTextPos(5,0)
		surface.DrawText( CurAmmo .. "/" .. MaxAmmo )

	cam.End3D2D()
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
