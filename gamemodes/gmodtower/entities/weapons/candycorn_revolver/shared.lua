
if SERVER then AddCSLuaFile("shared.lua") end

if CLIENT then
	SWEP.PrintName = "Candy Corn Revolver"
	SWEP.Slot = 1
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	killicon.AddFont("ammo_candycorn", "HL2MPTypeDeath", ".", Color( 255, 255, 0, 255 ))
end

SWEP.Author = "Unrealomega"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "" 

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/W_357.mdl"

SWEP.HoldType = "pistol"

SWEP.PrimeClipSize = 6
SWEP.ReloadTime = 0

function SWEP:Initialize()

	self.Primary.CurrentAmount = self.PrimeClipSize
	
	self:SetWeaponHoldType( self.HoldType )
	
end 

function SWEP:PrimaryAttack()
	
	if !self:CanPrimaryAttack() or util.PointContents(self.Owner:GetPos()) == CONTENTS_WATER then return end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	
	self:ShootWeapon()
	
end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

end

function SWEP:ShootBullet()
	
	if SERVER then	
		
		local viewAng = self.Owner:EyeAngles()
		local bullet = ents.Create("ammo_candycorn")
		bullet:SetAngles(Angle(viewAng.p + 90, viewAng.y, viewAng.r))
		bullet:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
		bullet:SetPhysicsAttacker(self.Owner)
		bullet:SetOwner(self.Owner)
		bullet:Spawn()
		bullet:Activate()
		
		local phys = bullet:GetPhysicsObject()
		if phys then
			phys:ApplyForceCenter(self.Owner:GetAimVector() * 1000000)
			phys:AddAngleVelocity(Vector(0, 0, 500))
		end
		
	end
	
	self.Owner:ViewPunch(Angle( -15, 0, 0 ))
	
	self:ShootEffects()
	
end

function SWEP:Reload()

	if self:GetPrimeClip() == self.PrimeClipSize or self:CanReload() then return end
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	self:SetPrimeClip(self.PrimeClipSize)
	self.Weapon:SetNextReload(CurTime() + 3.75)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	
end

function SWEP:ShootWeapon()

	if self:GetPrimeClip() <= 0 then
		self:Reload()
	else
		self.Weapon:EmitSound("weapons/357/357_fire" .. math.random(2, 3) .. ".wav")
		self:ShootBullet()
		self:TakePrimaryAmmo(1)		
	end
	
end

function SWEP:TakePrimaryAmmo(amt)
	self:SetPrimeClip(self:GetPrimeClip() - amt)
end

function SWEP:GetPrimeClip()
	return self.Primary.CurrentAmount
end

function SWEP:SetPrimeClip(amt)
	self.Primary.CurrentAmount = amt
end

function SWEP:SetNextReload(time)
	self.ReloadTime = time
end

function SWEP:CanReload()
	return self.ReloadTime > CurTime()
end

function SWEP:CanPrimaryAttack()
	return !self:CanReload()
end

function SWEP:CanSecondaryAttack()
	return false
end