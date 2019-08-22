

-----------------------------------------------------
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Firework Bullet"

ENT.Model = Model( "models/gmod_tower/firework_rocket.mdl" )

ENT.SoundLiftOff = Sound( "GModTower/lobby/firework/firework_launch.wav" )
ENT.SoundExplosion = Sound( "GModTower/lobby/firework/firework_explode.wav" )

/*hook.Add( "ShouldCollide", "ShouldCollideFireworks", function( ent1, ent2 )

	if ent1:GetClass() == "ammo_firework" && ent2:GetClass() == "func_physbox" then
		return false
	end

	if ent1:GetClass() == "ammo_firework" && ent2:GetClass() == "gmt_pooltube" then
		return false
	end

	return true

end )*/
