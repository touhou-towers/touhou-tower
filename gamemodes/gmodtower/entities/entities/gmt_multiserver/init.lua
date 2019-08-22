
include('shared.lua')
include('network.lua')
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_list.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile("cl_map.lua")
AddCSLuaFile("cl_mainobj.lua")
AddCSLuaFile("cl_playerlist.lua")
AddCSLuaFile("shared.lua")

local UsedServerIds = {}
local function GetNewServerId()
	if #GTowerServers.Servers >= #UsedServerIds then
		UsedServerIds = {}
	end

	for k, v in pairs( GTowerServers.Servers ) do
		if !table.HasValue( UsedServerIds, k ) then
			table.insert( UsedServerIds, k )
			return k
		end
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	SpawnPos.z = SpawnPos.z + 64

	local ent = ents.Create( "gmt_multiserver" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self.Entity:SetModel( self.Model )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

	self.ImageZoom = 0.6
	self:ReloadOBBBounds()

	self.LastPlyRequest = {}
	//self:SharedInit()
	self:DrawShadow( false )

	self:SetId( self.GamemodeId or 4 )

end

function ENT:Id()
	return self.ServerId
end

function ENT:SetId( id )
	self.ServerId = id
	self:SetSkin( id )
end

function ENT:Use( ply )

	local PlyId = ply:EntIndex()

	if ply:KeyDownLast(IN_USE) == false && ( self.LastPlyRequest[ PlyId ] or 0.0 ) < CurTime() then

		local Server = GTowerServers:Get( self:Id() )

		if Server then
			GTowerServers:AskToJoinServer( ply, Server )
		end

		self.LastPlyRequest[ PlyId ] = CurTime() + 0.5

	end

end

function ENT:KeyValue( key, value )

	if key == "gamemode" then
		self.GamemodeId = tonumber( value )
	end

end

function ENT:Think()
	self:NextThink(CurTime() + 3)

	self:BuildInformation()
	self:BuildPlayerInfo()

	return true
end

function ENT:OnRemove()

end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
