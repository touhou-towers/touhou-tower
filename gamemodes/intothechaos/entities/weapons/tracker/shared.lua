if SERVER then	AddCSLuaFile( "shared.lua" )end
SWEP.Base				= "weapon_base"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.PrintName 			= "Paranormal Detector"
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.ViewModel			= "models/weapons/v_alyxgun.mdl"
SWEP.WorldModel 		= "models/weapons/w_pvp_ragingb.mdl"
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			= "none"

if CLIENT then
  local entityToTrack = "ghost_*"


local params = {
	["$basetexture"] = "color/white",
	["$additive"] = 0,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
}
local whiteTex = CreateMaterial("White01", "UnlitGeneric", params)
local refractTex = Material("room209/radar_refract")
local staticTex = Material("room209/static")
local CenterRing = Material( "room209/ui_ring" )
local Circle = Material( "room209/white_circle" )

surface.CreateFont( "LabelFont", { font = "Digital-7 Mono", size = 24, weight = 100 } )
surface.CreateFont( "LabelSmallFont", { font = "Digital-7 Mono", size = 12, weight = 50, antialias = false } )

local sweep = Sound( "room209/radar_sweep.wav" )
local sweeped = false

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
end

function SWEP:CanSecondaryAttack()
    return true
end

local function GetBatteryPercent()

	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid( wep ) and wep:GetClass() == "tracker" then
		return LocalPlayer():GetBattery() --wep:GetBatteryPercent()
	end

	return 1

end

local storedLocations = {}
local function DrawPoints( pingloc )

	for k,v in pairs(ents.FindByClass(entityToTrack)) do

		local yaw = ( -LocalPlayer():GetAngles().y - 90 ) * (math.pi / 180)
		local vpos = ( LocalPlayer():GetPos() - v:GetPos() ) / 6.0
		local dist = vpos:Length()

		vpos.z = yaw
		local alpha = (dist + 600 - pingloc) / 600
		if pingloc < dist then
			storedLocations[k] = vpos
			alpha = 0
		else
			vpos = storedLocations[k] or vpos
			storedLocations[k] = vpos
			dist = vpos:Length()
			yaw = vpos.z
		end

		--[[if alpha > .5 then

			if not v.sweeped then
				LocalPlayer():EmitSound(sweep,40)
				v.sweeped = true
			end

		else
			v.sweeped = false
		end]]

		local x = vpos.x * math.cos(yaw) - vpos.y * math.sin(yaw)
		local y = vpos.x * math.sin(yaw) + vpos.y * math.cos(yaw)

		surface.SetDrawColor( 255,255,255,255 * (alpha) )

		surface.SetMaterial( whiteTex )
		surface.DrawTexturedRect(
			x-4,
			-y-4,
			8,
			8 )

		draw.SimpleText(
			string.format("%03.0f", dist * 4),
			"LabelSmallFont",
			x,
			-y + 5,
			Color(255,255,255,255 * alpha),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_LEFT
		)

	end

	surface.SetDrawColor( 255,255,100,255 )
	surface.DrawTexturedRect(
		-4,
		-4,
		8,
		8 )

end

function DrawBattery( x, y, percent )

	local w, h = 34, 16

	surface.SetDrawColor(255,255,255,255)

	if percent <= .2 then

		surface.SetDrawColor(255,0,0,SinBetween(50,255, RealTime() * 20))

	end

	local thickness = 3

	-- Top
	surface.DrawRect( x, y, w, thickness )

	-- Bottom
	surface.DrawRect( x, y + h - thickness, w, thickness )

	-- Left
	surface.DrawRect( x, y + thickness, thickness, h - thickness )

	-- Right
	surface.DrawRect( x + w - thickness, y + thickness, thickness, h - thickness )

	-- Fill
	surface.DrawRect( x + thickness + 1, y + thickness + 1, ( w - ( thickness * 2 ) ) * percent - 2, h - ( thickness * 2 ) - 2 )

	-- Ground
	surface.DrawRect( x + w - thickness, y + thickness, thickness * 2, h - ( thickness * 2 ) )

end

local start = CurTime()
local scanY = 0
local function DrawScreen( w, h )

	local t = (CurTime() - start) * 2
	local sm = -w/2 + math.fmod(t, 4) * w --w/2 + math.cos(t) * w

	if GetBatteryPercent() > 0 then

		-- Sweep noise
		if sm < -140 and sm > -150 then
			if not sweeped then
				LocalPlayer():EmitSound(sweep,40)
				sweeped = true
			end
		end
		if sm > 0 then sweeped = false end

		for k,v in pairs(ents.FindByClass(entityToTrack)) do
			v:DrawModel()
		end

		-- CRT Line
		surface.SetDrawColor( 255,255,255,10 )
		surface.SetMaterial( whiteTex )
		surface.DrawTexturedRect( -w/2, scanY, w, 4 )

		scanY = scanY + 1
		if scanY > h then scanY = -h/2 end

		-- Refract shader
		render.UpdateRefractTexture()
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(refractTex)
		surface.DrawTexturedRect(-w/2, -h/2,w,h)

		-- Background
		surface.SetDrawColor( 0,10,50,80 )
		surface.SetMaterial( whiteTex )
		surface.DrawTexturedRect(
			-w/2,
			-h/2,
			w,
			h )

		-- Center ring
		surface.SetDrawColor( 255,255,255,255 )
		surface.SetMaterial( CenterRing )
		surface.DrawTexturedRect(
			-w/2 - sm,
			-w/2 - sm,
			w + sm * 2,
			w + sm * 2 )

		-- Points

		surface.SetMaterial( Circle )
		surface.SetDrawColor( 255,255,255,255 )
		DrawPoints( sm + w / 2 )

	else

		-- Background
		surface.SetDrawColor( 0,10,50,245 )
		surface.SetMaterial( whiteTex )
		surface.DrawTexturedRect(
			-w/2,
			-h/2,
			w,
			h )

	end

	-- Title
	draw.SimpleText(
		"Paranormal Detector",
		"LabelFont",
		-w/2 + 6,
		-h/2 + h - 24,
		Color(255,255,255,255),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_LEFT
	)

	-- Battery
	DrawBattery( -w/2 + h - 44, -h/2 + h - 28 + 5, GetBatteryPercent() )

	-- Static
	local staticAlpha = 35
	if GetBatteryPercent() <= 0 then staticAlpha = 255 end

	surface.SetDrawColor(255,255,255,staticAlpha)
	surface.SetMaterial(staticTex)
	surface.DrawTexturedRect(-w/2, -h/2,w,h)

	-- Border
	surface.SetDrawColor( 10,20,20,255 )
	surface.SetMaterial( whiteTex )
	surface.DrawTexturedRect( -w/2, -h/2, w, 4 )
	surface.DrawTexturedRect( -w/2, -h/2 + h-4, w, 4 )
	surface.DrawTexturedRect( -w/2, -h/2, 4, h )
	surface.DrawTexturedRect( -w/2 + w-4, -h/2, 4, h )

end

local function DrawStencilScreen( pos, angle )

	if LocalPlayer():InVehicle() then return end

	local scale = 20
	local width = 15
	local height = 15
	local rwidth = width * scale
	local rheight = height * scale

	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilTestMask( 1 )
	render.SetStencilWriteMask( 1 )
	render.SetStencilReferenceValue( 1 )

	cam.Start3D2D( pos, angle, 1 / scale )

		surface.SetDrawColor( 0,0,0,1 )
		surface.SetMaterial( whiteTex )
		surface.DrawTexturedRect(
			-rwidth/2,
			-rheight/2,
			rwidth,rheight )

	cam.End3D2D()

	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	cam.Start3D2D( pos, angle, 1 / scale )

		DrawScreen(rwidth, rheight)

	cam.End3D2D()

	render.SetStencilEnable( false )
end


local LASER = Material( 'cable/redlaser' )
hook.Add("PreDrawViewModel", "screen_vmview", function( viewmodel, client, weapon )

	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid( wep ) and wep:GetClass() != "tracker" then return end

	if client then
		local viewModel = LocalPlayer():GetViewModel()
		return
	end


	local viewModel = LocalPlayer():GetViewModel()
	if not IsValid( viewModel ) then return end
	if viewModel:GetModel() != "models/weapons/v_alyxgun.mdl" then return end
	local attachmentIndex = viewModel:LookupAttachment("muzzle")
	local at = viewModel:GetAttachment( attachmentIndex )

	local pos = Vector(0,0,0)
	local angle = Angle(0,0,0)

	if at then
		pos = at.Pos + at.Ang:Right() * -5 --+ at.Ang:Forward() * -20 + at.Ang:Up() * -5 + at.Ang:Right() * -4
		angle = at.Ang
		--angle:RotateAroundAxis(angle:Forward(), -90)
		angle:RotateAroundAxis(angle:Right(), 90)
	end

	render.DepthRange( 0, 0.1 )
	DrawStencilScreen( pos, angle )


	--print("A: " .. tostring(at.Ang))
	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

end)

hook.Add("PostDrawViewModel", "screen_paint", function( viewmodel, client, weapon )

	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid( wep ) and wep:GetClass() != "tracker" then return end

	render.SetStencilEnable( false )
	render.OverrideDepthEnable( false, false )

	do return end

	local viewModel = LocalPlayer():GetViewModel()
	local attachmentIndex = viewModel:LookupAttachment("muzzle")
	local at = viewModel:GetAttachment( attachmentIndex )
	print("B: " .. tostring(at.Ang))

	local pos = Vector(0,0,0)
	local angle = Angle(0,0,0)

	if at then
		pos = at.Pos --+ at.Ang:Forward() * -20 + at.Ang:Up() * -5 + at.Ang:Right() * -4
		angle = at.Ang
		angle:RotateAroundAxis(angle:Forward(), -90)
		angle:RotateAroundAxis(angle:Right(), 90)
	end

	DrawStencilScreen( pos, angle )
end)
end
