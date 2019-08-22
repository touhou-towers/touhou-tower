
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "gmt_npc_digi" )
	ent:SetPos( tr.HitPos + Vector(0,0,1) )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
end

function ENT:AcceptInput( name, activator, ply )

    if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then
		GTowerStore:OpenStore( ply, 12 )
		--timer.Simple( 0.0, GTowerStore.OpenStore( GTowerStore, ply, 12 ))
		
    end
	
end