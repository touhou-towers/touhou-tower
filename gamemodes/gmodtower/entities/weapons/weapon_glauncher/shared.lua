
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Grenade Launcher"
SWEP.Slot		 = 5
SWEP.SlotPos		 = 3

SWEP.ViewModel		 = "models/weapons/v_pvp_grenade.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_grenade.mdl"
SWEP.HoldType		 = "shotgun"

SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 1.6
SWEP.Primary.ClipSize	 = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Ammo	 = "RPG_Round"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/GrenadeLauncher/GrenadeLauncherFire.wav"
SWEP.Primary.Recoil	 = 3

SWEP.Secondary.Delay = 2

SWEP.SoundDeploy	 = "GModTower/pvpbattle/GrenadeLauncher/GrenadeLauncherDeploy.wav"
SWEP.SoundEmpty		 = "GModTower/pvpbattle/GrenadeLauncher/GrenadeLauncherEmpty.wav"

SWEP.SoundFill		 = "GModTower/pvpbattle/GrenadeLauncher/GrenadeLauncherInsert.wav"
SWEP.SoundPump		 = "GModTower/pvpbattle/GrenadeLauncher/GrenadeLauncherPump.wav"

SWEP.Description = "This powerful dual-purpose grenade launcher is any man's worry. Primary fire ejects super bouncy grenades. Secondary fire ejects small sticky grenades. If you see someone with this weapon, run away as fast as you can."
SWEP.StoreBuyable = true
SWEP.StorePrice = 3000

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.SoundDeploy )
	GtowerPrecacheSound( self.SoundEmpty )
	GtowerPrecacheSound( self.Primary.Sound )

	GtowerPrecacheSound( self.SoundFill )
	GtowerPrecacheSound( self.SoundPump )
end

function SWEP:CanPrimaryAttack()
	if self.reloading then
		if self.Weapon:GetVar( "interrupt", 0 ) == 0 then
			self.Weapon:SetVar( "interrupt", 1 )
		end

		return false
	end

	return self.BaseClass.CanPrimaryAttack(self.Weapon)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if SERVER then self:ShootEnt( "pvp_glauncher_nade", 1800 ) end
	self:ShootEffects(self.Primary.Sound, self.Primary.Recoil, self.Primary.Effect, ACT_VM_PRIMARYATTACK)

	self:TakePrimaryAmmo( 1 )
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )

	if SERVER then self:ShootEnt( "pvp_glauncher_stickynade", 1800 ) end
	self:ShootEffects(self.Primary.Sound, self.Primary.Recoil, self.Primary.Effect, ACT_VM_PRIMARYATTACK)

	self:TakePrimaryAmmo( 1 )
end

function SWEP:SpecialReload()
	if self.Owner.Reloading then return true end

	self.Owner.Reloading = true

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.5 )
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )

	self.Weapon:SetVar( "interrupt", 0 )
	
	self.Owner:SetAnimation( PLAYER_RELOAD )

	return true
end

function SWEP:Think()
	if !self.Owner.Reloading then return end
	if CurTime() < self.Weapon:GetVar( "reloadtimer", 0) then return end

	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 2 then
		self.Owner.Reloading = false
		self.Weapon:SetNextPrimaryFire( CurTime() + .5 )
		return
	end

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.5 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )

	self.Owner:SetAnimation( PLAYER_RELOAD )
			
	self.Weapon:EmitSound( self.SoundFill )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 1 then
		self.Weapon:SetVar( "interrupt", 2 )

		self:EmitSound( self.SoundPump )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	end
end