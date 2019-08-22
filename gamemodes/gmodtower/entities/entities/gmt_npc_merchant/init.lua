
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ent = ents.Create( "gmt_npc_merchant" )
	ent:SetPos( tr.HitPos + Vector(0,0,3) )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
	self:UpdateAnimation()
end

function ENT:UpdateAnimation()
	if !IsValid( self ) then
		return
	end

	local anim = self:LookupSequence("idle_subtle")

	if anim <= 0 then
		Msg("Could not find animation")
	end

	self:SetAnimation( anim )

end

function ENT:AcceptInput( name, activator, ply )

    if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then
		GTowerStore:OpenStore( ply, 8 )
			if self:GetNWBool("Sale") then
				if math.random(1,2) == 1 then
					self:EmitSound(Sound("GModTower/stores/merchant/sale.wav"))
				else
					self:EmitSound(Sound("GModTower/stores/merchant/sale2.wav"))
				end
			else
				self:EmitSound(Sound("GModTower/stores/merchant/open.wav"))
			end
    end

	timer.Simple( 0.0, self.UpdateAnimation, self )
end
