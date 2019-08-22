
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Phaser"

SWEP.WorldModel				= Model( "models/weapons/w_rif_sg552.mdl" )
SWEP.HoldType				= "ar2"

SWEP.Primary.ClipSize		= 80
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.085
SWEP.Primary.Cone			= 0.0005

SWEP.Primary.Damage			= 40
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/laser_fire.wav" )
SWEP.Primary.Trace			= "phaser"

SWEP.Offsets				= nil

SWEP.Tier 					= DropManager.UNCOMMON

function SWEP:Deploy()

	if SERVER && !self.IsMelee && !IsValid( self.Owner.LaserRifleEntity ) then
		local ent = ents.Create("zm_laser_laserrifle")
		ent:SetParent( self.Weapon )
		ent:SetOwner( self.Weapon )
		ent:Spawn()
		
		self.Owner.LaserRifleEntity = ent
	end

	return true

end

function SWEP:Holster()

	if IsValid( self.Owner.LaserRifleEntity ) then
		self.Owner.LaserRifleEntity:Remove()
	end

	return true

end