local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

local sprint_minimum = .2

function meta:CanRechargeSprint()
	
	self.SprintCooldown = self.SprintCooldown or 0
	local cooldown = self.SprintCooldown

	return ( ( !self.IsChimera && CurTime() >= cooldown ) || ( self.IsChimera && self:IsOnGround() && !self.IsRoaring && !self.IsBiting && !self.IsStunned ) && !self:KeyDown( IN_SPEED ) )
	
end

function meta:CanSprint()
	
	if self.Sprint > 0 then

		if self.IsTaunting || self.IsRoaring || self.IsBiting then
			return false
		end

		if self.IsChimera then
			return true
		end

		if self.IsScared || ( !self.IsChimera && ( !self:IsOnGround() || self.IsSprintting ) ) then
			return false
		end

		if self:Team() == TEAM_PIGS && !self.Sprinting then
			return true
		end

		if self:IsOnGround() then
			return true
		end

		return false

	end
	
	return false
	
end


function GM:SprintKeyPress( ply, key ) //pigs sprint
	
	if key != IN_SPEED || ply.Sprint < sprint_minimum then
		return
	end
	
	if ply:CanSprint() then
		ply.IsSprintting = true
	end
	
end


if SERVER then

	function meta:HandleSprinting()  //when they're actually sprinting

		if self.IsSprintting then

			local drain = GAMEMODE.SprintDrain

			if self.IsChimera then
				drain = drain - .0075
			else
				drain = drain - ( .000000025 * ( self.Rank / 4 ) )
			end

			self.Sprint = self.Sprint - drain

			if self.Sprint <= 0 then //you're all out man!

				self.IsSprintting = false
			
				if CurTime() > self.SprintCooldown then
					self.SprintCooldown = CurTime() + 2
				end

				self:SetupSpeeds()

				return

			end
		end

		if !self.IsSprintting && self.Sprint < 1 && self:CanRechargeSprint() then

			local recharge = GAMEMODE.SprintRecharge

			if self.IsChimera then
				recharge = recharge + .00005
			else

				local num = .00075
				if self:Crouching() then
					num = .02
				end

				recharge = recharge + ( num * ( self.Rank / 4 ) )

			end

			self.Sprint = math.Clamp( self.Sprint + recharge, 0, 1 )

		end

		self:UpdateSpeeds()

	end							

	hook.Add( "Think", "UC_SprintThink", function()

		for _, ply in ipairs( player.GetAll() ) do

			if !ply:Alive() then ply.IsSprintting = false return end

			ply.Sprint = ply.Sprint or 1
			if ply.IsChimera then ply.IsSprintting = false end

			ply.SprintCooldown = ply.SprintCooldown or 0

			if ply.IsChimera || !ply.IsSprintting then
				ply.IsSprintting = ply:KeyDown( IN_SPEED ) && ply:MovementKeyDown() && ply:CanSprint() && ply:IsOnGround() && ply:IsMoving()
			end

			if ply.IsScared then
				ply:UpdateSpeeds()
				return
			end

			ply:HandleSprinting()

		end

	end )

else

	local sprintbar = surface.GetTextureID( "UCH/hud_sprint_bar" )
	local ucsprintbar = surface.GetTextureID( "UCH/hud_sprint_bar_UC" )

	local sw, sh = ScrW(), ScrH()

	function GM:DrawSprintBar( x, y, w, h )

		local ply = LocalPlayer()

		if ( !ply.Sprint && !ply.IsScared ) || ( ply:Team() == TEAM_PIGS && !ply:Alive() ) then
			return
		end

		local mat = sprintbar
		local rankcolor = ply:GetRankColor()
		local r, g, b = rankcolor.r, rankcolor.g, rankcolor.b
	
		if ply.IsChimera then
			mat = ucsprintbar
			r, g, b = 255, 255, 255
		end

		local a = ply.SprintBarAlpha
	
		ply.SprintMeterSmooth = ply.SprintMeterSmooth || ply.Sprint
	
		local diff = math.abs( ply.SprintMeterSmooth - ply.Sprint )

		ply.SprintMeterSmooth = math.Approach( ply.SprintMeterSmooth, ply.Sprint, FrameTime() * ( diff * 5 ) )

		draw.RoundedBox( 0, x, y, w, h, Color( 130, 130, 130, a ) )

		if !ply.IsChimera then
			draw.RoundedBox( 0, x, y, ( w * sprint_minimum ), h, Color( 100, 100, 100, a ) )
		end
	
		surface.SetTexture( mat )
		surface.SetDrawColor( Color( r, g, b, a ) )
		surface.DrawTexturedRect( x, ( y + 1), ( w * ply.SprintMeterSmooth ), h )
	
		if ply.SprintMeterSmooth <= .02 || ply.IsScared then
			local alpha = ( 100 + ( math.sin( CurTime() * 5 ) * 45 ) )
			draw.RoundedBox( 0, x, y, w, h, Color( 250, 0, 0, alpha ) )
		end

	end

end
