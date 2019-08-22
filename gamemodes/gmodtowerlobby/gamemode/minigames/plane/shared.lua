local Vector = Vector
local TEAM_SPECTATOR = TEAM_SPECTATOR
local IN_JUMP = IN_JUMP
local FrameTime = FrameTime
local util = util 
local Angle = Angle
local math = math
local IsValid = IsValid
local Msg = Msg
local ACHIVEMENTS = ACHIVEMENTS
local _G = _G
local GTowerLocation = GTowerLocation

module("minigames.plane")

MinigameName = "Plane Battle"
MinigameLocation = 51
MinigameMessage = "MiniBattleGameStart"
MinigameArg1 = "Airplane Fight"
MinigameArg2 = GTowerLocation:GetName( MinigameLocation )

function HookPlayerMove( pl, mv )

	if InGame( pl ) then
		
		if ( !pl:Alive() ) then return end
		if ( pl:Team() == TEAM_SPECTATOR ) then return end
		//if ( !pl:GetNWFloat( "Speed", false ) ) then return end
		
		local vel = GetPlaneVel( pl ) //pl:GetNWFloat( "Speed", 100 )
		local accel = 30.0
		
		local Dot = pl:GetAimVector():Dot( Vector( 0, 0, -1 ) )
		
		// Boost, todo, make temporary
		if ( pl:KeyDown( IN_JUMP ) ) then
			Dot = Dot + 5.0
		end
		
		vel = math.Clamp( vel + Dot * FrameTime() * accel, 0, 1000 )
		
		if ( vel > 200 && !pl:KeyDown( IN_JUMP ) ) then
			vel = vel - ( FrameTime() * 120 )
		end
		
		//pl:SetNWFloat( "Speed", vel )
		SetPlaneVel( pl, vel )
		
		local Velocity = pl:GetAimVector() * vel * 5
		
		local Target = pl:GetPos() + Velocity * FrameTime()
		
		
		//debugoverlay.Line( pl:GetPos(), Target, 10 )
		
		local trace = { start = pl:GetPos(), endpos = Target, filter = pl }	  
		local tr = util.TraceLine( trace )
		
		if ( tr.Hit ) then
			
			pl:SetPos( tr.HitPos + tr.HitNormal * 50 )
			mv:SetVelocity( Vector(0,0,0) )
			
			if ( SERVER ) then
				timer.Simple( 0, DoExplosion, pl )
				pl:Kill()
			end
		
		else
		
			mv:SetVelocity( Velocity )
			mv:SetOrigin( Target )
		
		end	
		
		return true
	
	end

end

function ShouldCollide(ent1, ent2) 
	if InGame( ent1 ) && InGame( ent2 ) then
		return true
	end
end

function HookPlayerAnim( ply, anim )
	
	if InGame( ply ) then		
		return _G.ACT_BUSY_SIT_CHAIR, ply:LookupSequence( "drive_jeep" )
	end
	
end

Aim = {0,30,0}

function CalcView( ply, origin, angles, fov )
	
	if !InGame( ply ) then return end
	if !ply:Alive() then return end
	
	local Pos = ply:EyePos()
	
	return {
		origin = Pos + angles:Up() * Aim[1] + angles:Forward() * Aim[2] + angles:Right() * Aim[3],
		angles = angles,
		fov = fov	
	}

end