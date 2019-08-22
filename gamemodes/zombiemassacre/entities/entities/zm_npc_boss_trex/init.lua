AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = Model( "models/dinosaurs/trex.mdl" )

ENT.HP = 150
ENT.Damage = 35
ENT.Points = 2

ENT.AttackDelay = 2
ENT.AttackRadius = 72
ENT.RagdollDeath = false

ENT.SAttack = { "GModTower/zom/creatures/trex/trex_attack", 2 }
ENT.SDie = { "GModTower/zom/creatures/trex/trex_die", 1 }
ENT.SIdle = { "GModTower/zom/creatures/trex/trex_idle", 2 }
ENT.SPain = { "GModTower/zom/creatures/trex/trex_pain", 4 }

function ENT:Attack( enemy, hit )

	if !enemy then return end
	local hit = hit or false

	if hit then

		local a = math.random( 1, 2 )
		local sequence

		if a == 1 then
			sequence = self:LookupSequence( "Attack_1" )
		else
			sequence = self:LookupSequence( "Attack_"..math.random(2,4) )
		end

		self:SetSequence( sequence )
		self:SetPlaybackRate( .5 )

		enemy:TakeDamage( self.Damage, self )
		self:EmitSoundTable( self.SAttack )

	else

		self:EmitSoundTable( self.SMiss )

	end

end

/*function ENT:Precache()
	for _, mdl in ipairs( self.Models ) do
		util.PrecacheModel( mdl )
	end
end*/
