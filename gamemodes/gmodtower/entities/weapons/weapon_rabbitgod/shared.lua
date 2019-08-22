
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Rabbit GOD!"
SWEP.Slot			= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_rocket_launcher.mdl"
SWEP.WorldModel 		= "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType			= "normal"
SWEP.ViewModelFlip		= false

SWEP.Primary.Delay		= 0.3

SWEP.Secondary.Delay	= 1.5

function SWEP:Initialize()
	//self.NextLightThink = 0
	
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	local Att = self.Weapon:LookupAttachment("muzzle")
	
	/* local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetAttachment(0)
		effectdata:SetOrigin( self.Owner:GetEyeTrace().HitPos )
		effectdata:SetScale(100)
	util.Effect("TeslaZap", effectdata)   */
	
	local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetOrigin( self.Owner:GetEyeTrace().HitPos )
		effectdata:SetScale( 6 )
		effectdata:SetRadius( 5 )
		effectdata:SetMagnitude( 0.2 )
		
	util.Effect("tesla_shoot", effectdata)
	
	
	
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	
end
/*
local function GetRandAttach()
	if math.random(0,1) == 0 then
		return "anim_attachment_RH"
	end
	return "anim_attachment_LH"
end

function SWEP:Think()
	if CurTime() > (self.NextLightThink or 0) then
		local Att = self.Owner:LookupAttachment( GetRandAttach() )
		local Pos = self.Owner:EyePos()
		
		if Att != 0 then
			Pos = self.Owner:GetAttachment(Att).Pos
		end
		
		local Trace = util.QuickTrace( Pos, VectorRand() * 128, {self.Owner,self.Weapon} )
	
		/* local effectdata = EffectData()
			effectdata:SetEntity(self.Owner)
			effectdata:SetAttachment(Att)
			effectdata:SetOrigin( Trace.HitPos )
			effectdata:SetScale(10)
		util.Effect("TeslaZap", effectdata) */
		/*
		
		local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(Pos)
			effectdata:SetScale(10)
			effectdata:SetMagnitude(20)
			effectdata:SetEntity(self)
		util.Effect("TeslaHitBoxes", effectdata)
		
		//print("Effect!", Att, Trace.Fraction )
		
		self.NextLightThink = CurTime() + 0.1
	end
end
*/
function SWEP:Reload()

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end