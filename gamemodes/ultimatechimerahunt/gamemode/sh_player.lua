function GM:KeyPress( ply, key )
	
	if !ply.IsGhost then

		self:SprintKeyPress( ply, key )

	end

	if SERVER then

		if key == IN_ATTACK2 && ply:CanTaunt() then

			local t, num = "taunt", 1.1

			if ply.Rank == 4 then
				t, num = "taunt2", 1
			end

			ply:Taunt( t, num )

		end

		if key == IN_USE || key == IN_ATTACK then

			ply.LastPressAttempt = ply.LastPressAttempt || 0

			if CurTime() < ply.LastPressAttempt then
				return
			end

			ply.LastPressAttempt = CurTime() + .1

			if ply:IsPig() then
				
				if ply:CanPressButton() then

					local uc = self:GetUC()
					uc:EmitSound( "UCH/chimera/button.wav", 80, math.random( 94, 105 ) )
					
					uc.Pressed = true
					uc.Presser = ply

					ply:RankUp()
					ply:AddAchivement( ACHIVEMENTS.UCHBUTTON, 1 )
					
					if !ply:IsOnGround() then
						ply:SetAchivement( ACHIVEMENTS.UCHAERIAL, 1 )
					end

					uc:Kill()

					ply:AddFrags( 1 )

				end
				
				if key == IN_ATTACK && ply.HasSaturn && !ply.IsScared && !ply.IsTaunting then

					ply:EmitSound( "UCH/saturn/saturn_throw.wav", 80, 100 )
					
					timer.Simple( 0.01, function() if IsValid(ply) then ply.HasSaturn = false end end )
					
					if IsValid( ply.HeldSaturn ) then
						ply.HeldSaturn:Remove()
					end

					local ent = ents.Create( "mr_saturn" )
					if IsValid( ent ) then
						ent:SetPos( ply:GetShootPos() + Vector( 10, 0, 0 ) )
						ent:SetOwner( ply )
						ent:SetPhysicsAttacker( ply ) 
						ent:Spawn()
						ent:Activate()
						ent.ShouldSpaz = true

						local phys = ent:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity( ply:GetVelocity() + ( ply:GetAimVector() * 800 ) )
						end

					end
					
					//anim hack
					umsg.Start( "SwitchLight" )
						umsg.Entity( ply )
					umsg.End()

				end

			end

		end

		if ply.IsChimera then
			self:UCKeyPress( ply, key )
		end
	
	else
		
		if !ply.IsGhost && key == IN_ATTACK || key == IN_USE then
			LocalPlayer().XHairAlpha = 242
		end
		
	end

end

function GM:Move( ply, move )

	if !IsValid( ply ) then return end
		
	if ply.IsGhost then
		
		local move = ply.GhostMove( move )
		return move
		
	else

		if ply.IsTaunting || ply.IsBiting || ply.IsRoaring || ( ply.IsChimera && !ply:Alive() ) then

			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
			
			if !ply.LockTauntAng then
				ply.LockTauntAng = ply:EyeAngles()
			end
			
			if ply:Alive() then
				ply:SetEyeAngles( ply.LockTauntAng )
			end
			
			return true

		else

			ply.LockTauntAng = nil
			return self.BaseClass:Move( ply, move )

		end
		
	end
	
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, players )
	
	if ply.IsChimera || ply.IsGhost then
		return true
	end
	
end

function RestartAnimation( ply )
	
	ply:AnimRestartMainSequence()

	umsg.Start( "UC_RestartAnimation" )
		umsg.Entity( ply )
	umsg.End()
	
end