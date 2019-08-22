include("shared.lua")

module("minigames.pvpnarnia",package.seeall )

LocalPlayerInGame = false
ForceAngle = nil

usermessage.Hook("pvpnarnia", function( um )

	local Id = um:ReadChar()
	
	if Id == 0 then
		AddHooks()
	elseif Id == 1 then
		RemoveHooks()
	end

end )

function InGame( ply )
	if ply == LocalPlayer() then
		return LocalPlayerInGame
	end
end

function HudShowWeapons( name )
	if name == "CHudWeaponSelection" || name == "CHudAmmo" then	
		return true
	end
end

function ShouldCollide( ply1, ply2 )
	if ply1:IsPlayer() && ply2:IsPlayer() then
		return true
	end
end

function AddHooks()

	_G.GAMEMODE.AddDeathNotice = function() return true end
	hook.Add("OpenSideMenu", "PVPNarniaOpenSideMenu", OpenSideMenu )
	hook.Add("HUDShouldDraw", "PVPNarniaShowWeapon", HudShowWeapons )
	hook.Add("ShouldCollide", "EnableNarniaCollisions", ShouldCollide )
	
	
	LocalPlayerInGame = true
	LocalPlayer()._DisabledJetpack = true
end

function OpenSideMenu()

	local Form = vgui.Create("DForm")
	
	Form:SetName( "PVP Narnia" )
	
	local Refresh = Form:Button("LEAVE")
	Refresh.DoClick = function() RunConsoleCommand("gmt_pvpnarnialeave") end
	
	return Form
	
end

function RemoveHooks()

	_G.GAMEMODE.AddDeathNotice = _G.GAMEMODE.BaseClass.AddDeathNotice
	
	hook.Remove("OpenSideMenu", "PVPNarniaOpenSideMenu")
	hook.Remove("HUDShouldDraw", "PVPNarniaShowWeapon" )
	hook.Remove("ShouldCollide", "EnableNarniaCollisions" )
	
	LocalPlayerInGame = false
	LocalPlayer()._DisabledJetpack = nil
end

