
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "gmt_npc_ballracer" )
	ent:SetPos( tr.HitPos + Vector(0,0,1) )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
	self:SetSubMaterial(3,self.Material)
end

function ENT:AcceptInput( name, activator, ply )
	
	if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then	
		--timer.Simple( 0.0, BallRacer.OpenStore, BallRacer, ply )
		
		timer.Simple( 0.0, function()
			BallRacer:OpenStore( ply )
		end )
	end

end