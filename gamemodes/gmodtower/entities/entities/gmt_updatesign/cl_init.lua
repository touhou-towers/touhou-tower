include("shared.lua")

hook.Add("OpenSideMenu", "UpdatesignAdmin", function()

	if !LocalPlayer():IsAdmin() then return end
	local Ent = LocalPlayer():GetEyeTrace().Entity

	if !IsValid( Ent ) or Ent:GetClass() != "gmt_updatesign" then return end

	local Form = vgui.Create("DForm")
	Form:SetName( "Set Skin" )

	local Ballrace = Form:Button( "Ballrace")
	Ballrace.DoClick = function()
    Ent:SetGlobalSkin(0,ent)
	end

  local GourmetRace = Form:Button( "Gourmet Race")
  GourmetRace.DoClick = function()
    Ent:SetGlobalSkin(1)
  end

  local Minigolf = Form:Button( "Minigolf")
  Minigolf.DoClick = function()
    Ent:SetGlobalSkin(2)
  end

  local Monotone = Form:Button( "Monotone")
  Monotone.DoClick = function()
    Ent:SetGlobalSkin(3)
  end

  local PVP = Form:Button( "PVP Battle")
  PVP.DoClick = function()
    Ent:SetGlobalSkin(4)
  end

  local UCH = Form:Button( "Source Karts")
  UCH.DoClick = function()
    Ent:SetGlobalSkin(5)
  end

  local UCH = Form:Button( "UCH")
  UCH.DoClick = function()
    Ent:SetGlobalSkin(6)
  end

  local Virus = Form:Button( "Virus")
  Virus.DoClick = function()
    Ent:SetGlobalSkin(7)
  end

  local ZombieMassacre = Form:Button( "Zombie Massacre")
  ZombieMassacre.DoClick = function()
    Ent:SetGlobalSkin(8)
  end

  local Blueprint = Form:Button( "Work In Progress")
  Blueprint.DoClick = function()
    Ent:SetGlobalSkin(9)
  end

	return Form
end)

function ENT:SetGlobalSkin(skin)
	net.Start("SetUpdateSkin")
	net.WriteEntity(self)
	net.WriteInt(skin,8)
	net.SendToServer()
end
