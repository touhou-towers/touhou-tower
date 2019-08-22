

----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "RYNO V"

SWEP.WorldModel				= Model( "models/Weapons/w_rocket_launcher.mdl" )
SWEP.ViewModel				= Model( "models/weapons/c_rpg.mdl" )
SWEP.HoldType				= "physgun"
SWEP.UseHands				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.05
SWEP.Primary.Recoil	 		= 1
SWEP.Primary.Cone			= .08
SWEP.Primary.Sound			= "weapons/m4a1/m4a1-1.wav"

SWEP.OvertureP				= nil
SWEP.Overture				= "GModTower/music/overture.mp3"

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Overture)
end

function SWEP:Think()
	if !self.OvertureP then return end

	if self.OvertureP < CurTime() then
		self.OvertureP = nil
	end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.Primary.Recoil then
		self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, 0, 0 ) )
	end
	self.Weapon:SendWeaponAnim( anim or ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	--self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
--
	--self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Ammo)
	--self:ShootEffects(self.Primary.Sound, self.Primary.Recoil, ACT_VM_PRIMARYATTACK)

	if !self.OvertureP then
		self.OvertureP = CurTime() + 17
		self:EmitSound(self.Overture)
	end

	if CLIENT then return end
	if math.random(1,5) == 3 then
		local ent = ents.Create( "rynov_rpg" )
		ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 50 ))
		ent:SetAngles( self.Owner:EyeAngles() )
		ent:SetOwner(self.Owner)
		ent:Spawn()
	end
end

function SWEP:Reload()
	return false
end

function SWEP:Holster()
	self.OvertureP = nil
	self:StopSound(self.Overture)
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:ShootBullet( dmg, numbul, cone, ammo )
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( cone, cone, 0 )
	bullet.Tracer	= 1
	bullet.Force	= 1

	if type(dmg) == "table" then
		bullet.Damage	= math.random(dmg[1],dmg[2])
	else
		bullet.Damage	= dmg
	end

	if ammo != "none" then
		bullet.AmmoType	= ammo
	end

	self.Owner:FireBullets( bullet )
end
