
-----------------------------------------------------
-- Names of the curves to manage creating tubes for

local CurveNames =

{

	"waterslide_a",

	"waterslide_b"

}



-- Maximum number of tubes to be created per curve

local MaxTubesPerCurve = 3





local function GetStartPosAngle(curvename)

	local curve = STORED_CURVES[curvename]



	-- WELLLLP this shouldn't happen

	if not curve then return Vector(), Angle() end



	return curve.Points[1].Pos, curve.Points[1].Angle

end





-- If we're on the client, all we'll do is draw some ghost tubes

if CLIENT then

	local TubeModel = Model( "models/gmod_tower/pooltube.mdl")

	local GhostModels = {}

	local NextThink = 0


	hook.Add("Think", "GMTWaterslideGhostManager", function()

		-- We don't need to check very often

		if RealTime() < NextThink then return end

		NextThink = RealTime() + 5



		-- Only bother updating when they're in the boardwalk

		--local plyLoc = Location.Get(LocalPlayer():Location())

		--if not plyLoc or plyLoc.Group ~= "boardwalk" then return end



		-- Go through each curvename, checking its subsequent ghost models

		for _, v in pairs(CurveNames) do



			-- Make sure the curve is valid

			if not STORED_CURVES[v] then continue end



			-- Query soundscape worldsounds for the top and bottom

			--QuerySoundscape(v, true )

			--QuerySoundscape(v, false )



			local pos, ang = GetStartPosAngle(v)



			-- If it's now invalid, recreate the model

			if not IsValid(GhostModels[v]) then



				local mdl = ClientsideModel(TubeModel)

				mdl:SetPos(pos)

				mdl:SetAngles(ang)

				mdl:SetRenderMode(RENDERMODE_GLOW)

				mdl:SetColor(Color(255,255,255,150))

				mdl:SetModelScale(0.90,0)



				-- Store it so we don't recreate it if don't have to

				GhostModels[v] = mdl

			end

		end

	end )



	-- Go no further, it's serverside time

	return

end



local Tubes = {}



-- Create a unique table for each curve to manage

for _, v in pairs(CurveNames) do



	-- Make sure there's an actual matching curve

	if not STORED_CURVES[v] then continue end



	-- Create a useful storage table

	Tubes[v] = {}

	Tubes[v].CreatedTubes = {}

end



-- Clean the table of removed pooltubes

local function CleanPoolTubes(tbl)

	for i=#tbl.CreatedTubes, 1, -1 do

		if not IsValid(tbl.CreatedTubes[i]) then

			table.remove(tbl.CreatedTubes, i)

		end

	end

end



-- Find any available tube to use, as opposed to creating a new one

local function FindOpenTube(curvename)

	for _, v in pairs( ents.FindByClass("gmt_pooltube")) do



		-- Has a matching curve and nobody's riding it

		if IsValid(v) and v.SlideCurveName == curvename and not IsValid(v:GetOwner()) then

			return v

		end

	end

end



-- General function for managing pool tubes, their positions, and queueing them up

local function ManagePoolTubes(tbl, curvename)

	-- If a tube is sliding or we've hit the max entities, do nothing

	if IsValid(tbl.SlidingTube) then



		-- Check if the're still on a curve

		if tbl.SlidingTube.CurrentCurve == nil then

			tbl.SlidingTube = nil

		end



		-- There's nothing further here to do

		return

	end



	-- If we've got a valid queued tube, check if its state changes

	if IsValid(tbl.QueuedTube) then

		local tube = tbl.QueuedTube

		--if IsValid(tube:GetOwner() ) or tube.CurrentCurve ~= nil then



			-- Set the slide curve

			tube:SetSlideCurve(STORED_CURVES[curvename])

			tube:SetMoveType(MOVETYPE_VPHYSICS) -- Unfreeze it



			tbl.SlidingTube = tube

			tbl.QueuedTube = nil

		--end



		return

	end



		-- Prioritize existing tubes before creating one

	local tube = FindOpenTube(curvename)



	-- Only create a new tube if we're below the limit

	if not IsValid(tube) and #tbl.CreatedTubes < MaxTubesPerCurve then



		print("No valid tubes found, but under limit. Creating a new one")



		-- If all else fails, create a new tube

		tube = ents.Create("gmt_pooltube")

		tube:Spawn()

		tube:Activate()

		--tube:SetPos(GetStartPosAngle())



		-- We're overwriting this for our own slide management so

		tube.NoReset = true



		-- You're with us now

		tube.SlideCurveName = curvename

		table.insert(tbl.CreatedTubes, tube)

	end



	if not IsValid(tube) then return end



	-- Get the position of the very first node

	local pos, ang = GetStartPosAngle(curvename)



	-- Set the pos/angles to right where the start of the curve is

	tube:SetPos(pos)

	tube:SetAngles(ang)

	tube:SetMoveType(MOVETYPE_NONE) -- Freeze it while it's 'queued'



	-- Store that shit

	tbl.QueuedTube = tube

end



-- sorry foohy, I don't want your STUPID tubes on flatgrass

if not string.find(game.GetMap(), "gmt_lobby2") then

	return

end



local NextThink = 0

hook.Add("Think", "GMTPoolTubeWaterslideManager", function()

	if CurTime() < NextThink then return end

	NextThink = CurTime() + 0.20



	for curve, tbl in pairs(Tubes) do

		-- First clean up the list of pooltubes

		CleanPoolTubes(tbl)



		-- Now decide to idle, create an entity, or move an entity

		ManagePoolTubes(tbl, curve)

	end

end )
