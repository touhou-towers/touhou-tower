
-----------------------------------------------------
ENT.Base 			= "base_anim"
ENT.Type 			= "vehicle"
ENT.Model 			= Model( "models/gmod_tower/kart/kart_frame.mdl" )
ENT.ModelSmall		= Model( "models/gmod_tower/kart/kart_frame_small.mdl" )
ENT.FrontWheelModel = Model( "models/gmod_tower/kart/kart_frontwheel.mdl" )
ENT.BackWheelModel 	= Model( "models/gmod_tower/kart/kart_backwheel.mdl" )

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ApproachSupport = function( cur, target, TarMulti )
	return SpecialApproach( cur , target, (math.abs( target - cur ) + 1) * (TarMulti or 1) * FrameTime() )
end

ApproachSupport2 = function ( cur, target, TarMulti )
	return math.Approach( cur , target, (math.abs( target - cur ) + 1) * (TarMulti or 1) * FrameTime() )
end

function SpecialApproach(cur, target, inc)

	if (cur < target) then

		return math.Clamp( math.ceil( cur + inc ), cur, target )

	elseif (cur > target) then

		return math.Clamp( math.floor( cur - inc ) , target, cur )

	end

	return target

end

EPSILON = 0.001

// Returns a CurTime-based sin expression, sin( time / divider ) * mul
function SinTime( divider, mul )
	return math.sin( CurTime() / divider ) * mul
end

function SinBetween( min, max, time )

	local diff = max - min
	local remain = max - diff

	return ( ( ( math.sin( time ) + 1 ) / 2 ) * diff ) + remain

end

function CosBetween( min, max, time )

	local diff = max - min
	local remain = max - diff

	return ( ( ( math.cos( time ) + 1 ) / 2 ) * diff ) + remain

end


module( "math", package.seeall )

// Returns the approximate "fitted" number based on linear regression.
function Fit( val, valMin, valMax, outMin, outMax )
	return ( val - valMin ) * ( outMax - outMin ) / ( valMax - valMin ) + outMin
end

// Returns if a value has gone beyond the maximum value.
function IsBeyond( val, max )
	return ( val % max ) == 0
end

// Returns if a number is between two numbers.
function IsBetween( num, min, max )
	return num >= min && num <= max
end

//Returns an eased value between two numbers.
function Ease( origin, new, speed )
	return ( origin - new ) / speed
end

// Returns the average of an amount of numbers of a table
function Average( nums )

	if type( nums ) != "table" then return end

	local total = #nums
	local sum = 0

	for i=0, total do
		sum = sum + tonumber( nums[i] )
	end

	return sum / total

end

-- Elapsed animation ticker
function Ticker( duration )
	setmetatable({
		start = RealTime(),
		duration = duration,
	},
	{
		__index = function( self, k )
			if k == "elapsed" then return math.min( RealTime() - self.start, self.duration ) end
			if k == "fraction" then return self.elapsed / self.duration end
			if k == "inv_fraction" then return 1 - self.fraction end
			return rawget( self, k )
		end
	})
end

-- Ceil the given number to the largest power of two
function CeilPower2(n)
	return math.pow(2, math.ceil(math.log(n) / math.log(2)))
end

 function ScreenRadialClamp(x,y,padding)

	local w, h = ScrW(), ScrH()
	local ratio = w / h

	-- Default padding is 10% of the screen height
	padding = padding or h * 0.1

	-- Radius of width and height of screen
	-- Equivalent to the center of the screen
	local rx, ry = w / 2, h / 2

	-- Vector to given point w/ equalize ratio
	local targetx, targety = x - rx, ratio * (y - ry)

	-- Angle to target coordinate (in radians)
	local ang = math.atan2( targety, targetx )

	-- Find maximum point on screen given the angle
	local clampx, clampy =
		(rx - padding) * math.cos(ang),
		(ry - padding) * math.sin(ang) * ratio

	-- If our clamped vector is smaller than the target vector
	-- we will return the clamped vector
	local targetmag = math.sqrt( targetx^2 + targety^2 )
	local clampmag = math.sqrt( clampx^2 + clampy^2 )

	if targetmag > clampmag then
		return clampx + rx, clampy * 1/ratio + ry, true
	else
		return x, y, false
	end

end

function Wrap( a, min, max )

	min = min or 0
	max = max or 1
	return math.fmod(a, ( max - min ) ) + min

end

function Rotate(x, y, angle)

	local rx = x * -math.cos(angle) + y * math.sin(angle)
	local ry = x * math.sin(angle) + y * math.cos(angle)
	return rx,ry

end

function ProjectVector( a, b )
	local inv_denom = 1.0 / b:Dot(b)
	local d = b:Dot(a) * inv_denom
	return a - (b * inv_denom) * d
end

local _v0 = {}
local _v1 = {}
function PerpendicularVector( v )
	local pos = 0
	local len = 1

	_v0[1] = v.x
	_v0[2] = v.y
	_v0[3] = v.z

	_v1[1] = 0
	_v1[2] = 0
	_v1[3] = 0

	for i=1, 3 do
		local d = math.abs( _v0[i] )
		if d < len then
			pos = i
			len = d
		end
	end

	_v1[pos] = 1.0
	local v = ProjectVector(Vector(_v1[1], _v1[2], _v1[3]), v) v:Normalize()
	return v
end

function SolveVertexWinding( verts, normal )

	local center = Vector(0,0,0)
	local size = #verts
	if size < 3 then return end

	for i=1, size do center = center + verts[i].pos end
	center = center / size

	local up = (verts[1].pos - center) up:Normalize()
	local right = normal:Cross(up)

	table.sort(verts, function(v0, v1)

		local offset0 = v0.pos - center
		local offset1 = v1.pos - center

		local x0 = offset0:Dot(right)
		local y0 = offset0:Dot(up)

		local x1 = offset1:Dot(right)
		local y1 = offset1:Dot(up)

		return math.atan2(y0,x0) > math.atan2(y1,x1)

	end)

end

function PolysToTriangles( verts )
	local out = {}
	for i=2, #verts-1 do
		table.insert(out, verts[i])
		table.insert(out, verts[1])
		table.insert(out, verts[i+1])
	end

	return out
end

SafeMaterials = { // Materials that are safe for the kart to be on
	"GMOD_TOWER/KARTRACER/LIFELESSRACEWAY/RACETRACK",
	"GMOD_TOWER/KARTRACER/DESERT/WOOD_PLANKS01"
}

DirtMaterials = { // Materials that slow down the kart

}

GrassMaterials = { // Materials that slow down the kart
	"GMOD_TOWER/COMMON/GRASS",
	"GMOD_TOWER/KARTRACER/LIFELESSRACEWAY/LGRASS",
}

SandMaterials = { // Materials that slow down the kart
	"DEV/VALUESAND50",
}

LavaMaterials = { // Materials that slow down and kill the kart

}

BoostMaterials = { // Materials that speed up the kart
	"GMOD_TOWER/BALLS/MAXIMUMSPEED",
	"GMOD_TOWER/KARTRACER/RAVE/SK_BOOST_PINK",
	"maps/gmt_sk_rave/gmod_tower/kartracer/rave/sk_boost_pink_-5049_9856_-512"
}

StickMaterials = { // Materials that maintain its own surface gravity
	"DEV/DEV_MEASUREGENERIC01B",
	"GMOD_TOWER/KARTRACER/TRACK/ROAD7",
	"GMOD_TOWER/KARTRACER/LIFELESSRACEWAY/RACETRACK_GRAV",
	"GMOD_TOWER/KARTRACER/LIFELESSRACEWAY/TUNNELWALLSTOP_GRAV",
	"GMOD_TOWER/KARTRACER/TRACK/ROADGRAVITY",
	"GMOD_TOWER/KARTRACER/TRACK/GRAVITY",
	"GMOD_TOWER/KARTRACER/DESERT/WOOD_PLANKS01_GRAVITY",
	"GMOD_TOWER/KARTRACER/RAVE/GLITTER_TRACK",
	"maps/gmt_sk_rave/gmod_tower/kartracer/rave/glitter_track_-5488_10736_-694"
	//"DEV/DEV_MEASUREWALL01A"
}

function ENT:GetKart()

	return self:GetOwner():GetKart()

end



function ENT:IsValidOwner()

	return IsValid( self:GetOwner() )

end

ENT.Wheels = {
	{
		Model = "frontwheel",
		Att = "wheel_fr",
		Ang = 0,
		Extrude = 1,
	},
	{
		Model = "frontwheel",
		Att = "wheel_fl",
		Ang = 180,
		Extrude = -1,
	},
	{
		Model = "backwheel",
		Att = "wheel_rr",
		Ang = 0,
		Extrude = 1,
	},
	{
		Model = "backwheel",
		Att = "wheel_rl",
		Ang = 180,
		Extrude = -1,
	}
}
ENT.Settings = {
	//Key = {Value, Min, Max, Mod}
	FrictionFactor = { 300, 0, 300 },
	FrictionRightFactor = { 200, 0, 500 },
	PowerForward = { 250, 0, 800 },
	PowerBackwards = { -100, -800, 0 },
	TurnPower = { 130, 0, 150 },
	TurnFricton = { 1, 0.01, 2 },

	MaxVel = { 500, 1, 2000 },
	MaxBoostVel = { 500, 1, 2000 },
	MaxAngVel = { 300, 0.01, 500 },

	DriftingFactor = { .15, 0, 5 },
	DriftingJumpPower = { 1.8, 0, 25 },
	DriftingYawPower = { 0.25, 0, 5 },
	DriftingTurnFactor = { 5, 0, 600 },

	// Not from the latest Source Karts, only used in the old base. Added for compatibility.
	// Altered cause the originals were way too high. (They still are)
	JumpPower = { 5, 0, 10000 },
	JumpWaitTime = { 1, 0, 5 },
	UpwardForce = { 600, -300, 600 }

	// Originals, once again, not used in the final Source Karts.
	/*
	JumpPower = { 300, 0, 10000 },
	JumpWaitTime = { 1, 0, 5 },
	UpwardForce = { 180, -300, 600 }
	*/
}
ENT.BattleSettings = {
	//Key = {Value, Min, Max, Mod}
	FrictionFactor = { 300, 0, 300 },
	FrictionRightFactor = { 500, 0, 500 },
	PowerForward = { 500, 0, 800 },
	PowerBackwards = { -500, -800, 0 },
	TurnPower = { 150, 0, 150 },
	TurnFricton = { 1.58, 0.01, 2 },
	MaxVel = { 500, 1, 2000 },
	MaxBoostVel = { 1000, 1, 2000 },
	MaxAngVel = { 300, 0.01, 500 },

	DriftingFactor = { 4.17, 0, 5 },

	DriftingJumpPower = { 12.8, 0, 25 },

	DriftingYawPower = { 1.54, 0, 5 },

	DriftingTurnFactor = { 10, 0, 600 },

}
ENT.DriftMinimum = .25
ENT.DriftLevels = {
	1.15,
	2,
	3,
}
function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "TurnAngleNet" )
	self:NetworkVar( "Int", 1, "DriftStart" )
	self:NetworkVar( "Bool", 1, "IsEngineOn" )
	self:NetworkVar( "Bool", 0, "IsDrifting" )
	self:NetworkVar( "Bool", 2, "IsInvincible" )
	//self:NetworkVar( "Bool", 2, "IsDriftReady" )
	self:NetworkVar( "Bool", 3, "IsBoosting" )
	self:NetworkVar( "Bool", 4, "IsGhost" )
end

function ENT:IsGhost()
	return self:GetIsGhost()
end

function ENT:Initialize()
    self:SetCustomCollisionCheck( true )
end

function ENT:GetDownTrace( origin, mask, box )
	local origin = origin or self:GetPos()
	local filtered = table.Add( ents.FindByClass( "sk_kart" ), ents.FindByClass( "sk_wheel" ) )
	--filtered = table.Add( filtered, ents.FindByClass( "sk_item*" ) )
	if box then
		return util.TraceHull( {
			start = origin,
			endpos = origin + self:GetUp() * -32,
			mins = Vector( -box, -box, -box ),
			maxs = Vector( box, box, box ),
			filter = filtered,
			mask = mask
		} )
	else
		return util.TraceLine( {
			start = origin,
			endpos = origin + self:GetUp() * -32,
			filter = filtered,
			mask = mask
		} )
	end
end
function ENT:GetUpTrace( origin, mask )
	local origin = origin or self:GetPos()
	local filtered = table.Add( ents.FindByClass( "sk_kart" ), ents.FindByClass( "sk_wheel" ) )
	--filtered = table.Add( filtered, ents.FindByClass( "sk_item*" ) )
	return util.TraceLine( {
		start = origin,
		endpos = origin + self:GetUp() * 32,
		filter = filtered,
		mask = mask
	} )
end
function ENT:HitWorld( trace )
	if !trace then return false end
	return trace.HitWorld || ( IsValid( trace.Entity ) && ( trace.Entity:GetClass() == "func_brush" || trace.Entity:GetClass() == "func_movelinear" ) )
end
function ENT:IsOnWater()
	local wtrace = self:GetDownTrace( nil, MASK_WATER )
	return wtrace.Hit, wtrace.HitPos, wtrace.HitNormal
end
function ENT:GetTraction( trace )
	// == SPECIAL CASES ==
	// Handle on water
	local water, whitpos = self:IsOnWater()
	if water then
		return .1, "water", true
	end
	// Handle spinning... yeah this is kinda a hack BUT WHATEVER
	/*if self.Spinning && self.Spinning > CurTime() then
		return 1.6, "spinning", true
	end*/
	// == TRACE CASES ==
	trace = trace or self:GetDownTrace()
	local hitTexture = trace.HitTexture
	local matType = trace.MatType
	// Handle grass
	if table.HasValue( GrassMaterials, hitTexture ) || matType == MAT_DIRT then
		return .5, "grass", true
	end
	// Handle dirt
	if table.HasValue( DirtMaterials, hitTexture ) || matType == MAT_SLOSH then
		return .8, "dirt", true
	end
	// Handle sand
	if table.HasValue( SandMaterials, hitTexture ) || matType == MAT_SAND then
		return .9, "sand", true
	end
	// Handle lava
	if table.HasValue( LavaMaterials, hitTexture ) || matType == MAT_FLESH then
		return 1.1, "lava", true
	end
	// Handle boost
	if table.HasValue( BoostMaterials, hitTexture ) || matType == MAT_COMPUTER || string.StartWith( hitTexture, "maps/gmt_sk_rave/gmod_tower/kartracer/rave/sk_boost_pink" ) then
		return .4, "boost", false
	end

	// Handle surface
	if table.HasValue( StickMaterials, hitTexture ) or string.StartWith( hitTexture, "maps/gmt_sk_rave/gmod_tower/kartracer/rave/glitter" ) or string.StartWith( hitTexture, "maps/gmt_sk_rave/gmod_tower/kartracer/rave/sk_boost_blue" ) then
		return .15, "surface", false
	end

	if hitTexture == "**displacement**" then

		if game.GetMap() == "gmt_sk_rave" then
			return .15, "surface", false
		end

		return .8, "dirt", true
	end
	return .2, "normal", false
end

concommand.Add( "sk_ground", function( ply, cmd, args )
	if !ply:IsAdmin() then return end
	local kart = ply:GetKart()
	if IsValid( kart ) then
		local trace = kart:GetDownTrace()
		local hitTexture = trace.HitTexture
		local hitType = trace.MatType
		local Traction, MatType = kart:GetTraction()
		ply:ChatPrint( tostring( hitTexture ) )
		ply:ChatPrint( tostring( hitType ) )
		if MatType then
			ply:ChatPrint( MatType )
		end
	end
end )
