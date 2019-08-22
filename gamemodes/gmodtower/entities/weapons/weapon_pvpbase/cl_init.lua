

-----------------------------------------------------
include("shared.lua")

SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.ViewModelFOV		= 64
SWEP.ViewModelFlip		= true
SWEP.CSMuzzleFlashes		= true

SWEP.IronHUD	= surface.GetTextureID( "gmod_tower/pvpbattle/sniper" )

//SWEP.ModelPanel = nil
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	/*if ValidPanel( self.ModelPanel ) then
		return
	end

	self.ModelPanel = vgui.Create( "DModelPanel2", self )
	self.ModelPanel:SetPos( x, y )
	self.ModelPanel:SetSize( wide, tall )
	self.ModelPanel:SetModel( self.WorldModel )

	self.ModelPanel:SetLookAt( Vector( 0, 0, 0 ) )
	self.ModelPanel:SetCamPos( Vector( 0, 0, 0 ) )*/

end

function SWEP:PrintWeaponInfo() end
function SWEP:BulletCallback() end

function SWEP:DrawHUD()

	if self.Owner.Iron && self.IronZoom /*&& !self.IronPost && CurTime() > self.HideViewModel*/ then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, math.random( 230, 255 ), 0, math.random(10, 15) ) )
		surface.SetTexture( self.IronHUD )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawLine( 0, ScrH() / 2, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW(), ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, 0, ScrW() / 2, ScrH() / 2 )
		surface.DrawLine( ScrW() / 2, ScrH() / 2, ScrW() / 2, ScrH() )

		return
	end

	if self.DrawCrosshair then
		self:DrawHUDCrosshair()
	end

	/*if ValidPanel( self.ModelPanel ) then
		self.ModelPanel:Remove()
	end*/

end

local curSpread = 5
local curAlpha = 180
function SWEP:DrawHUDCrosshair()

	local x = ScrW() / 2
	local y = ScrH() / 2
	local spread = 5
	local alpha = 180

	if self.Owner:KeyDown( IN_ATTACK ) then
		spread = 15
		alpha = 255
	end

	curSpread = math.Approach( curSpread, spread, FrameTime() * 60 )
	curAlpha = math.Approach( curAlpha, alpha, FrameTime() * 180 )

	local thickness = 4
	local width = 3
	local height = 3
	local halfWidth = width / 2
	local halfHeight = height / 2


	// Black
	surface.SetDrawColor( 0, 0, 0, curAlpha * .85 )

	surface.DrawRect( x - halfWidth, y - halfHeight, width, height )

	// Sides
	surface.DrawRect( x - curSpread - thickness - 1, y - halfHeight - 1.5, thickness + 2, height + 2 )
	surface.DrawRect( x + curSpread - 2, y - halfHeight - 1.5, thickness + 2, height + 2 )

	// Top
	surface.DrawRect( x - halfWidth - 1.5, y - curSpread - thickness - 1, width + 2, thickness + 2 )
	surface.DrawRect( x - halfWidth - 1.5, y + curSpread - 2, width + 2, thickness + 2 )


	// White
	surface.SetDrawColor( 255, 255, 255, curAlpha )

	// Sides
	surface.DrawRect( x - curSpread - thickness, y - halfHeight, thickness, height )
	surface.DrawRect( x + curSpread - 1, y - halfHeight, thickness, height )

	// Top
	surface.DrawRect( x - halfWidth, y - curSpread - thickness, width, thickness )
	surface.DrawRect( x - halfWidth, y + curSpread - 1, width, thickness )

end

function SWEP:GetViewModelPosition( pos, ang )
	if !self.IronSightsPos then return pos, ang end

	local bIron = self.Owner.Iron
	
	if ( bIron != self.bLastIron ) then
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
	end

	local fIronTime = self.fIronTime or 0
	if ( !bIron && fIronTime < CurTime() - self.IconSightTime ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	if ( fIronTime > CurTime() - self.IconSightTime ) then
		Mul = math.Clamp( (CurTime() - fIronTime) / self.IconSightTime, 0, 1 )
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