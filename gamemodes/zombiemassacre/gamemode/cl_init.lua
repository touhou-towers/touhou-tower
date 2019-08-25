include("includes/modules/GTowerModels.lua")
-----------------------------------------------------
include("cl_hud.lua")
--include( "cl_hudchat.lua" )
include("cl_hudmessage.lua")
include("cl_input.lua")
include("cl_radar.lua")
include("cl_modelpanel.lua")
include("cl_classchooser.lua")
include("cl_math.lua")
include("cl_math_color.lua")
include("cl_music.lua")
include("cl_util.lua")

include("dropmanager/cl_init.lua")

include("postprocess/init.lua")
include("sh_movement.lua")

include("sh_classmanager.lua")

include("shared.lua")
include("sh_player_meta.lua")

include("gmt/cl_scoreboard.lua")

ConVarDisplayHUD = CreateClientConVar("gmt_zm_hud", 1, true)
ConVarDLights = CreateClientConVar("gmt_zm_dlights", 2, true)
ConVarCameraSpeed = CreateClientConVar("gmt_zm_cameraspeed", 1, true)
ConVarDrawBlur = CreateClientConVar("gmt_zm_blur", 1, true)
ConVarDrawNotes = CreateClientConVar("gmt_zm_notes", 1, true)

-- Precache the particle system
game.AddParticles("particles/explodey.pcf")
PrecacheParticleSystem("dusty_explosion_rockets")

Cursor2D = surface.GetTextureID("cursor/cursor_default")

function GM:ShouldDrawLocalPlayer()
	return true
end

function GM:Think()
	gui.EnableScreenClicker(true)

	self:FadeBrushes()
	self:FadeRagdolls()
	self:HandleCountdown()
end

local FadeEnts = {
	"func_brush",
	"prop_fading"
	-- "prop_dynamic_override",
	-- "prop_dynamic",
}

local function IsFadeable(ent)
	for _, class in pairs(FadeEnts) do
		if ent:GetClass() == class then
			return true
		end
	end

	return false
end

FadeableEnts = {}

function GM:SetupFadebles()
	for _, ent in pairs(ents.GetAll()) do
		if IsFadeable(ent) then
			table.insert(FadeableEnts, ent)
		end
	end
end

hook.Add(
	"InitPostEntity",
	"UpdateFadeables",
	function()
		GAMEMODE:SetupFadebles()
	end
)

function GM:FadeBrushes()
	-- Preform fade
	for _, ent in pairs(FadeableEnts) do
		if IsFadeable(ent) then
			if not ent.Alpha then
				ent.Alpha = 255
			end

			if ent.ShouldFade then
				ent.Alpha = math.Approach(ent.Alpha, 150, 4)
			else
				ent.Alpha = math.Approach(ent.Alpha, 255, 4)
			end

			ent:SetColor(Color(255, 255, 255, ent.Alpha))
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent.ShouldFade = false
		end
	end

	-- Fade ents above cursor
	if LocalPlayer():Alive() then
		local cursorvec = LocalPlayer():GetAimVector()
		local origin = LastCameraPosition
		local trace = util.TraceLine({start = origin, endpos = origin + cursorvec * 9000})

		if IsValid(trace.Entity) and IsFadeable(trace.Entity) and trace.Entity:GetPos().z > LocalPlayer():GetPos().z then
			trace.Entity.ShouldFade = true
		end
	end

	-- Fade ents above player
	local size = 50
	local pos = LocalPlayer():GetPos()
	local entsabove = ents.FindInBox(pos + Vector(-size, -size, 64), pos + Vector(size, size, 1000))

	-- Fade all when dead
	if not LocalPlayer():Alive() then
		entsabove = FadeableEnts
	end

	-- Mark brushes for fade
	for _, ent in pairs(entsabove) do
		if IsFadeable(ent) then
			ent.ShouldFade = true
		end
	end
end

function GM:FadeRagdolls()
	for k, v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
		if v.Time and v.Time < CurTime() then
			v:SetColor(Color(255, 255, 255, v.Alpha))
			v:SetRenderMode(RENDERMODE_TRANSALPHA)
			v.Alpha = math.Approach(v.Alpha, 0, -4)

			if v.Alpha <= 0 then
				v:Remove()
			end
		elseif not v.Time then
			v.Time = CurTime() + 10
			v.Alpha = 255
		end
	end
end

TimeLeftUsed = {}

function GM:HandleCountdown()
	if self:GetState() ~= STATE_PLAYING then
		return
	end

	local endTime = self:GetTimeLeft()
	local timeLeft = endTime - 1 -- adjusting for hud message sliding

	if timeLeft <= 0 then
		timeLeft = 0
	end
	timeLeft = math.Round(timeLeft)

	if TimeLeftUsed[timeLeft] ~= nil then
		return
	end

	if timeLeft == 15 then
		-- 15 seconds remaining
		HUDMessage(HudMessages[1], 5, nil, true)
		TimeLeftUsed[timeLeft] = timeLeft
	elseif timeLeft <= 5 and timeLeft > 0 then
		local msgIndex = 2 + (5 - timeLeft)

		HUDMessage(HudMessages[msgIndex], 0.7, nil, true)

		TimeLeftUsed[timeLeft] = timeLeft
	end
end

function GetCircleTable(id, perc, InBound, OutBound, amt, spread, offsetX, offsetY)
	local angbegin = math.rad(id * (360 / amt))
	local angend = angbegin + math.rad((360 / amt) - spread) * perc

	if not offsetX then
		offsetX = 0
	end
	if not offsetY then
		offsetY = 0
	end

	return {
		{
			["x"] = offsetX + math.cos(angbegin) * OutBound,
			["y"] = offsetY + math.sin(angbegin) * OutBound,
			["u"] = 0,
			["v"] = 0
		},
		{
			["x"] = offsetX + math.cos(angend) * OutBound,
			["y"] = offsetY + math.sin(angend) * OutBound,
			["u"] = 1,
			["v"] = 1
		},
		{
			["x"] = offsetX + math.cos(angend) * InBound,
			["y"] = offsetY + math.sin(angend) * InBound,
			["u"] = 0,
			["v"] = 1
		},
		{
			["x"] = offsetX + math.cos(angbegin) * InBound,
			["y"] = offsetY + math.sin(angbegin) * InBound,
			["u"] = 1,
			["v"] = 0
		}
	}
end

function GM:DrawWorldHealth(ply)
	if not ply:Alive() then
		return
	end

	local alpha = 255

	if ply ~= LocalPlayer() then
		alpha = 100
	end

	local pos = ply:LocalToWorld(Vector(0, 0, 2))
	local ang = Angle(0, 90, 0) -- ply:LocalToWorldAngles( Angle(0,90,0) )

	local health = ply:Health()
	local maxHealth = ply:MaxHealth()

	local HealthPolys = 12
	local HealthPerc = health / maxHealth * HealthPolys
	local HealthCircle = 90

	local wide = 20

	local colorPerc = math.Clamp((health / maxHealth) * 255, 0, 255)

	if (health / maxHealth) <= .25 then
		alpha = SinBetween(50, 255, RealTime() * 15)
		wide = SinBetween(20, 30, RealTime() * 15)
	end

	cam.Start3D2D(pos, ang, 0.25)
	surface.SetTexture(0)
	surface.SetDrawColor(255 - (colorPerc * (health / maxHealth)), colorPerc, 0, alpha)

	for i = 1, HealthPerc, 1 do
		surface.DrawPoly(GetCircleTable(i, 1.0, HealthCircle, HealthCircle + wide, HealthPolys, 5))
	end

	surface.DrawPoly(
		GetCircleTable(
			math.ceil(HealthPerc),
			HealthPerc - math.floor(HealthPerc),
			HealthCircle,
			HealthCircle + wide,
			HealthPolys,
			5
		)
	)
	cam.End3D2D()
end

function GM:DrawWorldCombo(ply)
	if not ply:Alive() then
		return
	end

	local pos = ply:LocalToWorld(Vector(0, 0, 2))
	local ang = Angle(0, 90, 0) -- ply:LocalToWorldAngles( Angle(0,90,0) )

	local combo = ply:GetNWInt("Combo", 0)
	local maxCombo = 5

	if ply:GetNWInt("IsPowerCombo") then
		combo = maxCombo
	end

	local ComboPolys = 16
	local ComboPerc = combo / 5 * ComboPolys
	local ComboCircle = 50

	cam.Start3D2D(pos, ang, 0.25)
	surface.SetTexture(0)

	local colorPerc = math.Clamp(50 + (combo / maxCombo) * 200, 50, 200)
	local color = Color(235, colorPerc, 35)

	if ply:GetNWInt("IsPowerCombo") then
		color = Color(math.random(200, 255), math.random(50, 255), math.random(50, 255))
	end

	surface.SetDrawColor(color.r, color.g, color.b, 255)

	for i = 1, ComboPerc, 1 do
		surface.DrawPoly(GetCircleTable(i, 1.0, ComboCircle, ComboCircle + 20, ComboPolys, 0))
	end

	surface.DrawPoly(
		GetCircleTable(math.ceil(ComboPerc), ComboPerc - math.floor(ComboPerc), ComboCircle, ComboCircle + 20, ComboPolys, 0)
	)
	cam.End3D2D()
end

function GM:DrawWorldPowerup(ent, curdelay, removedelay, offset)
	if not removedelay then
		return
	end
	if not offset then
		offset = 10
	end

	local pos = ent:LocalToWorld(Vector(0, 0, offset))
	local ang = Angle(0, 90, 0)

	local time = curdelay - CurTime()
	local percent = time / removedelay

	local PowerupPolys = 16
	local PowerupPerc = percent * PowerupPolys
	local PowerupCircle = 60

	cam.Start3D2D(pos, ang, 0.25)
	surface.SetTexture(0)
	surface.SetDrawColor(Color(math.random(200, 255), math.random(200, 255), math.random(200, 255), 50 * percent))

	for i = 1, PowerupPerc, 1 do
		surface.DrawPoly(GetCircleTable(i, 1.0, PowerupCircle, PowerupCircle + 20, PowerupPolys, 0))
	end

	surface.DrawPoly(
		GetCircleTable(
			math.ceil(PowerupPerc),
			PowerupPerc - math.floor(PowerupPerc),
			PowerupCircle,
			PowerupCircle + 20,
			PowerupPolys,
			0
		)
	)
	cam.End3D2D()
end

local MaterialPower = Material("models/effects/comball_tape")
local MaterialSpawn = Material("models/props_combine/portalball001_sheet")

function GM:PostDrawTranslucentRenderables()
	if not self:IsPlaying() then
		return
	end

	for _, v in pairs(player.GetAll()) do
		self:DrawWorldHealth(v)
		self:DrawWorldCombo(v)
	end
end

function GM:DrawModelMaterial(ent, scale, material)
	-- start stencil
	render.SetStencilEnable(true)

	-- render the model normally, and into the stencil buffer
	render.ClearStencil()
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilWriteMask(1)
	render.SetStencilReferenceValue(1)

	-- render model

	-- render the outline everywhere the model isn't
	render.SetStencilReferenceValue(0)
	render.SetStencilTestMask(1)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)

	-- render black model
	render.SuppressEngineLighting(true)
	render.MaterialOverride(material)
	-- render model
	ent:SetModelScale(scale, 0)
	ent:SetupBones()
	ent:DrawModel()

	-- clear
	render.MaterialOverride()
	render.SuppressEngineLighting(false)

	-- end stencil buffer
	render.SetStencilEnable(false)
end

usermessage.Hook(
	"ZMShowScores",
	function(um)
		local display = um:ReadBool()

		TimeLeftUsed = {}

		if display == true then
			print("YES")
			--RunConsoleCommand( "gmt_showscores", "1" )
			RunConsoleCommand("-attack")
		else
			print("NO")
			--RunConsoleCommand( "gmt_showscores", "0" )
			RunConsoleCommand("r_cleardecals")
		end
	end
)

usermessage.Hook(
	"ZMShowUpgradeScreen",
	function(um)
		local display = um:ReadBool()

		if display == true then
			ClassSelection.Open()
		else
			ClassSelection.Close()
		end
	end
)
