

-----------------------------------------------------
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