include( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

ENT.TeleportDist	= 600	// pet teleports to you at this distance
ENT.StopDist		= 150	// at distances closer than this, the pet stops applying velocity
ENT.FreezeDist		= 50	// at this distance, the pet stops moving entirely
ENT.WinkDist		= 100	// oh my, what a cute melon!
ENT.RollingVelocity	= 350	// at this velocity or greater, the pet does a rolling emote

ENT.DullTime		= 35
ENT.BoredTime		= 15

local NEARBY_NOTHING	= 0 // nothing found nearby
local NEARBY_PET		= 1 // another pet nearby

function ENT:Initialize()

	self:SetModel( self.Model )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	self:PhysWake()

	self:DrawShadow( true )

	self.PlayerDistance = 0
	self.NextEmotionThink = CurTime()
	self.EmoteTime = CurTime()
	self.LastActionTime = CurTime()

	self:SharedInit()

	self.EmoteTime = CurTime() + 2
	self:EmitRandomSound( "Spawning", 5 )

end

function ENT:UpdatePetName()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		self:SetPetName( string.sub(ply:GetInfo("gmt_petname_cube"),1,15) )
	end
end


function ENT:OnRemove()

	self:EmitRandomSound( "Deleted", 5 )

	local owner = self:GetOwner()

	if IsValid( owner ) then
		owner.Pet = nil
	end


end


function ENT:Teleport( ply )

	local pos = ply:GetPos()

	pos.x = pos.x + ( math.Rand( -1.0, 1.0 ) * 40 )
	pos.y = pos.y + ( math.Rand( -1.0, 1.0 ) * 40 )
	pos.z = pos.z + 20

	self:SetPos( pos )

	self:PhysWake()

	self:EmitRandomSound( "Teleporting", 30 )
end

function ENT:EmitRandomSound( emotion, chance )

	if ( chance && math.random( 1, chance ) != 1 ) then return end

	local soundIndex = Pets.GetRandomSoundIndex( "melon", emotion )

	if ( soundIndex == -1 ) then return end

	local sound = Pets.GetSound( "melon", emotion, soundIndex )

	--self:EmitSound( sound, 100, 100 )
end

function ENT:Use( ply )

	if ( ply == self:GetOwner() ) then
		self:SetEmotion( "OwnerPoke", 0.5 )
		self:ResetIdle()
	else
		self:SetEmotion( "OtherPoke", 0.5 )
		self:ResetIdle()
	end

	self:ConfirmEmotion()

end

function ENT:Touch( ent )

	if !IsValid( ent ) then return end

	if ( ent:GetClass() == "gmt_pet" ) then
		self:SetEmotion( "Kiss", 0.5 )
		self:ResetIdle()
		self:ConfirmEmotion( 5 )
	end
end

function ENT:EmotionThink()

	if self.NextEmotionThink >= CurTime() then return end

	local owner = self:GetOwner()

	if IsValid(owner) then self:UpdatePetName() end

	if self.Emotion != Pets.GetIDFromEmotion( "Rolling" ) then
		if ( IsValid( owner ) && owner:IsRabbit() ) then
			self:SetEmotion( "Rabbit" )
		else
			self:SetEmotion( "Happy" )
		end
	end

	local physObj = self:GetPhysicsObject()

	if IsValid( physObj ) then
		local velocity = physObj:GetVelocity():Length()

		if ( velocity > 50 ) then
			self:ResetIdle()
		end

		if ( velocity > self.RollingVelocity ) then
			self:SetEmotion( "Rolling" )
			self:ConfirmEmotion()
			self.NextEmotionThink = CurTime() + 0.5

			return
		end

	end

	local actionDiff = self:IdleTime()

	if ( actionDiff > 1 && actionDiff < 3 && self.Emotion == Pets.GetIDFromEmotion( "Rolling" ) ) then
		self:SetEmotion( "Dizzy", 2 )
	elseif ( actionDiff > self.DullTime ) then
		self:SetEmotion( "Dull" )
	elseif ( actionDiff > self.BoredTime ) then
		self:SetEmotion( "Bored" )
	end

	local nearby = self:GetNearby()

	if ( nearby == NEARBY_PET ) then
		self:SetEmotion( "Wink" )
	end

	self:ConfirmEmotion()

	self.NextEmotionThink = CurTime() + 0.5

end

function ENT:ResetIdle()
	self.LastActionTime = CurTime()
end

function ENT:IdleTime()
	return ( CurTime() - self.LastActionTime )
end

function ENT:Think()

	local owner = self:GetOwner()
	if !IsValid( owner ) then
		if IsValid(self) then self:Remove() end
		return
	end

	local selfPos = self:GetPos()
	local plyPos = owner:GetPos()

	self.PlayerDistance = selfPos:Distance( plyPos )

	if ( self.PlayerDistance > self.TeleportDist ) then
		self:Teleport( owner )
	end

	self:EmotionThink()

	self:PhysWake()

end

// checks if another pet is near this pet
function ENT:GetNearby()

	local selfPos = self:GetPos()
	local foundMelon = false

	local entTable = {}

	local results = {}

	table.Add( entTable, ents.FindByClass( "gmt_pet" ) )

	for _, v in ipairs( entTable ) do
		if IsValid( v ) && v != self then

			local entDistance = selfPos:Distance( v:GetPos() )

			if ( entDistance <= self.WinkDist ) then
				results[ v ] = entDistance
			end

		end
	end

	local closestDist = 0
	local closestType = ""

	for k, v in pairs( results ) do
		if ( v >= closestDist ) then
			closestDist = v
			closestType = k:GetClass()
		end
	end

	if ( closestType == "gmt_pet" ) then
		return NEARBY_PET
	end

	return NEARBY_NOTHING

end

function ENT:SetEmotion( emote, time )

	if ( self.EmoteTime && self.EmoteTime > CurTime() ) then return end // another emotion is already playing!

	self.TempEmotion = emote

	self.EmoteTime = CurTime() + ( time or 0 )

end

function ENT:ConfirmEmotion( soundChance )

	local tempId = Pets.GetIDFromEmotion( self.TempEmotion )

	// short circuit
	if ( self.Emotion == tempId ) then return end

	self.Emotion = tempId

	local randIndex = Pets.GetRandomQuoteIndex( "melon", self.Emotion )

	if math.random( 1, 2 ) == 1 && randIndex != -1 then
		umsg.Start( "PetMSG" )
			umsg.Entity( self )
			umsg.Char( self.Emotion )
			umsg.Char( randIndex )
		umsg.End()
	end

	self:EmitRandomSound( self.Emotion, soundChance or 10 )

end

function ENT:PhysicsUpdate( phys )

	local velocity = phys:GetVelocity()

	if ( self.PlayerDistance <= self.FreezeDist ) then
		phys:SetVelocity( Vector( 0, 0, velocity.z ) )
		return
	end

	if ( self.PlayerDistance <= self.StopDist ) then return end

	local angle = self:GetOwner():GetPos() - self:GetPos()

	local vect = angle:GetNormalized() * ( self.PlayerDistance / 4 )
	vect.z = math.Clamp( vect.z, 0, 100 ) // don't move too far up

	phys:ApplyForceCenter( vect )

end

concommand.Add( "gmt_petemote", function( ply, cmd, args )

	if !IsValid( ply.Pet ) then return end

	if #args == 0 then return end

	local emote = tonumber( args[ 1 ] )
	local time = tonumber( args[ 2 ] )

	if !emote then return end

	ply.Pet:SetEmotion( emote, time )
	ply.Pet:ConfirmEmotion()

end )
