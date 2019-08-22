util.AddNetworkString("UpdateShowDelay")
util.AddNetworkString("ResetStage")

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("gmidi2.lua")
AddCSLuaFile("foreplay.lua")
AddCSLuaFile("cl_util.lua")
AddCSLuaFile("cl_songinfo.lua")
AddCSLuaFile("cl_events.lua")
AddCSLuaFile("cl_lasers.lua")

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/gmod_tower/stage.mdl")
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit( SOLID_VPHYSICS )
	end
  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:EnableMotion(false)
  end
end

concommand.Add("showsecret",function(ply)
	if ply:SteamID() == "STEAM_0:0:38865393" then
		for k,v in pairs(player.GetAll()) do v:SendLua([[for k,v in pairs(ents.GetAll()) do if v:GetClass() == "stage" then v:StartEasteregg() end end]]) end
	end
end)

concommand.Add("showtime",function( ply, cmd, args, str )

if ply:IsAdmin() then

if string.len( str ) == 0 then
  WaitTime = 1
	net.Start("UpdateShowDelay")
	net.WriteFloat(0.1)
	net.Broadcast()
	for k,v in pairs(player.GetAll()) do v:SendLua([[for k,v in pairs(ents.GetAll()) do if v:GetClass() == "stage" then v:Start() end end]]) end
else
  WaitTime = tonumber(str) * 60
  net.Start("UpdateShowDelay")
  net.WriteFloat(tonumber(str))
  net.Broadcast()
end

for k,v in pairs(player.GetAll()) do
  if WaitTime == 0 or WaitTime == 60 then
    --Placed nothing here so it wouldn't spam 2 messages.
  else
		v:SendLua([[GTowerChat.Chat:AddText("4th of July Show Starting In ]]..string.NiceTime( WaitTime )..[[!", Color( 255, 50, 50, 255 ))]])
  end
end


end
end)
net.Receive("ResetStage",function()
  for _,stage in pairs(ents.GetAll()) do if stage:GetClass() == "stage" then
    local newstage = ents.Create( "stage" )
    newstage:SetPos( stage:GetPos() )
    newstage:SetAngles( stage:GetAngles() )
    newstage:Spawn()
    net.Start("UpdateShowDelay")
    net.WriteFloat(3600)
    net.Broadcast()
    stage:Remove()
  end end
end)
