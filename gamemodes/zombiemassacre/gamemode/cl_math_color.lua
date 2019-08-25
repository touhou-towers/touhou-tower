function cprint(str)
end

function breakLyrics(lyrics)
	local tab = {}
	for l in string.gmatch(lyrics, "([%w%p]+)") do
		l = string.gsub(l, ",", "")
		l = string.gsub(l, "-", " ")
		table.insert(tab, l)
	end
	return tab
end

function SinBetween(min, max, time)
	local diff = max - min
	local remain = max - diff

	return (((math.sin(time) + 1) / 2) * diff) + remain
end

function CosBetween(min, max, time)
	local diff = max - min
	local remain = max - diff

	return (((math.cos(time) + 1) / 2) * diff) + remain
end

module("colorutil", package.seeall)

function Matches(c1, c2)
	return c1.r == c2.r and c1.g == c2.g and c1.b == c2.b
end

function Smooth(time, alpha)
	time = time or 3

	return Color(
		100 + math.abs(math.sin(-CurTime() * 3.14 * time) * 155),
		100 + math.abs(math.sin(CurTime() * 2.71 * time) * 155),
		100 + math.abs(math.sin(-CurTime() * 6 * time) * 155),
		alpha or 255
	)
end

local CurColorID = 1
local CurrentColor = Color(0, 0, 0)
local NiceColors = {
	Color(255, 0, 0),
	Color(0, 255, 0),
	Color(0, 0, 255),
	Color(0, 255, 255),
	Color(255, 0, 255),
	Color(255, 255, 0)
}

local function GetNextColorID()
	if CurColorID > (#NiceColors - 1) then
		CurColorID = 1
		return CurColorID
	end

	return CurColorID + 1
end

function SmoothTimer()
	local nextColor = NiceColors[self:GetNextColorID()]

	if
		not (math.abs(CurrentColor.r) >= math.abs(nextColor.r) and math.abs(CurrentColor.g) >= math.abs(nextColor.g) and
			math.abs(CurrentColor.b) >= math.abs(nextColor.b))
	 then
		CurrentColor.r = math.Approach(CurrentColor.r, nextColor.r, FrameTime() * 30)
		CurrentColor.g = math.Approach(CurrentColor.g, nextColor.g, FrameTime() * 30)
		CurrentColor.b = math.Approach(CurrentColor.b, nextColor.b, FrameTime() * 30)
	else
		CurColorID = GetNextColorID()
	end

	return CurrentColor
end

function GetRandomColor()
	local rand = math.random(0, 6)
	local color = Color(math.random(125, 255), math.random(125, 255), math.random(125, 255))
	if rand == 1 then
		color = Color(math.random(125, 255), math.random(30, 80), math.random(30, 80))
	elseif rand == 2 then
		color = Color(math.random(30, 80), math.random(125, 255), math.random(30, 80))
	elseif rand == 3 then
		color = Color(math.random(30, 80), math.random(30, 80), math.random(125, 255))
	elseif rand == 4 then
		color = Color(math.random(30, 80), math.random(125, 255), math.random(125, 255))
	elseif rand == 5 then
		color = Color(math.random(125, 255), math.random(30, 80), math.random(125, 255))
	elseif rand == 6 then
		color = Color(math.random(125, 255), math.random(125, 255), math.random(30, 80))
	end

	return color
end

function HSV(h, s, v, ...)
	h = h % 360
	local h1 = math.floor((h / 60) % 6)
	local f = (h / 60) - math.floor(h / 60)
	local p = v * (1 - s)
	local q = v * (1 - (f * s))
	local t = v * (1 - (1 - f) * s)

	local values = {
		{v, t, p},
		{q, v, p},
		{p, v, t},
		{p, q, v},
		{t, p, v},
		{v, p, q}
	}

	local out = values[h1 + 1]

	if arg ~= nil then
		for k, v in pairs(arg) do
			table.insert(out, v)
		end
	end

	return unpack(out)
end

module("math", package.seeall)

function Fit(val, valMin, valMax, outMin, outMax)
	return math.ceil((val - valMin) * (outMax - outMin) / (valMax - valMin) + outMin)
end

function IsBetween(num, min, max)
	return num >= min and num <= max
end
