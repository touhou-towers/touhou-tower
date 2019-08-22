
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType		= "normal"

SWEP.PrintName		= "Extinguisher"
SWEP.Slot			= 3
SWEP.SlotPos		= 1

SWEP.Base			= "weapon_base"

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModel		= ""
SWEP.WorldModel		= ""

SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.Automatic= false
SWEP.Secondary.Ammo	= "none"

SWEP.FrozenVictim = nil
SWEP.LoopSound = Sound("ambient/gas/steam_loop1.wav")
SWEP.FreezeSound = Sound("physics/glass/glass_impact_bullet4.wav")
SWEP.UnFreezeSound = {Sound("physics/glass/glass_sheet_break1.wav"),
					  Sound("physics/glass/glass_sheet_break2.wav"),
					  Sound("physics/glass/glass_sheet_break3.wav")}


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

	RegisterNWTable( self, { {"ExtingN", false, NWTYPE_BOOL, REPL_EVERYONE} } )
end

function SWEP:Deploy()
	self.ExtingN = false

	self:SendWeaponAnim( ACT_VM_DEPLOY )

	self.Owner:DrawViewModel(false)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() )

	if SERVER then
		self.ExtingN = true
	end
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

if SERVER then

function SWEP:Think()
	if !self.Owner:KeyDown( IN_ATTACK ) then
		self.ExtingN = false
		return
	end

	local shootpos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local trace = util.TraceLine({start=shootpos, endpos=shootpos + (dir * 250), filter=self.Owner})

	if IsValid( trace.Entity ) then
		if trace.Entity:IsOnFire() then trace.Entity:Extinguish() end

		if self.Owner:GetSetting( "GTAllowWeapons" ) && 
			trace.Entity:IsPlayer() && 
			!trace.Entity:IsFrozen() &&
			trace.Entity.FreezeEffect != true then
			
			local effectdata = EffectData()
				effectdata:SetOrigin( trace.Entity:GetPos() )
			util.Effect( "iced", effectdata )

			trace.Entity:EmitSound( self.FreezeSound )
			trace.Entity:Freeze( true )
			trace.Entity:SetColor( 155,215,250,255 )
			trace.Entity:SetMaterial( "models/shiny" )

			trace.Entity.FreezeEffect = true
			
			local id = trace.Entity:UserID()
			local unfreeze = self.UnFreezeSound
			
			timer.Create( "Unfreeze" .. id, 5, 1, function()
				if IsValid(trace.Entity) then
					local effectdata = EffectData()
						effectdata:SetOrigin( trace.Entity:GetPos() )
					util.Effect( "iced", effectdata )

					trace.Entity.FreezeEffect = false
					
					trace.Entity:EmitSound( table.Random(unfreeze) )
					trace.Entity:Freeze( false )
					trace.Entity:SetColor( 255,255,255,255 )
					trace.Entity:SetMaterial( "" )

				end
				if timer.Exists( "Unfreeze" .. id ) then timer.Destroy( "Unfreeze" .. id ) end
			end )
		end
	end
end

else

function SWEP:OnRemove()
	if self.Emitter then
		self.Emitter:Finish()
		self.Emitter = nil
	end

	if self.ExtingSound then
		self.ExtingSound:FadeOut(0.1)
	end
end

function SWEP:Think()
	local flame = self.ExtingN

	if flame == false && !self.Emitter then return end

	if (self.Owner == LocalPlayer() && !self.Owner:KeyDown(IN_ATTACK)) || (self.Emitter && !flame) then
		if self.Emitter then
			self.Emitter:Finish()
			self.Emitter = nil
			self.ExtingSound:FadeOut(0.5)
		end
		return 
	end

	local dir = self.Owner:GetAimVector()
	local shootpos = self.Owner:EyePos()

	if !self.ExtingSound then
		self.ExtingSound = CreateSound(self.Owner, self.LoopSound)
	end

	if !self.Emitter then
		self.Emitter = ParticleEmitter(shootpos)
		self.Exting = CurTime()
		self.ExtingSound:PlayEx(1, 200)
	end

	if CurTime() < self.Exting + 0.01 then return end
	
	for i=1, 5 do
		local particle = self.Emitter:Add("particles/smokey", shootpos)
		if particle then
			particle:SetPos(shootpos + (dir * i * 5))
			particle:SetVelocity(dir * (200 + math.random() * 200))
			particle:SetLifeTime(0)
			particle:SetDieTime(0.6)
			particle:SetColor( 190,190,255 )
			particle:SetStartSize(2)
			particle:SetEndSize(16)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
		end
	end

	self.Exting = CurTime()
end

function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
	self:Think()
end

end