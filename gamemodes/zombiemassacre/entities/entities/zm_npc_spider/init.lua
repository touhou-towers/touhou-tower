AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = Model( "models/npc/spider_regular/npc_spider_regular.mdl" )

ENT.HP = 150
ENT.Damage = 35
ENT.Points = 2

ENT.AttackDelay = 2
ENT.AttackRadius = 72
ENT.RagdollDeath = false

ENT.SAlert = { "GModTower/Zom/creatures/spider/alert", 3 }
ENT.SAttack = { "GModTower/Zom/creatures/spider/attack", 3 }
ENT.SDie = { "GModTower/Zom/creatures/spider/die", 3 }
ENT.SIdle = { "GModTower/Zom/creatures/spider/idle", 2 }
ENT.SMiss = { "GModTower/Zom/creatures/spider/miss", 2 }
ENT.SPain = { "GModTower/Zom/creatures/spider/pain", 6 }

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