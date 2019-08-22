
-----------------------------------------------------
ENT.Type 				= "anim"
ENT.Base 				= "base_anim"

ENT.PrintName			= "Pool Tube"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.Model				= Model( "models/gmod_tower/pooltube.mdl")
ENT.Gravity 			= -350

local function GetPoolTube( ply )
	return ply.PoolTube
end

local novel = Vector(0,0,0)
hook.Add( "Move", "MoveTube", function( ply, movedata )

	local tube = GetPoolTube( ply )

	if IsValid( tube ) then

		movedata:SetForwardSpeed( 0 )
		movedata:SetSideSpeed( 0 )
		movedata:SetVelocity( novel )
		if SERVER then ply:SetGroundEntity( NULL ) end

		movedata:SetOrigin( tube:GetPos() )

		return true

	end

end )

hook.Add( "PlayerFootstep", "PlayerFootstepTube", function( ply, pos, foot, sound, volume, rf )
	return GetPoolTube( ply )
end )

local meta = FindMetaTable( "Player" )
if !meta then 
	return
end

function meta:GetTranslatedModel()

	local model = self:GetModel()

	if model == "models/player/urban.mbl" then
		return "models/player/urban.mdl"
	end

	model = string.Replace( model, "models/humans/", "models/" )
	model = string.Replace( model, "models/", "models/" )

	/*if !string.find( model, "models/player/" ) then
		model = string.Replace( model, "models/", "models/player/" )
	end*/
	
	return model

end

function meta:SetProperties( ent )

	if !IsValid( ent ) then return end

	ent.GetPlayerColor = function() return self:GetPlayerColor() end
	ent:SetMaterial( self:GetMaterial() )
	ent:SetSkin( self:GetSkin() )
	ent:SetBodygroup( 1, self:GetBodygroup(1) )
	
end

local meta = FindMetaTable("Entity")

function meta:SetPlayerProperties(ply)
	if !IsValid(ply) then return end
	
	if !self.GetPlayerColor then
		self.GetPlayerColor = function() return ply:GetPlayerColor() end
	end
	
	--self:SetBodygroup( ply:GetBodyGroup(1),1 )
	self:SetMaterial( ply:GetMaterial() )
	self:SetSkin( ply:GetSkin() or 1 )

end