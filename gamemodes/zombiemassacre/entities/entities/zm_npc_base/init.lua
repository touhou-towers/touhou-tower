AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = "models/Zombie/Classic.mdl"

ENT.HP = 100
ENT.Damage = 50
ENT.Points = 1

ENT.SAlert = nil
ENT.SAttack = nil
ENT.SDie = nil
ENT.SIdle = nil
ENT.SMiss = nil
ENT.SPain = nil

ENT.IdleTalk = 0
ENT.AttackDelay = 0.5
ENT.AttackRadius = 64

ENT.RagdollDeath = true
ENT.ShouldDrop = true

function ENT:Initialize()

	self:Precache()
	self:SetModel( self.Model )

	self:SetHullSizeNormal()
	self:SetHullType( HULL_HUMAN )
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( CAP_MOVE_GROUND )
	self:CapabilitiesAdd( CAP_INNATE_MELEE_ATTACK1 )

	self:SetCustomCollisionCheck( true )

	self:SetMaxYawSpeed( 5000 )
	self:ClearSchedule()
	self:UpdateEnemy( self:FindEnemy() )

	self:SetHealth( self.HP )

end

function ENT:Precache() return end


//Serves as a way to select a random sound from in a small table.
//We're not using table counting in anyway.
//Instead, we have one entry for the string beginning.
//And the last table entry is the amount of songs available.
//This way I don't have to copy paste an entire list of songs that are completely the same other than the number on the end.
function ENT:EmitSoundTable( sound, vol )

	if !sound || type( sound ) != "table" then return end

	sound = sound[1] .. math.random( 1, sound[2] ) .. ".wav"
	--vol = vol or 35
	vol = 75

	local pitch = math.random( 90, 100 )

	self.Entity:EmitSound( sound, vol, pitch )

end


//This is a hack to spawn client side ragdolls in a mature way.
//We simply spawn a env_shooter then setup the correct variables to throw the ragdoll as if it were a gib.
function ENT:SpawnRagdoll( att )

	local ang = self:GetAngles()

	local shooter = ents.Create("env_shooter")
		shooter:SetPos( self:GetPos() )
		shooter:SetKeyValue( "m_iGibs", "1" )
		shooter:SetKeyValue( "shootsounds", "3" )
		shooter:SetKeyValue( "gibangles", ang.p.." "..ang.y.." "..ang.r )
		shooter:SetKeyValue( "angles", ang.p.." "..ang.y.." "..ang.r )
		shooter:SetKeyValue( "shootmodel", self:GetModel() )
		shooter:SetKeyValue( "simulation", "2" )
		shooter:SetKeyValue( "gibanglevelocity", math.random( -50, 50 ).." "..math.random( -150, 150 ).." "..math.random( -150, 150 ) )

		if IsValid( att ) then
			shooter:SetKeyValue( "m_flVelocity", tostring( math.Rand( -40, 0 ) ) )
			shooter:SetKeyValue( "m_flVariance", tostring( math.Rand( -2, 0 ) ) )
		end

	shooter:Spawn()
	shooter:Fire( "shoot", 0, 0 )
	shooter:Fire( "kill", 0.1, 0.1 )

end

//The death function focuses itself by clearing the NPC and awarding the player with a few extras.
//We also want to spawn a ragdoll, so we call the function above.
function ENT:Death( ply )
	ply:AddFrags( self.Points )
	ply:AddPoints( self.Points * 2 )
	ply:AddCombo()

	if self.RagdollDeath then self:SpawnRagdoll( ply ) end
	self:OnDeath( ply )

	// lets randomly drop a goodie
	DropManager.RandomDrop( self:GetPos() )

	self:EmitSoundTable( self.SDie )
	self:Remove()

end

//Incase we want to do something fancy.
function ENT:OnDeath( ply ) return end

//The attack function that handles all the events that occur when the NPC attacks the player.
function ENT:Attack( enemy, hit )

	if !enemy then return end
	local hit = hit or false

	sched = SCHED_MELEE_ATTACK1

	if hit then
		enemy:TakeDamage( self.Damage, self )
		self:EmitSoundTable( self.SAttack )
	else
		self:EmitSoundTable( self.SMiss )
	end

end

//This take damage checks the damage recived and compares it with the current health.
//If the health is too low, we kill off the NPC.
//If its not the NPC just recives damage normally with a few added on effects.
function ENT:OnTakeDamage( dmg )

	if !IsValid( self ) then return end

	local att = dmg:GetAttacker()
	local health = self:Health()
	local finalhp = health - dmg:GetDamage()

	if !att:IsPlayer() then
		dmg:SetDamage( 0 )
		return
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() + Vector( 0, 0, 30 ) )
	effectdata:SetNormal( self:GetForward() )
	effectdata:SetScale( 2 )
	util.Effect( "bloodcloud", effectdata, true, true )

	if finalhp <= 0 then
		self:Death( att )
		return
	end

	self:SetHealth( finalhp )
	self:EmitSoundTable( self.SPain )

end

//We're going to run through the table of players and check their distance between them and the NPC.
//After that we return the perfect player.
function ENT:FindEnemy()

	local tbl = player.GetAll()

	if #tbl < 1 then
		return NULL
	else
		local enemy = NULL
		local dist = 8000

		for k,ply in ipairs( tbl ) do
			local compare = ply:GetPos():Distance( self:GetPos() )
			if compare < dist && ( ply:IsPlayer() && ply:Alive() ) then
				enemy = ply
				dist = compare
			end
		end
		return enemy
	end

end


//This function makes sure the NPC is grabbing the right enemy.
//If the enemy no longer exists or is alive, we'll update the NPC.
function ENT:UpdateEnemy( enemy )

	if IsValid( enemy ) && ( enemy:IsPlayer() && enemy:Alive() ) then
		self:SetEnemy( enemy, true )
		self:UpdateEnemyMemory( enemy, enemy:GetPos() )
	else
		self:SetEnemy( NULL )
	end

end

function ENT:Think()

	//Small little tidbit to make the NPCs goan and such.
	if self.IdleTalk < CurTime() then
		self:EmitSoundTable( self.SIdle )
		self.IdleTalk = CurTime() + math.random( 15, 25 )
	end

	//Reset the attack time.
	if !self.AttackTime then
		self.AttackTime = CurTime() + self.AttackDelay
	end

end

function ENT:GetRelationship( entity )

	if IsValid( entity ) && entity:IsPlayer() then return D_HT end

	return D_LI

end

//This is ran every frame as the NPC figures out what to do next.
//We make sure they wander at all times.
//After that we simply look for an enemy.
//If the enemy is there, we use the built in check for attacking.
function ENT:SelectSchedule()

	local enemy = self:GetEnemy()
	local sched = SCHED_IDLE_WANDER

	if IsValid( enemy ) then
		if self:HasCondition( 23 ) then //COND_CAN_MELEE_ATTACK1

			if self.AttackTime && self.AttackTime < CurTime() then
				self.AttackTime = nil
				local enemy = self:GetEnemy()

				if IsValid( enemy ) && enemy:GetPos():Distance( self:GetPos() ) < self.AttackRadius then
					self:Attack( enemy, true )
				else
					self:Attack( enemy, false )
				end
			end

		else
			sched = SCHED_CHASE_ENEMY
		end
	else
		self:UpdateEnemy( self:FindEnemy() )
	end

	self:SetSchedule( sched )

end
