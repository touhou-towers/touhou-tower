
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "gmt_npc_fireworks" )
	ent:SetPos( tr.HitPos + Vector(0,0,1) )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
	self:SetSubMaterial(3,self.Material)
end

function ENT:Think()

	if ( math.random( 1, 2 ) == 1 ) then
	
		local eff = EffectData()
	
		eff:SetOrigin( self:GetPos() + Vector( 0, 0, 100 ) + ( VectorRand():GetNormal() * 25 )  )
		eff:SetEntity( self )
	
		util.Effect( "firework_npc", eff )
		
		--self:EmitSound( "GModTower/lobby/firework/firework_explode.wav",
		--	eff:GetOrigin(),
		--	math.random( 30, 50 ),
		--	math.random( 150, 200 ) )
		
	end
	
	self:NextThink( CurTime() + 0.50 )
	
	return true
	
end

function ENT:AcceptInput( name, activator, ply )

    if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then		
		GTowerStore:OpenStore( ply, 14 )
    end 
	
end