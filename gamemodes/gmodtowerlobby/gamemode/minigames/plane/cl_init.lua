include("shared.lua")

module("minigames.plane", package.seeall )

LocalPlayerInGame = false
ForceAngle = nil

usermessage.Hook("plane", function( um )

	local Id = um:ReadChar()

	if Id == 0 then
		AddHooks()
	elseif Id == 1 then
		RemoveHooks()
	elseif Id == 2 then
		LocalPlayer()._PlaneVelocity = um:ReadFloat()

		if um:ReadBool() == true then
			ForceAngle = um:ReadAngle()
		end

	elseif Id == 3 then

		local Count = um:ReadChar()
		local TotalEarned = um:ReadLong()
		local SortTable = {}

		for i=1, Count do

			local ply = Entity( um:ReadChar() )
			local kills = um:ReadChar()

			if IsValid( ply ) then
				ply._PlaneKills = kills
				table.insert( SortTable, ply )
			end

		end

		table.sort( SortTable, function( a, b )
			return a._PlaneKills < b._PlaneKills
		end )

		Msg("====== Crazy Plane =======\n")
		Msg("Total money generated: " .. TotalEarned .. " GMC.\n")
		Msg("Scoreboard:\n")

		for _, ply in pairs( SortTable ) do
			Msg( "\t" .. ply._PlaneKills .. "|\t" .. ply:GetName() .. "\n" )
		end

		Msg("====== Crazy Plane =======\n")

	end

end )

function GetPlaneVel( ply )
	return ply._PlaneVelocity or 100
end

function SetPlaneVel( ply, vel )
	ply._PlaneVelocity = vel
end

function InGame( ply )
	if ply == LocalPlayer() then
		return LocalPlayerInGame
	end
	for _, ent in ipairs( ents.FindByClass("plane") ) do
		if ent:GetOwner() == ply then
			return true
		end
	end
end

function AddHooks()
	hook.Add("InputMouseApply", "PlaneInputMouseApply", InputMouseApply )
	hook.Add("ShouldDrawLocalPlayer", "PlaneShouldDrawLocalPlayer", ShouldDrawLocalPlayer )

	hook.Add("Move", "PlaneMove", HookPlayerMove )
	--hook.Add("CalcView", "PlaneCalcView", CalcView )
	hook.Add("OpenSideMenu", "PlaneOpenSideMenu", OpenSideMenu )
	hook.Add("ShouldCollide", "PlaneShouldCollide", ShouldCollide )
	hook.Add("CalcMainActivity", "PlaneAnim", HookPlayerAnim )
	_G.GAMEMODE.AddDeathNotice = function() return true end

	LocalPlayerInGame = true
end

function OpenSideMenu()

	local Form = vgui.Create("DForm")

	Form:SetName( "Planes" )

	local Refresh = Form:Button("LEAVE")
	Refresh.DoClick = function() RunConsoleCommand("gmt_planeleave") end

	return Form

end

function RemoveHooks()
	hook.Remove("InputMouseApply", "PlaneInputMouseApply" )
	hook.Remove("ShouldDrawLocalPlayer", "PlaneShouldDrawLocalPlayer" )
	hook.Remove("Move", "PlaneMove" )
	--hook.Remove("CalcView", "PlaneCalcView" )
	hook.Remove("OpenSideMenu", "PlaneOpenSideMenu")
	hook.Remove("ShouldCollide", "PlaneShouldCollide" )
	hook.Remove("CalcMainActivity", "PlaneAnim" )
	_G.GAMEMODE.AddDeathNotice = _G.GAMEMODE.BaseClass.AddDeathNotice

	LocalPlayerInGame = false
end

function InputMouseApply( cmd, x, y, angle )

	if !InGame( LocalPlayer() ) then return end
	if ForceAngle then
		cmd:SetViewAngles( ForceAngle )
		ForceAngle = nil
		return
	end

	angle.roll = math.Approach( angle.roll, 0, angle.roll / 400 )
	angle.yaw = angle.yaw + angle.roll * -0.0025

	local Ang = angle

	local speed = GetPlaneVel( LocalPlayer() )

	local pitchchange = y * 0.02
	local yawchange = x * -0.005
	local rollchange = x * 0.022

	local stalling = 50 - speed
	if ( speed < 50 ) then
		local rate = 1 - (speed / 50)
		pitchchange = pitchchange + (rate ^ 10.0) * 20
	end

	--Ang:Rotate( Angle( pitchchange, yawchange, rollchange ) )

	local Ang = Ang:GetAngles()
	Ang.roll = math.Clamp( Ang.roll, -90, 90 )

	cmd:SetViewAngles( Ang )
	return true

end

function ShouldDrawLocalPlayer( pl )
	if !InGame( LocalPlayer() ) then return end
	return true
end

local PlanePositionBuffer = {}

hook.Add( "HUDPaint", "QToLeave", function()
	if !InGame( LocalPlayer() ) then return end
	surface.SetDrawColor(25,25,25,175)
	surface.DrawRect(0,ScrH() - (ScrH()/8),ScrW(),ScrH()/8)
	draw.DrawText("HOLD Q TO LEAVE MINIGAME","GTowerSkyMsgSmall",ScrW()/2,ScrH() - (ScrH()/10),Color( 255, 255, 255, 255 ),1)
end )
