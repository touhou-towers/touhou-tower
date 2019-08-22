
-----------------------------------------------------
SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "Plasma Auto-rifle"
SWEP.Slot					= 2

//Types
SWEP.HoldType				= "ar2"
SWEP.GunType				= "rifle"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel			 	= Model("models/weapons/v_vir_par.mdl")
SWEP.WorldModel			 	= Model("models/weapons/w_vir_par.mdl")

//Primary
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 0.1
SWEP.Primary.Recoil	 		= 1.5
SWEP.Primary.Cone			= 0.015
SWEP.Primary.Damage			= 12
SWEP.Primary.Automatic		= true
SWEP.Primary.UnlimitedAmmo  = true

//Sounds
SWEP.Primary.Sound			= Sound("GModTower/virus/weapons/PlasmaRifle/shoot.wav")
SWEP.SoundDeploy	 		= Sound("GModTower/virus/weapons/PlasmaRifle/deploy.wav")
SWEP.ExtraSounds = {
	Alert					= Sound("GModTower/virus/weapons/PlasmaRifle/alert.wav"),
	CoolDown				= Sound("GModTower/virus/weapons/PlasmaRifle/cool_down.wav")
}

//Effects
SWEP.Trace					= "plasma"

//Iron
SWEP.IronZoom				= true
SWEP.IronPost				= true
SWEP.IronZoomFOV	 		= 50

SWEP.OverHeatTime			= 5
SWEP.CoolDownTime 			= 3
SWEP.ExponentDelay 			= 0.75

SWEP.MinDelay 				= 0.075
SWEP.MaxDelay 				= 0.13

SWEP.MinCone 				= 0.015
SWEP.MaxCone 				= 0.075
SWEP.OverHeat = 0

SWEP.KeyLastTime 			= 0


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.OverHeat = 0

end

function SWEP:Think()

	if !IsValid( self.Owner )then return end

	if self.Owner:KeyDown( IN_ATTACK ) then

		self:OverHeatAdd()

	end

	if !self.Owner:KeyDown( IN_ATTACK ) && self.OverHeat > 0.0 && self.KeyLastTime < CurTime() then

		if self.OverHeat > 0.5 && !self.CoolSound then

			self.CoolSound = true
			if CLIENT then
				surface.PlaySound( self.ExtraSounds.CoolDown )
			end

			if self.AlertSound then
				self.AlertSound = false
			end

		end

		self.OverHeat = math.max( self.OverHeat - FrameTime() / self.CoolDownTime, 0.0 )

	else

		self.CoolSound = false

	end

	self:UpdateColor()

end

function SWEP:OverHeatAdd( amt )

	if self.OverHeat > 0.25 && !self.AlertSound then

		self.AlertSound = true
		if CLIENT then
			surface.PlaySound( self.ExtraSounds.Alert )
		end

	end

	if self.OverHeat == 1.0 then return end

	self.OverHeat = math.min( self.OverHeat + FrameTime() / self.OverHeatTime, 1.0 )

	if amt then
		self.OverHeat = self.OverHeat + amt
	end

end

function SWEP:UpdateColor()

	local ViewModel = self.Owner:GetViewModel()
	if IsValid( ViewModel ) then

		if self.OverHeat > 0.0 then

			ViewModel:SetColor( Color( 255, math.floor( self.OverHeat * -255 ), math.floor( self.OverHeat * -255 ), 255 ) )

		else

			ViewModel:SetColor( Color( 255, 255, 255, 255 ) )

		end
	end

end

function SWEP:UpdateScale()

	local Perc = math.pow( self.OverHeat, self.ExponentDelay )

	self.Primary.Delay = Lerp( Perc, self.MinDelay, self.MaxDelay )
	self.Primary.Cone = Lerp( Perc, self.MinCone, self.MaxCone )

end

function SWEP:PrimaryAttack()

	self.KeyLastTime = CurTime() + 1
	self:UpdateScale()
	self.BaseClass.PrimaryAttack( self )

end

function SWEP:CanSecondaryAttack() return false end

function SWEP:PostDrawViewModel( vm, wep, ply )

	local pos = self:GetMuzzlePos( vm ) + ( vm:GetRight() * -5 ) + ( vm:GetUp() * 2 )
	if !pos then return end
	local ang = LocalPlayer():EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local perc = self.OverHeat
	if perc == 0 then return end

	cam.Start3D2D( pos, Angle( ang.p, ang.y, ang.r ), 0.05 )

		local w, h = 100, 10
		local padding = 1
		local x = ( w / 2 + ( padding / 2 ) ) * - 1
		local y = ( h / 2 + ( padding / 2 ) ) * - 1

		local color = colorutil.TweenColor( Color( 50, 50, 255, 150 ), Color( 255, 100, 255, 150 ), perc )
		draw.RectFillBorder( x, y, w, h, padding, perc, Color( 100, 100, 255, 150 ), color )

	cam.End3D2D()

end
