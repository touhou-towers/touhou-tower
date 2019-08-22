
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base 				= "weapon_pvpbase"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Chainsaw"
SWEP.Slot				= 0
SWEP.SlotPos			= 4

SWEP.ViewModel			= Model( "models/weapons/v_pvp_chainsaw.mdl")
SWEP.WorldModel 		= Model( "models/weapons/w_pvp_chainsaw.mdl")
SWEP.ViewModelFlip		= true

SWEP.Primary.Delay		= 1.1
SWEP.Secondary.Delay	= 5
SWEP.HoldType			= "slam"

SWEP.Description = "Just Slice and dice.  Or if they're a bit far - throw the metal beast at them!"
SWEP.StoreBuyable = true
SWEP.StorePrice = 900

SWEP.Sounds = {
	[1] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_Attack.wav"),
	[2] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_Attacking.wav"),
	[3] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_Deploy.wav"),
	[4] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_Idle.wav"),
	[5] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_StartAttack.wav"),
	[6] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_Throw.wav"),
	[7] = Sound("GModTower/pvpbattle/Chainsaw/Chainsaw_ToIdle.wav"),
}

if CLIENT then
	SWEP.RandPosVec = VectorRand()
end
SWEP.ViewModelFlip  = false

function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType)

	self.NextWaitingSound = 0
	self.NextWaitingChangePos = 0
end

//function SWEP:Precache()

//end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
end

local function TestTrace( pos, ang, ply )

	local trace = util.TraceLine({
		start  = pos,
		endpos = pos + ang:Forward() * 128,
		filter = ply
	})

	if IsValid(trace.Entity) && trace.Entity:IsPlayer() then
		return trace.Entity
	end

end

local function TestTraces( ply )

	local pos = ply:GetShootPos()
	local ang = ply:GetAimVector():Angle()

	return TestTrace( pos, ang, ply ) ||
		TestTrace( pos, ang + Angle(15,0,0), ply ) ||
		TestTrace( pos, ang + Angle(0,15,0), ply ) ||
		TestTrace( pos, ang + Angle(0,-15,0), ply )

end


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Owner:ViewPunch( Angle( -30, 0, 0 ) )
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	/*local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
			mins=Vector(-8, -8, -8), maxs=Vector(8, 8, 8),
			filter=self.Owner})*/

	local target = TestTraces( self.Owner )
	local sound = self.Sounds[5]

	if target then
		sound = self.Sounds[1]

		if SERVER then
			target:TakeDamage( math.random(90, 120), self.Owner)
		end

		local effectdata = EffectData()
			effectdata:SetOrigin( self.Owner:EyePos() )
			effectdata:SetNormal( self.Owner:GetAngles():Forward() )
		util.Effect( "gib_bloodemitter", effectdata )
	end

	self.Weapon:EmitSound( sound )

end

function SWEP:Think()
	if CurTime() > self.NextWaitingSound then
		self.Weapon:EmitSound( self.Sounds[4] )
		self.NextWaitingSound = CurTime() + 1.5
	end

	if CLIENT then
		self.RandPosVec = VectorRand() * 0.2
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	self.Weapon:StopSound( self.Sounds[4] )
	return true
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	if !gamemode.Get( "pvpbattle" ) then return end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.Owner:ViewPunch( Angle( -30, 0, 0 ) )

	self.Owner:EmitSound( self.Sounds[5] )
	if CLIENT then return end

	self:ShootEnt( "pvp_chainsaw", 3500 )
	self.Owner:StripWeapon( "weapon_chainsaw" )
end

function SWEP:GetViewModelPosition( pos, ang )
	return pos + self.RandPosVec, ang
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
