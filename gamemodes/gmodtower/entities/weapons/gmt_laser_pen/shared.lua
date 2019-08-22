
if SERVER then AddCSLuaFile("shared.lua") end

if CLIENT then
	SWEP.PrintName = "Laser Pen"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "Unrealomega"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "pistol"

SWEP.DecalList = {"Antlion.Splat",
				"BeerSplash",
				"BirdPoop",
				"Blood",
				"BulletProof",
				"Cross",
				"Dark",
				"ExplosiveGunshot",
				"Eye",
				"FadingScorch",
				"GlassBreak",
				"Impact.Antlion",
				"Impact.BloodyFlesh",
				"Impact.Concrete",
				"Impact.Glass",
				"Impact.Metal",
				"Impact.Sand",
				"Impact.Wood",
				"Light",
				"ManhackCut",
				"Nought",
				"Noughtsncrosses",
				"PaintSplatBlue",
				"PaintSplatGreen",
				"PaintSplatPink",
				"Scorch",
				"Smile",
				"Splash.Large",
				"YellowBlood"}
			
SWEP.CurrentDecal = 1
SWEP.ReloadTime = 0

function SWEP:PrimaryAttack() --Paints to the surface
	
	self:SetWeaponHoldType( self.HoldType )
	
	if !self:ShootLaser() then return end
	
	if self.Owner:IsAdmin() then 
		self.Weapon:SetNextPrimaryFire(CurTime() + .2)
	else
		self.Weapon:SetNextPrimaryFire(CurTime() + .3) 
	end
	
end

function SWEP:Reload() --Changes the decal

	self:ChangeDecal(1)
	
end

function SWEP:SecondaryAttack()

	self:ChangeDecal(-1)
	
end

function SWEP:ChangeDecal(change)

	if self.ReloadTime > CurTime() then return end
	self.ReloadTime = CurTime() + .2
	
	local dir = self.CurrentDecal + change
	
	if dir > 1 and dir < #self.DecalList + 1 then 
		self.CurrentDecal = dir
	else
		if change < 0 then
			self.CurrentDecal = #self.DecalList
		else
			self.CurrentDecal = 1
		end
	end

	self.Owner:PrintMessage(HUD_PRINTCENTER, "Decal: " .. self.DecalList[self.CurrentDecal])

end

function SWEP:ShootLaser()

	local trace = self.Owner:GetEyeTrace()
	if self.Owner:GetPos():Distance(trace.HitPos) < 70 then return end
	
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone)

	util.Decal(self.DecalList[self.CurrentDecal], trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
	
	return true
	
end

function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone )

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local effectdata = EffectData()
	effectdata:SetOrigin(hitpos)
	effectdata:SetStart(self.Owner:GetShootPos())
	effectdata:SetAttachment(1)
	effectdata:SetEntity(self.Weapon)
	util.Effect("ToolTracer", effectdata)
	
end