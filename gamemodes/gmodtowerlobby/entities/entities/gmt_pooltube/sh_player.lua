-- Creates a ClientSideModel that is designed to replicate actions of player

AddCSLuaFile()

local PLAYER = {}
PLAYER.__index = PLAYER

----
-- Returns the player client model
----
function PLAYER:Get()
	return self.Model
end

----
-- Returns if the player client model is valid
----
function PLAYER:IsValid()
	return IsValid( self.Model )
end

----
-- Called when setting up the player client model
----
function PLAYER:Init()

	if !IsValid( self.Player ) then return end

	-- Remove previous model, if it exists

	if IsValid( self.Model ) then self:Remove() end

	self.Model = ClientsideModel( self.Player:GetTranslatedModel(), RENDER_GROUP_OPAQUE_ENTITY )
	--self.Model:SetNoDraw( true ) -- We're rendering this elsewhere
	self.Model:SetPlayerProperties( self.Player )

	-- Reference to player object
	self.Player._ClientPlayerModel = self

	-- Hat support
	hook.Add( "OverrideHatEntity", "OverrideHat"..tostring(self.Model:EntIndex()), function( ply )
		if self.Player._ClientPlayerModel then
			return self.Player._ClientPlayerModel
		end
	end )

	-- Hook into think
	hook.Add( "Think", "Think"..tostring(self.Model:EntIndex()), function()
		self:_Think()
	end )

end

----
-- Removes the player client model
----
function PLAYER:Remove()

	if IsValid( self.Model ) then
		hook.Remove( "Think", "Think"..tostring(self.Model:EntIndex()) )
		hook.Remove( "OverrideHatEntity", "OverrideHat"..tostring(self.Model:EntIndex()) )
		hook.Remove( "ForceThirdperson", "ForceThirdperson"..tostring(self.Model:EntIndex()) )

		self.Model:Remove()
		self.Model = nil
	end

	if IsValid( self.Player ) then
		-- Dereference to player object
		self.Player._ClientPlayerModel = nil

		--self.Player:ResetEquipmentScale()
		self.Player = nil
	end

end

----
-- Sets the default sequence on the player client model. Useful for seats.
----
function PLAYER:SetSequence( seq )

	if not IsValid( self.Player ) then return end
	if not IsValid( self.Model ) then return end

	-- Set the default sequence
	self.Sequence = self.Model:LookupSequence( seq )

	self.Model:ClearPoseParameters()
	self.Model:ResetSequenceInfo()

	self.Model:ResetSequence( self.Sequence )
	self.Model:SetCycle( 0.0 )

end

----
-- Forced third person on the client. Useful for seats like the pool tube.
----
function PLAYER:ForceThirdPerson( enabled )

	if not IsValid( self.Player ) then return end
	if not IsValid( self.Model ) then return end

	if enabled then

		hook.Add( "ForceThirdperson", "ForceThirdperson"..tostring(self.Model:EntIndex()), function( ply )
			return IsValid( ply:GetClientPlayerModel() )
		end )

	else
		hook.Remove( "ForceThirdperson", "ForceThirdperson"..tostring(self.Model:EntIndex()) )
	end

end

----
-- Sets the player model entity ownership. Useful to automatically adjust offsets while drawing.
----
function PLAYER:SetOwner( owner )
	self.Owner = owner
end

----
-- Internal think function that handles removing, updating, and sequences.
----
function PLAYER:_Think()

	-- Remove if the player is gone
	if not IsValid( self.Player ) or not self.Player:Alive() then
		self:Remove()
		return
	end

	-- Reinit if needed
	if not IsValid( self.Model ) or not self.Model:GetModel() then
		self:Init( self.Player )
	end

	-- Update sequence
	if self.Sequence then

		if self.Model:GetSequence() != self.Sequence then
			self.Model:SetPlaybackRate( 1.0 )
			self.Model:ResetSequence( self.Sequence )
			self.Model:SetCycle( 0 )
		end

	end

end

----
-- Draws the player client model.
----
function PLAYER:Draw( pos, angles )

	if not IsValid( self.Player ) then return end
	if not IsValid( self.Model ) then return end

	--if not self:ShouldDraw() then return end

	-- Handle entity ownership offsets
	if IsValid( self.Owner ) then
		pos = util.TranslateOffset( pos, self.Owner )
		angles = ent:GetAngles() + angles
	end

	-- Set pos and angles
	self.Model:SetPos( pos )
	self.Model:SetAngles( angles )

	-- Player properties
	self.Model:SetPlayerProperties( self.Player )
	self.Model:SetupBones()

	-- Scale it properly
	local scale = GTowerModels.GetScale( self.Model:GetModel() )
	self.Model:SetModelScale( scale, 0 )

	-- Draw it
	--self.Model:DrawModel()

	-- Draw player equipment
	self.Player:ManualEquipmentDraw()
	self.Player:ManualBubbleDraw()

end

----
-- Returns if the player model can be drawn.
----
function PLAYER:ShouldDraw()

	if self.Player == LocalPlayer() then
		return LocalPlayer():ShouldDrawLocalPlayer() && not LocalPlayer():GetObserverTarget()
	end

	return true

end

----
-- Updates animation based on player movement. Useful to fully replicate player actions. Hook into UpdateAnimation for this.
-- This will remove any sequence set with SetSequence.
----
function PLAYER:UpdateAnimation( groundSpeed )

	if not IsValid( self.Player ) then return end
	if not IsValid( self.Model ) then return end

	self.Sequence = nil

	-- Player movement replication
	local ply = self.Player
	local ent = self.Model
	local vel = ply:GetVelocity():Length2D()

	-- Handle playback rate
	local playRate = 1
	if vel > 0.5 then
		if groundSpeed < 0.001 then
			playRate = 0.01
		else
			playRate = vel / groundSpeed
			playRate = math.Clamp( playRate, 0.01, 10 )
		end
	end
	ent:SetPlaybackRate( math.Clamp(playRate, 0.1, 2) )

	-- Fixup frame advance
	if !ent.LastTick then ent.LastTick = CurTime() end
	ent:FrameAdvance( CurTime() - ent.LastTick )
	ent.LastTick = CurTime()

	-- Update current sequence
	local seq = ply:GetSequence()
	if ent.LastSeq != seq then
		ent.LastSeq = seq
		ent:ResetSequence( seq ) -- If the player changes sequences, change the legs too
	end

	-- Breathing!
	local breathScale = .5
	if !ent.NextBreath then ent.NextBreath = CurTime() end
	if ent.NextBreath <= CurTime() then -- Only update every cycle, should stop MOST of the jittering
		ent.NextBreath = CurTime() + 1.95 / breathScale
		ent:SetPoseParameter( "breathing", breathScale )
	end

	-- Head movement
	if !ent.BodyAngle then ent.BodyAngle = 0 end

	local aim = ply:EyeAngles()
	if seq != ent:LookupSequence( "idle_all_01" ) then
		ent.BodyAngle = aim.y
	else
		local diff = math.NormalizeAngle( aim.y - ent.BodyAngle )
		local abs = math.abs( diff )
		if abs > 45 then
			local norm = math.Clamp( diff, -1, 1 )
			ent.BodyAngle = math.NormalizeAngle( ent.BodyAngle + ( diff - 45 * norm ) )
		end
	end

	local HeadYaw = math.NormalizeAngle( aim.y - ent.BodyAngle )
	ent:SetAngles( Angle( 0, ent.BodyAngle, 0 ) )

	ent:SetPoseParameter( "head_pitch", math.Clamp( aim.p - 40, -19, 20 ) )
	ent:SetPoseParameter( "body_pitch", -aim.p )
	ent:SetPoseParameter( "head_yaw", HeadYaw )

	-- Movement pose parameters
	ent:SetPoseParameter( "move_x", ( ply:GetPoseParameter( "move_x" ) * 2 ) - 1 ) -- Translate the walk x direction
	ent:SetPoseParameter( "move_y", ( ply:GetPoseParameter( "move_y" ) * 2 ) - 1 ) -- Translate the walk y direction
	ent:SetPoseParameter( "move_yaw", ( ply:GetPoseParameter( "move_yaw" ) * 360 ) - 180 ) -- Translate the walk direction
	ent:SetPoseParameter( "body_yaw", ( ply:GetPoseParameter( "body_yaw" ) * 180 ) - 90 ) -- Translate the body yaw
	ent:SetPoseParameter( "spine_yaw",( ply:GetPoseParameter( "spine_yaw" ) * 180 ) - 90 ) -- Translate the spine yaw

end

----
-- Draws the player name.
----
if CLIENT then
surface.CreateFont( "ClPlayerName", { font = "Coolvetica", size = 26, weight = 400 } )

function PLAYER:DrawPlayerName( pos, offset )

	if not IsValid( self.Player ) then return end
	if not IsValid( self.Model ) then return end
	if LocalPlayer() == self.Player then return end

	local ang = LocalPlayer():EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	pos = pos + ( offset or Vector( 0, 0, 80 ) ) + ang:Up() * ( math.sin( CurTime() ) * 2 )

	local dist = LocalPlayer():GetPos():Distance( self.Player:GetPos() )
	if ( dist >= 800 ) then return end

	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 150 )
	local name = self.Player:GetName()

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .5 )

		draw.DrawText( name, "ClPlayerName", 2, 2, Color( 0, 0, 0, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( name, "ClPlayerName", 0, 0, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()

end
end
----
-- Create a new instance of a clientside player
----
function ClientsidePlayer( ply )

	if not IsValid( ply ) then return end

	local tbl = {}
	tbl = setmetatable( tbl, PLAYER )

	tbl.Player = ply
	tbl:Init()

	return tbl

end


local PlayerMeta = FindMetaTable("Player")

----
-- Returns client player model, if the player has one
----
function PlayerMeta:GetClientPlayerModel()
	return self._ClientPlayerModel
end


----
-- Example usage:
----

-- Setup
--------------------------------------------------------------------------
-- self.PlayerModel = ClientsidePlayer( ply )
-- self.PlayerModel:SetSequence( "sit_rollercoaster" ) -- Sets single sequence forever.

-- or

-- hook.Add( "UpdateAnimation", "FakeUpdateAnimation", function( ply, vel, groundSpeed )
--		if IsValid( ply:GetClientPlayerModel() ) then
--			ply:GetClientPlayerModel():UpdateAnimation( groundSpeed )
--		end
-- end )


-- Drawing done elsewhere, possibly PreDrawTranslucentRenderables or ENTITY:Draw()
--------------------------------------------------------------------------
-- self.PlayerModel:Draw( pos, ang )
-- self.PlayerModel:DrawPlayerName( pos )

-- or

-- ply:GetClientPlayerModel():Draw( pos, ang )


-- Parameters
--------------------------------------------------------------------------
-- self.PlayerModel:ForceThirdPerson( true )


-- Remove when the entity is removed
--------------------------------------------------------------------------
-- self.PlayerModel:Remove()
