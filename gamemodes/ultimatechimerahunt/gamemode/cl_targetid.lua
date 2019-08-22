surface.CreateFont( "UCH_TargetID", { font = "AlphaFridgeMagnets ", size = ScreenScale( 14), weight = 500 } )
surface.CreateFont( "UCH_TargetIDName", { font = "AlphaFridgeMagnets ", size = ScreenScale( 10), weight = 500 } )

function GM:DrawTargetID()
	
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	
	ply.TargetAlpha = ply.TargetAlpha or 0
	
	ply.TargetInfo = ply.TargetInfo or {}
	
	if IsValid( tr.Entity ) && tr.Entity:IsPlayer() && ( ply.IsGhost || ( ply:Team() == TEAM_PIGS && !tr.Entity.IsGhost && !tr.Entity.IsChimera ) ) then

		if ply.TargetAlpha != 255 then

			local dis = math.abs( 255 - ply.TargetAlpha )
			ply.TargetAlpha = math.Approach( ply.TargetAlpha, 255, FrameTime() * ( dis * 9 ) )

		end

		if tr.Entity != ply.TargetInfo.ply || !ply.TargetInfo.ply then

			ply.TargetInfo.ply = tr.Entity
			ply.TargetInfo.name = tr.Entity:GetName()
			ply.TargetInfo.rank = tr.Entity:GetRankName()

			local color = tr.Entity:GetRankColor()
			ply.TargetInfo.clr = Color( color.r, color.g, color.b, 255 )

		end

	else

		if ply.TargetAlpha != 0 then

			local dis = ply.TargetAlpha
			ply.TargetAlpha = math.Approach( ply.TargetAlpha, 0, FrameTime() * 250 )

		end
		
	end

	local rank, clr, name
	
	if !IsValid( ply.TargetInfo.ply ) then

		rank = ply.TargetInfo.rank or nil
		clr = ply.TargetInfo.clr or nil
		name = ply.TargetInfo.name or nil

	else

		local ply = ply.TargetInfo.ply
		rank = ply:GetRankName()

		local color = ply:GetRankColor()
		clr = Color( color.r, color.g, color.b, 255 )
		name = ply:GetName()

		if ply.IsGhost then

			if ply.IsFancy then
				rank = "Fancy Ghostie"
			else
				rank = "Spooky Ghostie"
			end

			clr = Color( 255, 255, 255, 255 )

		end

		if ply.IsChimera then

			rank = "The Ultimate Chimera"
			clr = Color( 230, 30, 110, 255 )

		end

	end

	if !clr || !rank || !name || !ply.TargetInfo || !IsValid( ply.TargetInfo.ply ) then return end
	if !ply.TargetInfo.name || ply.TargetInfo.name == "" then ply.TargetInfo.name = "Unknown" end
	
	clr.a = ply.TargetAlpha
	
	if ply.TargetAlpha > 0 then

		surface.SetFont( "UCH_TargetIDName" )
		local _, h = surface.GetTextSize( rank )

		self:DrawNiceText( rank, "UCH_TargetIDName", ScrW() * .5, ScrH() * .55, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ply.TargetAlpha )
		self:DrawNiceText( ply.TargetInfo.name, "UCH_TargetID", ScrW() * .5, ( ScrH() * .55 ) + h, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, ply.TargetAlpha )

	end

end
