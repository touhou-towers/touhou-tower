function GM:PlayerDeath( ply, wep, killer )

	self:DoKillNotice( ply )

	ply:AddDeaths( 1 )

	if ply:Team() == TEAM_PIGS then

		ply.IsDead = true // to set as ghost on next spawn
		ply.DeadPos = ply:GetPos()

		if !ply.IsPancake then
			ply:CreateRagdoll()
		end
		
		if ply.IsTaunting then
			ply:StopTaunting()
		end

		if ply:FlashlightIsOn() then
			ply:Flashlight()
		end
		
		if ply.HasSaturn then
		
			ply:StripSaturn()
			ply.HasSaturn = false

		end

		if ply.IsPancake then

			local color = ply:GetRankColor()
			local r, g, b = color.r, color.g, color.b
			local effectdata = EffectData()
				effectdata:SetOrigin( ply:GetPos() )
				effectdata:SetStart( Vector( r, g, b ) )
			util.Effect( "piggy_pop", effectdata )
	
			ply.IsPancake = false
		end

		if team.AlivePigs() > 0 then
			self:AddTime( self.OverTimeAdd )
		end

		/*ply.DeathTime = 0
		ply.NextSecond = CurTime() + 1*/
		timer.Simple( 3, function()
			
			if !IsValid(ply) then return end
			
			if !ply.IsChimera && !ply.IsGhost then
				ply:Spawn()
			end

		end )

	end

	if ply.IsChimera then
		ply:CreateBirdProp()
		ply:CreateRagdoll()
	end

	self:CheckGame( ply )

end

function GM:PlayerDeathThink( ply )

	if ply.IsChimera then
		return false
    end

end

function GM:PlayerDisconnected( ply )

	if !self:IsPlaying() then return end

	self:CheckGame( ply )
	
end

function GM:PlayerSwitchFlashlight( ply, SwitchOn )

	if !ply:IsAdmin() then
		if !ply.FlashLightTime then ply.FlashLightTime = 0 end
		if ply.FlashLightTime > CurTime() then return false end
			
		ply.FlashLightTime = CurTime() + 1
	end

	if ply:Team() == TEAM_PIGS then
		umsg.Start( "SwitchLight" )
			umsg.Entity( ply )
		umsg.End()
	end

    return ply:Team() == TEAM_PIGS

end

function GM:CanPlayerSuicide( ply ) return false end

function GM:PlayerUse( ply, ent )
	
	if ply.IsGhost then
		return false
	end

	return true
	
end

function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmg )
	
	if IsValid( ent ) && ent:IsPlayer() then

		if ent.IsChimera || ent.IsGhost || ( ent:Health() - amount ) <= 0 then
			
			if ent.IsChimera && amount > 100 then
				ent:Kill()
			end

			if ent:Alive() && !ent.IsChimera && ( ( ent:Health() - amount ) <= 0 ) then
				ent:Kill()
			end
			
			dmg:ScaleDamage( 0 )

		end
		
		if ent:IsPig() then
			dmg:ScaleDamage( 0 )
		end

	end
	
end

function GM:PlayerDeathSound() return true end

function GM:GetFallDamage( ply, vel )
	
	if ply.IsGhost then
		return false
	end

	if ply.IsChimera then
		return 0
	end
	
end


function GM:PlayerDisconnected( ply )
	
	if ply:IsBot() || #player.GetBots() > 0 then return end

	//Everyone left, end the game.
	local total = player.GetAll()
	if total < 1 then
		self:EndServer()
		return
	end
	
	self:CheckGame( ply )

end

hook.Add( "PlayerThink", "UC_PiggyNoise", function( ply )

	if ply:IsPig() then
		ply:MakePiggyNoises()
	end

end )