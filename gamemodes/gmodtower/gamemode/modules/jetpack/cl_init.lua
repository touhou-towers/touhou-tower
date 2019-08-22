-- i dont know how to get this to show
include("shared.lua")

local hook = hook
local surface = surface
local LocalPlayer, _G = LocalPlayer, _G

module("jetpack")

function GetJetpack()
	if ActiveJetpack && ActiveJetpack:IsValid() then
		return ActiveJetpack
	end
end

function JetpackFuelDraw()
	if GetJetpack() then
		local Amount = JetpackLeft( LocalPlayer() )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, 7, 102 )
		surface.DrawRect( 1, 1, 5, Amount * 100 )
		
	end
end

hook.Add("Initialize", "CheckJetpackDraw", function()
	if _G.GAMEMODE.AllowJetpack == true then
		hook.Add("HUDPaint", "DrawJetpackFuel", JetpackFuelDraw)
	end
end)