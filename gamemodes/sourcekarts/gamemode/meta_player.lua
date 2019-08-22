local novel = Vector( 0, 0, 0 )



hook.Add( "Move", "KartMove", function(ply, mv)

	--if ply:Team() == TEAM_CAMERA then return end


	if IsValid(ply:GetKart()) then
		mv:SetForwardSpeed( 0 )

		mv:SetSideSpeed( 0 )

		mv:SetVelocity( novel )

		if SERVER then ply:SetGroundEntity( NULL ) end



		local kart = ply:GetKart()

		local offset = 8



		if IsValid( kart ) then

			mv:SetOrigin( kart:GetPos() + kart:GetUp() * offset )

		end



		return true
	end



end )

-----------------------------------------------------
local meta = FindMetaTable( "Player" )

if !meta then

	Msg("ALERT! Could not hook Player Meta Table\n")

	return

end



function meta:GetKart()



	if IsValid( self:GetNWEntity( "Kart" ) ) then

		return self:GetNWEntity( "Kart" )

	end



	// The netvar failed, so we'll try getting it in another way

	for _, ent in pairs( ents.FindByClass( "sk_kart" ) ) do



		if ent:GetOwner() == self then

			return ent

		end



	end



end

function meta:GetPlayerColor2()
	return (self:GetNWVector( "PlyColor") ) or Vector(0,0,0)
end

function meta:IsSlowed() return self:GetNWBool( "Slowed") or false end

function meta:SetSlowed( slow ) self:SetNWBool("Slowed", slow) end



function meta:GetLap() return self:GetNWInt("Lap",1) end

function meta:SetLap( lap ) self:SetNWInt("Lap", lap) end



function meta:GetPosition() return self:GetNWInt("Position") or 1 end

function meta:SetPosition( pos ) self:SetNWInt("Position", pos) end



function meta:GetLapTime() return self:GetNWFloat( "LapTime" ) or 0 end

function meta:SetLapTime( time ) self:SetNWFloat("LapTime",time) end



function meta:GetBestLapTime() return self:GetNWFloat( "BestLapTime" ) or 0 end

function meta:SetBestLapTime( time ) self:SetNWFloat("BestLapTime",time) end



function meta:GetTotalTime() return self:GetNWFloat("TotalTime") or 0 end

function meta:SetTotalTime( time ) self:SetNWFloat("TotalTime",time) end



function meta:GetCheckpoint() return self:GetNWInt("Checkpoint") or 0 end

function meta:SetCheckpoint( point ) self:SetNWInt("Checkpoint", point) end



function meta:IsGhost() return self:GetNWBool("Ghost") or false end



if SERVER then



	function meta:SpawnKart( pos, angles, engineon )



		if !IsValid( self ) then return end



		local kart = self:GetKart()

		if IsValid( kart ) then kart:Remove() end



		local kart = ents.Create( "sk_kart" )

		kart:SetPos( pos or ( self:GetPos() + Vector( 0, 0, 25 ) ) )

		kart:SetAngles( angles or Angle( 0, 90, 0 ) )

		kart:Spawn()

		self.RevTime = 0

		kart:EmitSound( "GModTower/sourcekarts/effects/start.wav", 80, math.random( 120, 150 ) )



		kart:SetOwner( self )

		kart:SetIsEngineOn( engineon )



		/*local phys = kart:GetPhysicsObject()

		if IsValid( phys ) then

			phys:EnableMotion( engineon )

		end*/



		self:SetNWEntity( "Kart", kart )



		local scale = GTowerModels.GetScale( self:GetModel() )

		if scale < 1 then

			kart:SetModel( kart.ModelSmall )

		else

			kart:SetModel( kart.Model )

		end



		return kart



	end



	function meta:SetGhost( bool, delay )



		self:SetNWBool("Ghost", bool)



		local kart = self:GetKart()



		if bool then



			self:ClearItems()



			if delay then

				timer.Simple( delay, function()

					if IsValid( self ) then

						self:SetNWBool("Ghost", false)

					end

				end )

			end



		end



	end



	function meta:TakeBattleDamage( attacker )



		if self:Team() != TEAM_PLAYING || self:IsGhost() then return end



		// Reduce lives

		self:AddDeaths( 1 )



		if self:Deaths() >= GAMEMODE.MaxLives then

			--GAMEMODE:Eliminate( self )
			self.Dead = true
			self:SetGhost( true )
			self:SetTeam(TEAM_FINISHED)

		else

			self:SetGhost( true, 5 )

		end



		if attacker then

			attacker:AddFrags( 1 )

		end



	end



else // CLIENT





end



function meta:InNodeType( type )



	local kart = self:GetKart()

	if !IsValid( kart ) then return end



	local node = checkpoints.ClosestPoint( kart:GetPos() )

	if node then



		local nodedata = checkpoints.Points[ node ]



		local trace = util.TraceLine( {

			start = nodedata.pos,

			endpos = kart:GetPos(),

			filter = { self, kart }

		} )



		if !trace.HitWorld then

			return nodedata.type == type

		end



	end



end
