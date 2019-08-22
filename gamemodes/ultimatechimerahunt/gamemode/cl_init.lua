include( "shared.lua" )

/* Client Side Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/cl_*.lua", "LUA" ) ) do
	if v != "cl_init.lua" then
		include( v )
	end
end

/* Shared Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/sh_*.lua", "LUA" ) ) do
	include( v )
end

local txtmat = surface.GetTextureID( "UCH/logo/UClogo1" )
local tailmat = surface.GetTextureID( "UCH/logo/UClogo2" )
local birdmat = surface.GetTextureID( "UCH/logo/UClogo3" )
local btnmat = surface.GetTextureID( "UCH/logo/UClogo4" )
local wingmat = surface.GetTextureID( "UCH/logo/UClogo5" )
local expmat = surface.GetTextureID( "UCH/logo/UClogo6" )

local waverot = 0
local wavetime = CurTime() + 6

hook.Add( "Think", "LogoThink", function()

	local t = wavetime - CurTime()
	if t < 0 then
		wavetime = CurTime() + math.random( 12, 24 )
	end

	if t > 1.25 then
		waverot = math.Approach( waverot, 0, FrameTime() * 75 )
	else
		local num = 16 * math.sin( CurTime() * 12 )
		waverot = math.Approach( waverot, num, FrameTime() * 400 )
	end

end )

hook.Add( "ShouldHideHats", "ShouldHideHats", function( ply )

	if ply.IsChimera then
		return true
	end

	if ply:Team() == TEAM_GHOST && LocalPlayer():Team() != TEAM_GHOST then
		return true
	end

end )

function GM:DrawLogo( x, y, size )
	
	local size = size or 1 //if they didn't specify size, just default it to 1
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local txtw = ((ScrH() * .8 ) * size )
	local txth = ( txtw * .5 )
	
	//Wing 1
	local w = ( txth * .575 )
	local h = w
	
	local deg = 8
	local sway = ( deg * math.sin((CurTime() * 1.25)))
	
	surface.SetTexture( wingmat )
	surface.DrawTexturedRectRotated((x - ( txtw * .038)), ( y - ( txth * .205)), w, h, (-36 + sway))
	
	//Button
	local w = ( txth * .116 )
	local h = w
	
	surface.SetTexture( btnmat )
	surface.DrawTexturedRect((x - ( txtw * .0625)), ( y - ( txth * .27)), w, h )

	//Wing 2
	local w = ( txth * .575 )
	local h = w
	
	local deg = 8
	local sway = deg * math.sin( CurTime() * 1 )
	
	surface.SetTexture( wingmat )
	surface.DrawTexturedRectRotated((x - ( txtw * .05)), ( y - ( txth * .21)), w, h, (-4 + sway))
	
	//Tail
	local w = ( txtw * .14 )
	local h = ( w * 4 )

	local deg = 6
	local sway = ( deg * math.sin((CurTime() * 2)))
	
	surface.SetTexture( tailmat )
	surface.DrawTexturedRectRotated((x - ( txtw * .255)), ( y - ( txth * .145)), w, h, (-6 + sway))
	
	//Bird
	local w = ( txth * .28 )
	local h = w
	
	surface.SetTexture( birdmat )
	surface.DrawTexturedRect((x + ( txtw * .146)), ( y - ( txth * .3575)), w, h )
	
	// (!)
	local w = ( txth * .64 )
	local h = w
	
	surface.SetTexture( expmat )
	surface.DrawTexturedRectRotated((x + ( txtw * .2425)), ( y + ( txth * .09)), w, h, waverot )
	
	//Text
	surface.SetTexture( txtmat )
	surface.DrawTexturedRect((x - ( txtw * .5)), ( y - ( txth * .5)), txtw, txth )
	
end

function GM:PositionScoreboard( ScoreBoard )
	
	ScoreBoard:SetSize( 700, ScrH() - 100 )
	ScoreBoard:SetPos( ScrW() - ScoreBoard:GetWide() / 2, 50 )
	
end

function GM:RenderScreenspaceEffects()
	
	if LocalPlayer().IsGhost then
		DoGhostEffects()
	end

	for k, ply in pairs( player.GetAll() ) do

		if !LocalPlayer().IsGhost && ply.IsGhost || ( ply.IsChimera && !ply:Alive() ) then
			ply:SetRenderMode( RENDERMODE_NONE )
		else
			ply:SetRenderMode( RENDERMODE_NORMAL )
		end

		ply.skin, ply.bgroup, ply.bgroup2 = ( ply.skin || nil ), ( ply.bgroup || nil ), ( ply.bgroup2 || nil )

		if ply:Alive() then
			ply.skin = ply:GetSkin()
			ply.bgroup = ply:GetBodygroup( 1 )
			ply.bgroup2 = ply:GetBodygroup( 2 )
		end

		local rag = ply:GetRagdollEntity()
		if IsValid( rag ) then
			if !ply.IsChimera then
				rag:SetSkin( ply.skin or 1 )
				rag:SetBodygroup( 1, ply.bgroup or 1 )
				rag:SetBodygroup( 2, ply.bgroup2 or 1 )
				
				if !rag.Flew && ply.RagShouldFly then

					rag.Flew = true
					ply.RagShouldFly = false
					local uc = self:GetUC()
					if !IsValid( uc ) then return end

					local dir = uc:GetForward() + Vector( 0, 0, .75 )
					for i = 0, rag:GetPhysicsObjectCount() - 1 do
						rag:GetPhysicsObjectNum( i):ApplyForceCenter( dir * 50000 )
					end
					ply:Squeal( rag )

				end
				
			else
				rag:SetSkin( 1 )
				rag:SetBodygroup( 1, 0 )
			end
		end
		
		if ply.IsPancake then
			ply:DoPancakeEffect();
		else
			ply.PancakeNum = 1;
			local scale = Vector( 1,1,1 )
			local mat = Matrix();
			mat:Scale( scale );
			ply:EnableMatrix( "RenderMultiply", mat );
		end
		
	end
	
end

function GM:PrePlayerDraw( ply )
	
	if ( !LocalPlayer().IsGhost && ply.IsGhost || ( ply.IsChimera && !ply:Alive() ) || ( ply.IsGhost && ply:GetModel() != "models/uch/mghost.mdl" ) ) then
		return true
	end
	
end

/*hook.Add( "PreDrawHalos", "UCAngryHalo", function()

	if GAMEMODE:IsLastPigmasks() then
		halo.Add( { GAMEMODE:GetUC() }, Color( 255, 80, 80, 150 ), 2, 2, math.random( 4, 6 ), true, false )
		halo.Add( { GAMEMODE:GetUC() }, Color( 255, 255, 255, 150 ), 1, 1, 1, true, false )
	end

end )*/

usermessage.Hook( "UCMakeRagFly", function( um )

	local ply = um:ReadEntity()
	
	if IsValid( ply ) then
		ply.RagShouldFly = true
	end

end )

usermessage.Hook( "UCRound", function( um )

	local GameEnd = um:ReadBool()

	if GameEnd then

		RunConsoleCommand( "gmt_showscores", 1 )

	else

		RunConsoleCommand( "gmt_showscores" )
		RunConsoleCommand( "r_cleardecals" )

	end

end )

/* Disable Bhop */
hook.Add( "CreateMove", "DisableBhop", function( input )
	local ply = LocalPlayer()
	if ply:Alive() && input:KeyDown( IN_JUMP ) && ply.NextJump && CurTime() < ply.NextJump then
		input:SetButtons( input:GetButtons() - IN_JUMP )
	end
end )

hook.Add( "OnPlayerHitGround", "SetNextJump", function( ply, bInWater, bOnFloater, flFallSpeed )
	ply.NextJump = CurTime() + 0.08
end )


local function GetEyeAttach( ent, attachmentname )
	
	local attach = ent:LookupAttachment(attachmentname)

	if attach > 0 then
		local attach = ent:GetAttachment(attach)
		return attach.Pos
	end

end

local function EmitFlames( ent, pos )
	
	if not ent.Emitter then
		ent.Emitter = ParticleEmitter( pos )
	end

	local flare = Vector( CosBetween( -1, 1, RealTime() * 10 ), SinBetween( -2, 2, RealTime() * 10 ), 0 )

	local particle = ent.Emitter:Add( "particles/flamelet" .. math.random( 1 , 5 ), pos + ( VectorRand() * 3 ) )
	particle:SetVelocity( Vector( 0, 0, 40 ) + flare )
	particle:SetDieTime( math.Rand( .5, 1 ) )
	particle:SetStartAlpha( math.random( 150, 255 ) )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( math.random( 1, 5 ) )
	particle:SetEndSize( 0 )
	particle:SetColor( 255, 255, 255 )
	particle:SetGravity( Vector( 0, 0, 50 ) )

end

local SpriteMat = Material( "sprites/light_ignorez" )
hook.Add("PostDrawOpaqueRenderables", "UCAngry", function()

	if GAMEMODE:IsLastPigmasks() then
		local uch = GAMEMODE:GetUC()
		if IsValid( uch ) && uch:Alive() then

			local LEye = GetEyeAttach( uch, "L_eye" )
			local REye = GetEyeAttach( uch, "R_eye" )

			if not LEye or not REye then return end

			-- Flames
			if not uch.NextParticle or RealTime() > uch.NextParticle then
				EmitFlames( uch, LEye )
				EmitFlames( uch, REye )
				uch.NextParticle = RealTime() + 0.05
			end
			
			-- Glow
			render.SetMaterial( SpriteMat )

			if util.PixelVisible( LEye, 8, util.GetPixelVisibleHandle() ) then
				render.DrawSprite( LEye, 50, SinBetween(20,30, RealTime()*5), Color( 255, 0, 0 ) )
			end
			if util.PixelVisible( REye, 8, util.GetPixelVisibleHandle() ) then
				render.DrawSprite( REye, 50, SinBetween(20,30, RealTime()*5), Color( 255, 0, 0 ) )
			end

		end

	end

end)