
-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
	PendingReset = false
	CanCancel = false
	Cancelled = false
end

local self2

SWEP.Base				= "weapon_rage"
SWEP.BankAdminOnly		= true

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true

SWEP.PrintName 			= "Get Over HERE!"

SWEP.ViewModel			= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel			= "models/weapons/w_pvp_ire.mdl"

SWEP.Primary.Delay		= .25
SWEP.Primary.Force		= 25

SWEP.HoldType			= "fist"
SWEP.Dist				= 68

SWEP.Sounds				=
{
	["GetOver"] 		= Sound( "GModTower/lobby/scorpion/getoverhere.wav" ),
	["FinishHim"] 		= Sound( "GModTower/lobby/scorpion/finish_him.wav" ),
	["FatalityTheme"] 	= Sound( "GModTower/lobby/scorpion/fatality_theme.wav" ),
	["Fatality"] 		= Sound( "GModTower/lobby/scorpion/fatality.wav" ),
	["VictimNo"] 		= Sound( "GModTower/lobby/scorpion/victim_no.wav" ),
	["VictimScream"] 	= Sound( "GModTower/lobby/scorpion/victim_scream.wav" ),
	["VictimDie"] 		= Sound( "GModTower/lobby/scorpion/victim_die.wav" ),
}

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.Victim = nil
	self.Spear = nil
	self.State = 1 // 1 for idle, 2 for throwing, 3 for pulling, 4 wait, 5 fatality

end

function SWEP:Holster()

	self:End()

	return true

end

function SWEP:RemoveSpear()

	if IsValid( self.Spear ) then
		self.Spear:Remove()
	end

end

function SWEP:End()
	self.State = 1
	self:RemoveSpear()
	self:ResetSpeeds()
	self.Owner:Freeze( false )

	if IsValid( self.Victim ) then

		if !self.Fatality then
			//self.Victim:EmitSound( "GModTower/misc/sad.mp3", 100, 100 )
		end

		self.Victim:Freeze( false )
		--umsg.Start( "FatalityHead" )
			--umsg.Entity( self.Victim )
			--umsg.Bool( false )
		--umsg.End()

		self.Victim = nil

	end

end

function SWEP:ResetSpeeds()

	self.Owner:SetWalkSpeed( 250 )
	self.Owner:SetRunSpeed( 500 )
	self.Owner:SetJumpPower( 200 )

end

function SWEP:SetState( state )

	if CLIENT then return end

	--self.Owner:ChatPrint( state )
	self.State = state

	// Idle
	if state == 1 then
		self.Victim = nil
		self.CanFatality = false
		self.Owner:Freeze( false )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end

	// Throw
	if state == 2 then
		self.Owner:Freeze( true )
		self.Fatality = false
	end

	// Pull
	if state == 3 then

		self.PullTime = CurTime() + 2

		self.Victim:Freeze( true )
		self.Owner:EmitSound( self.Sounds.GetOver )

	end

	// Wait
	if state == 4 then

		self.WaitTime = CurTime() + 4
		self.CanFatality = false

		self:RemoveSpear()

		self.Owner:Freeze( false )
		self.Owner:SetWalkSpeed( 1 )
		self.Owner:SetRunSpeed( 1 )
		self.Owner:SetJumpPower( .1 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self.VictimNo = CreateSound( self.Victim, self.Sounds.VictimNo )
		self.FatalityTheme = CreateSound( self.Owner, self.Sounds.FatalityTheme )

		timer.Simple( .15, function()

			if IsValid( self.Victim ) && self.Victim:Alive() then

				self.Owner:EmitSound( self.Sounds.FinishHim )

				timer.Simple( .5, function()

					if self.FatalityTheme then self.FatalityTheme:Play() end

				end )

				timer.Simple( 1, function()

					if self.VictimNo then self.VictimNo:Play() end
					self.CanFatality = true

				end )

			end

		end )

	end

	// Fatality
	if state == 5 then

		self.CanFatality = false
		self.Fatality = true

		self.Owner:Freeze( true )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self.VictimScream = CreateSound( self.Victim, self.Sounds.VictimScream )
		self.VictimScream:Play()

		if self.FatalityTheme then self.FatalityTheme:Stop() end
		self.FatalityTheme = nil

		if self.VictimNo then self.VictimNo:Stop() end
		self.VictimNo = nil

		timer.Simple( .9, function()

			if IsValid( self.Victim ) && self.Victim:Alive() then

				umsg.Start( "FatalityHead" )
					umsg.Entity( self.Victim )
					umsg.Bool( true )
				umsg.End()

				if self.VictimScream then self.VictimScream:Stop() end
				self.Victim:EmitSound( "physics/flesh/flesh_squishy_impact_hard4.wav", 100, 50 )

				local effectdata = EffectData()
					effectdata:SetOrigin( self.Victim:GetPos() + Vector( 0, 0, 60 ) )
					effectdata:SetScale( 10 )
				util.Effect( "bloodcloud", effectdata, true, true )

				local effectdata2 = EffectData()
					effectdata2:SetOrigin( self.Victim:GetPos() + Vector( 0, 0, 30 ) )
				util.Effect( "gib_bloodemitter", effectdata2 )
				util.Effect( "gib_bloodemitter", effectdata2 )
				util.Effect( "gib_bloodemitter", effectdata2 )
				util.Effect( "gib_bloodemitter", effectdata2 )
				util.Effect( "gib_bloodemitter", effectdata2 )

				self.Victim:Ignite( 1 )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )

			end

		end )

		timer.Simple( 1.8, function()

			if IsValid( self.Victim ) && self.Victim:Alive() then

				self.Victim:SetVelocity( Vector( 0, 0, 500 ) )

				timer.Simple( .01, function()
					if IsValid( self.Victim ) then
						self.Victim:Kill()
					end
				end )

			end

		end )

		timer.Simple( 2.8, function()

			if IsValid( self.Victim ) then
				self.Owner:EmitSound( self.Sounds.Fatality )
			end

		end )

		timer.Simple( 3, function()

			if IsValid( self.Victim ) then
				self.Victim:EmitSound( self.Sounds.VictimDie )
				self.Victim:Freeze( false )
			end

		end )

		timer.Simple( 3, function() self:End() end )

	end

end

net.Receive("ResetSpear", function()
	if SERVER then return end
		net.Start("ResetSpearServer")
		net.SendToServer()
end)

net.Receive("ResetSpearServer",function()
	PendingReset = true
end)

net.Receive("FatalityClient",function()
net.Start("FatalityServer")
net.WriteEntity(net.ReadEntity())
net.SendToServer()
end)

net.Receive("FatalityServer",function()

	CanCancel = true

	Victim = net.ReadEntity()

	self2.Owner:Freeze( false )
	self2.Owner:SetWalkSpeed( 1 )
	self2.Owner:SetRunSpeed( 1 )
	self2.Owner:SetJumpPower( .1 )
	self2.Owner:SetAnimation( PLAYER_ATTACK1 )
	self2:RemoveSpear()

	timer.Simple( .15, function()

		if IsValid( Victim ) && Victim:Alive() then

			self2.Owner:EmitSound( self2.Sounds.FinishHim )

			timer.Simple( .5, function()

				Victim:EmitSound( self2.Sounds.VictimNo )

			end )

			timer.Simple( 1, function()
				if !Cancelled then
				Victim:EmitSound( "physics/flesh/flesh_squishy_impact_hard4.wav", 100, 50 )

				local effectdata = EffectData()
					effectdata:SetOrigin( Victim:GetPos() + Vector( 0, 0, 60 ) )
					effectdata:SetScale( 10 )
				util.Effect( "BloodImpact", effectdata, true, true )

				local effectdata2 = EffectData()
					effectdata2:SetOrigin( Victim:GetPos() + Vector( 0, 0, 30 ) )
				util.Effect( "BloodImpact", effectdata2 )
				util.Effect( "BloodImpact", effectdata2 )
				util.Effect( "BloodImpact", effectdata2 )

				Victim:Ignite( 1 )
				self2.Owner:SetAnimation( PLAYER_ATTACK1 )

				timer.Simple(.5,function()
					Victim:EmitSound( self2.Sounds.VictimScream )
				end)

				timer.Simple(1.5,function()
					Victim:EmitSound( self2.Sounds.VictimDie )
					Victim:Freeze(false)
					Victim:Kill()
					self2.Owner:EmitSound(self2.Sounds.FatalityTheme)
					self2.Owner:Freeze(false)
					self2.Owner:SetWalkSpeed( 250 )
					self2.Owner:SetRunSpeed( 500 )
					self2.Owner:SetJumpPower( 200 )

					self2:End()
				end)

				timer.Simple(3,function()
					self2.Owner:EmitSound(self2.Sounds.Fatality)
				end)
				end
			end )
		end
	end )
end)

function SWEP:Think()

	self2 = self
	--print(self.State)

	if PendingReset then
		self:End()
		PendingReset = false
	end

	if CLIENT then return end

	// Pull
	if self.State == 3 then

		if !IsValid( self.Victim ) || !self.Victim:Alive() || self.PullTime < CurTime() then
			self:End()
			return
		end

		local dist = self.Owner:GetPos():Distance( self.Victim:GetPos() )
		if dist <= self.Dist then
			self:SetState( 4 )
			return
		end

		local angle = self.Owner:GetPos() - self.Victim:GetPos()
		local vect = angle:GetNormal() * 250
		vect.z = 0

		self.Victim:SetVelocity( vect )

	end

	if self.State == 4 then

		if !IsValid( self.Victim ) || !self.Victim:Alive() || self.WaitTime < CurTime() then
			self:End()
			return
		end

		local dist = self.Owner:GetPos():Distance( self.Victim:GetPos() )
		if dist > self.Dist then
			self:End()
			return
		end

		if self.CanFatality && self.Owner:KeyDown( IN_RELOAD ) then
			self:SetState( 5 )
		end

	end

end

function SWEP:PrimaryAttack()

	if CLIENT then return end

	if SERVER and CanCancel then
		self:End()
		Victim:Freeze(false)
		CanCancel = false
		Cancelled = true
		timer.Simple(1,function()
			Cancelled = false
		end)
	end

	if !self:CanPrimaryAttack() || self.State != 1 || !self.Owner:IsOnGround() || !self.Owner:IsAdmin() then return end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Owner:ViewPunch( Angle( -20, 0, 0 ) )
	self:ShootEffects()

	if !IsFirstTimePredicted() then return end

	if SERVER then

		if !Cancelled then
		local viewAng = self.Owner:EyeAngles()
		local spear = ents.Create( "ammo_scorpion_spear" )
			spear:SetAngles( Angle( viewAng.p, viewAng.y, viewAng.r ) )
			spear:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
			spear:SetPhysicsAttacker( self.Owner )
			spear:SetOwner( self.Owner )
		spear:Spawn()
		spear:Activate()

		local phys = spear:GetPhysicsObject()
		if IsValid( phys ) then
			phys:ApplyForceCenter( self.Owner:GetAimVector() * 100000 )
		end

		self.Spear = spear
		self:SetState( 2 )
		end
	end

end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return true end


if SERVER then return end

usermessage.Hook( "FatalityHead", function( um )

	local ply = um:ReadEntity()
	local bool = um:ReadBool()
	if !IsValid( ply ) then return end

	local boneIndex = ply:LookupBone( "ValveBiped.Bip01_Head1" )
	if boneIndex then
		if bool then
			ply:ManipulateBoneScale( boneIndex, Vector( 0, 0, 0 ) )
		else
			ply:ManipulateBoneScale( boneIndex, Vector( 1, 1, 1 ) )
		end
	end

end )
