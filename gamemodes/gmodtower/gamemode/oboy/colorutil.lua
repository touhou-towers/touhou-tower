
local math = math
local Color = Color
local HSVToColor = HSVToColor
local RealTime = RealTime 
local FrameTime = FrameTime

module( "colorutil" )

function Matches( c1, c2 )
	return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b
end

function Smooth( time, alpha )

	time = time or 3

	return Color( 
			100 + math.abs( math.sin( -RealTime() * 3.14 * time ) * 155 ),
			100 + math.abs( math.sin( RealTime()  * 2.71	* time ) * 155 ),
			100 + math.abs( math.sin( -RealTime() * 6 	* time ) * 155 ),
			alpha or 255 )

end

local CurColorID = 1
local CurrentColor = Color( 0, 0, 0 )
local NiceColors = {
	Color( 255, 0, 0 ),
	Color( 0, 255, 0 ),
	Color( 0, 0, 255 ),
	Color( 0, 255, 255 ),
	Color( 255, 0, 255 ),
	Color( 255, 255, 0 ),
}

local function GetNextColorID()

	if CurColorID > ( #NiceColors - 1 ) then
		CurColorID = 1
		return CurColorID
	end

	return CurColorID + 1

end

function SmoothTimer()

	local nextColor = NiceColors[ self:GetNextColorID() ]

	if !( math.abs( CurrentColor.r ) >= math.abs( nextColor.r ) &&
	   math.abs( CurrentColor.g ) >= math.abs( nextColor.g ) &&
	   math.abs( CurrentColor.b ) >= math.abs( nextColor.b ) ) then

		CurrentColor.r = math.Approach( CurrentColor.r, nextColor.r, FrameTime() * 30 )
		CurrentColor.g = math.Approach( CurrentColor.g, nextColor.g, FrameTime() * 30 )
		CurrentColor.b = math.Approach( CurrentColor.b, nextColor.b, FrameTime() * 30 )

	else
		CurColorID = GetNextColorID()
	end

	return CurrentColor

end

function GetRandomColor()

	local rand = math.random( 0, 6 )
	local color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	if rand == 1 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 30, 80 ) )
	elseif rand == 2 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	elseif rand == 3 then
		color = Color( math.random( 30, 80 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 4 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	elseif rand == 5 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 6 then
		color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	end

	return color

end

function TweenColor(a, b, coef, alpha)

	return Color(
		a.r + (b.r - a.r) * coef,
		a.g + (b.g - a.g) * coef,
		a.b + (b.b - a.b) * coef,
		alpha
	)

end

function Rainbow( speed, offset, saturation, value )
	return HSVToColor( ( RealTime() * (speed or 50) % 360 ) + ( offset or 0 ),
		saturation or 1, value or 1 )
end

function Brighten( color, ratio, alpha )
	return Color( color.r * ratio, color.g * ratio, color.b * ratio, alpha or color.a )
end