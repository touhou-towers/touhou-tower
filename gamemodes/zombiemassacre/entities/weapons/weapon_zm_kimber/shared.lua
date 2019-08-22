
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Kimber"

SWEP.WorldModel				= Model( "models/weapons/w_pist_fiveseven.mdl" )
SWEP.HoldType				= "revolver"

SWEP.Primary.ClipSize		= 40
SWEP.Primary.Delay			= 0.25
SWEP.Primary.Cone			= 0.03

SWEP.Primary.Damage			= 50
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/kimber_fire.wav" )
SWEP.Primary.Automatic 		= true

SWEP.Offsets				= nil

function SWEP:Deploy()

	if SERVER && !self.IsMelee && !IsValid( self.Owner.LaserEntity ) then
		local ent = ents.Create("zm_laser_kimber")
		ent:SetParent( self.Weapon )
		ent:SetOwner( self.Weapon )
		ent:Spawn()
		
		self.Owner.LaserEntity = ent
	end

	return true

end

function SWEP:Holster()

	if IsValid( self.Owner.LaserEntity ) then
		self.Owner.LaserEntity:Remove()
	end

	return true

end