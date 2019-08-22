
function GM:Think()

	game.GetWorld():SetNWFloat("State", game.GetWorld().State)
	game.GetWorld():SetNWFloat("SetTime", game.GetWorld().SetTime)
	game.GetWorld():SetNWFloat("Time", game.GetWorld().Time)
	game.GetWorld():SetNWFloat("Round", game.GetWorld().Round)
	game.GetWorld():SetNWFloat("MaxRounds", game.GetWorld().MaxRounds)

	for _, v in ipairs( player.GetAll() ) do
		
		if v.IsVirus then
			self:VirusThink( v )
		else
			self:PlayerThink( v )
		end
	
	end
	
	if ( CurTime() >= self.NextRankThink ) then
	
		for _, v in ipairs( player.GetAll() ) do
			self:RankThink( v )
		end
		
		self.NextRankThink = CurTime() + 2
	end


	self:MapThink()
	
end

function GM:PlayerDeathThink( ply )

	if !IsValid( ply ) then return end
	
	if CurTime() > ply.RespawnTime then
		ply:Spawn()
	end
end


// map specific logic
function GM:MapThink()

	if ( CurTime() >= self.NextMapThink ) then

		local mapName = game.GetMap()

		//sewage water kill (for survivors)
		if mapName == "gmt_virus_sewage01" then
		
			for _, v in ipairs( player.GetAll() ) do

				if v:WaterLevel() != 0 then
					if !v:Alive() then return end
			
					if v:IsPlayer() && v:Alive() then
						v:Kill()
					end
				end
				
			end

		end

		self.NextMapThink = CurTime() + 0.1

	end

end

function GM:PlayerThink( ply )

	if ( !IsValid( ply ) || !ply:Alive() ) then return end  // MAC YOU STUPID RETARD
	
	if game.GetWorld().State == STATUS_WAITING then
		ply:CrosshairDisable() //JESUS FUCK DISABLE THE GOD DAMN CROSSHAIR
	end
	
	if game.GetWorld().State == STATUS_WAITING then return end
	
	if ( #ply:GetWeapons() == 0 && CurTime() > ply.NextWeaponThink && !ply.IsVirus ) then
		hook.Call( "PlayerLoadout", GAMEMODE, ply )
		ply.NextWeaponThink = CurTime() + 2
	end
	
	if game.GetWorld().State != STATUS_PLAYING then return end

	for _,v in ipairs( player.GetAll() ) do

		if ( v == ply || !v:Alive() || !v.IsVirus ) then return end

		local dist = ply:GetPos():Distance( v:GetPos() )
		//ply:ChatPrint( tostring(v) .. "| Dist: " .. tostring(dist) )

		local rad = 950  //start kicking in they're fucking close
		local scale_mod = 0.5

		if dist < rad then
			if dist < ( rad / 2 ) then
				scale_mod = 0.15  //freak the hug out
			end

			local scale = ( dist / rad ) * scale_mod
			//ply:ChatPrint( tostring(v) .. "| Scale: " .. tostring(scale) )

			if ( ply.NextRadSound or 0 ) < CurTime() then

				ply.NextRadSound = CurTime() + scale

				local ran = math.random( 1, 2 )
				if ran == 1 then
					ply:EmitSound( "Geiger.BeepLow", 50, math.random( 90, 110 ) )
				else
					ply:EmitSound( "Geiger.BeepHigh", 50, math.random( 90, 110 ) )
				end

			end

		end
	end

end

function GM:VirusThink( ply ) 

	if ( !IsValid( ply ) || !ply:Alive() ) then return end  // MAC YOU STUPID RETARD
	
	ply:StripWeapons()
	ply:RemoveAllAmmo()

	if ( game.GetWorld().State != STATUS_PLAYING ) then return end
	
	if ply.Flame != nil then
		local objs = ents.FindInSphere( ply:GetPos() + Vector( 0, 0, 40 ), 40 )

		if ( ply:GetVelocity():Length() <= 0 ) then return end  //standing still fuckers
		
		for _, v in ipairs( objs ) do
			if ( IsValid( v ) && v:IsPlayer() && !v.IsVirus ) then	
				self:Infect( v, ply )
			end
		end
	end
	
	if game.GetWorld().NumVirus == 1 then 
		
		for k,v in pairs(player.GetAll()) do
			if ( v.IsVirus && v:Deaths() >= 2 && v.enraged != true ) then
				
				v.enraged = true
				
				v:SetWalkSpeed( 500 )
				v:SetRunSpeed( 500 )
				
			elseif v.enraged == true then
			
				v:SetWalkSpeed( 500 )
				v:SetRunSpeed( 500 )
				
			end
		end
		
	elseif game.GetWorld().NumVirus >= 2 then
		
		for _, v in ipairs( player.GetAll() ) do
			if v.IsVirus || v.enraged == true then
				
				v.enraged = false
				v:SetWalkSpeed( self.VirusSpeed )
				v:SetRunSpeed( self.VirusSpeed )
				
			end
		end
		
	end

end

function GM:RankThink( ply, force )

	local rank = 1
	
	for _, v in ipairs( player.GetAll() ) do
		if self:ShouldCalcRank( ply, v ) || force then
		
			if ( v:Frags() > ply:Frags() ) then
			
				rank = rank + 1
				
			elseif ( v:Frags() == ply:Frags() ) then
				if ( v:Deaths() < ply:Deaths() ) then
				
					rank = rank + 1
					
				end
			end
			
		end
	end
	
	ply.Rank = rank
	
end

function GM:ShouldCalcRank( forPlayer, comparePlayer )

	if !( IsValid( forPlayer ) && IsValid( comparePlayer ) ) then return false end
	if ( forPlayer == comparePlayer ) then return false end
	
	return true
	
end