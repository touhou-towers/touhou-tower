local Vector = Vector
local TEAM_SPECTATOR = TEAM_SPECTATOR
local IN_JUMP = IN_JUMP
local FrameTime = FrameTime
local util = util 
local Angle = Angle
local math = math
local IsValid = IsValid
local Msg = Msg
local getfenv = getfenv
local minigames = minigames

module("minigames.plane")

minigames.RegisterMinigame( getfenv() ) 

Settings = {
	Money = {
		Name = "Money earned per kill",
		Type = "number",
		Min = 0,
		Max = 15,
		Default = 5,
		Decimals = 0,
	},
	SpawnTime = {
		Name = "Spawn time",
		Type = "number",
		Min = 0.0,
		Max = 3.0,
		Default = 1.0,	
		Decimals = 1,
	},
	Location = {
		Name = "Spawn Location",
		Type = "dropdown", //Drop down box - Choose one
		Values = {
			[1] = { //Value that is sent to the server
				Name = "Lobby", //Value that the client see
			},	
		},
		Default = 2
	}
}

Information = {
	Name = "Plane wars",
	Author = "Nican",
}

function HookPlayerMove( pl, mv )

	if InGame( pl ) && !pl:Alive() && pl:Team() == TEAM_SPECTATOR then
		
		local vel = GetPlaneVel( pl )
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
		
		SetPlaneVel( pl, vel )
		
		local Velocity = pl:GetAimVector() * vel * 5
		local Target = pl:GetPos() + Velocity * FrameTime()		
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

local Aim = {50,0,0}

function CalcView( ply, origin, angles, fov )
	
	if InGame( ply ) && ply:Alive() then
	
		return {
			origin = origin + angles:Up() * Aim[1] + angles:Forward() * Aim[2] + angles:Right() * Aim[3],
			angles = angles,
			fov = fov	
		}
		
	end

end