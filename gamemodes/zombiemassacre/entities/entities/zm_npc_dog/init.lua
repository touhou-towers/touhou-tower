AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = Model( "models/zom/dog.mdl" )

ENT.HP = 150
ENT.Damage = 35
ENT.Points = 8

ENT.AttackDelay = 2
ENT.AttackRadius = 72
ENT.RagdollDeath = false

/*ENT.SAlert = { "GModTower/Zom/zombie/alert/alert", 79 }
ENT.SAttack = { "GModTower/Zom/zombie/attack/attack", 16 }
ENT.SDie = { "GModTower/Zom/zombie/die/die", 30 }
ENT.SIdle = { "GModTower/Zom/zombie/idle/idle", 31 }
ENT.SMiss = { "GModTower/Zom/zombie/miss/miss", 2 }
ENT.SPain = { "GModTower/Zom/zombie/pain/pain", 24 }*/

function ENT:Attack( enemy, hit )

	if !enemy then return end
	local hit = hit or false

	if hit then

		local a = math.random( 1, 2 )
		local sequence

		if a == 1 then
			sequence = self:LookupSequence( "attack_leftmidbite" )
		else
			sequence = self:LookupSequence( "attack_rightmidbite" )
		end

		self:SetSequence( sequence )
		self:SetPlaybackRate( .5 )
		
		enemy:TakeDamage( self.Damage, self )		
		--self:EmitSoundTable( self.SAttack )

	--else

		--self:EmitSoundTable( self.SMiss )

	end

end