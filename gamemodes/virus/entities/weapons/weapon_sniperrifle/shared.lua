SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.DrawCrosshair	= false
end

//Basic Setup
SWEP.PrintName				= "Scope Enhanced Sniper Rifle"
SWEP.Slot					= 4

//Types
SWEP.HoldType				= "ar2"
SWEP.GunType				= "highcal"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel				= "models/weapons/v_vir_snp.mdl"
SWEP.WorldModel				= "models/weapons/w_pvp_as50.mdl"

//Primary
SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Ammo			= "SniperRound"
SWEP.Primary.Delay			= 0.75
SWEP.Primary.Recoil	 		= 6
SWEP.Primary.Cone			= 2
SWEP.Primary.Damage			= { 70, 80 }

//Secondary
SWEP.Secondary.Delay	 	= .25

//Effects
SWEP.Effect					= nil  //sniper_trail on zoom only

//Sounds
SWEP.Primary.Sound			= "GModTower/virus/weapons/Sniper/shoot.wav"

//Iron
SWEP.IronZoom		 		= true
SWEP.IronZoomFOV	 		= 15
SWEP.IronSightsPos 			= Vector (3.6707, -6.297, 1.6166)
SWEP.IronSightsAng 			= Vector (-0.7847, 4.1086, 0.8058)


function SWEP:Think()

	if self.Owner.Iron then

		self.Effect	= "sniper_trail"
		self.Primary.Cone = 0

	else

		self.Effect	= "sniper_trail"
		self.Primary.Cone = 0

	end

end

function SWEP:PrimaryAttack()

	//if self.Owner.Iron then
		self.BaseClass.PrimaryAttack( self )
	//end

	/*if self.Owner.Iron then
		self:ShootZoom()
	end*/

end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	self:ShootZoom()
	
	if !SERVER then return end
	
	if self.Owner.Iron then
		self.Owner:DrawViewModel( false )
	else
		self.Owner:DrawViewModel( true )
	end

end

function SWEP:AdjustMouseSensitivity()

	if !self.Owner.Iron then return 1 end

	return .1
	
end