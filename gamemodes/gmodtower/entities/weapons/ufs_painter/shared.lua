

SWEP.Base = "ufs_weaponbase"

SWEP.PrintName = "Painter"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.ShootDelay = 0.1

if CLIENT then

function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo( x, y, alpha ) end

end

if (SERVER) then

AddCSLuaFile("shared.lua")

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
end

function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire(CurTime() + self.ShootDelay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.ShootDelay)

	local ball = ents.Create("ufs_paintball")
	ball:SetOwner(self.Owner)
	ball:SetPos(self.Owner:GetShootPos() + 20*self.Owner:GetAimVector() - Vector(0,0,5))
	ball:SetAngles(self.Owner:EyeAngles())
	ball:Spawn()
	ball:Activate()
	ball:SetPaintColor(0)

	ball:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAimVector()+Vector(0,0,0.2))*7000)

	self.Owner:EmitSound("GModTower/mono/paintpop.wav", 75, math.random(70,130))
end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire(CurTime() + self.ShootDelay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.ShootDelay)

	local ball = ents.Create("ufs_paintball")
	ball:SetOwner(self.Owner)
	ball:SetPos(self.Owner:GetShootPos())
	ball:SetAngles(self.Owner:EyeAngles())
	ball:Spawn()
	ball:Activate()
	ball:SetNWInt("color",1)

	ball:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAimVector()+Vector(0,0,0.2))*7000)
	self.Owner:EmitSound("GModTower/mono/paintpop.wav", 75, math.random(70,130))
end

function SWEP:Reload()
end

end
