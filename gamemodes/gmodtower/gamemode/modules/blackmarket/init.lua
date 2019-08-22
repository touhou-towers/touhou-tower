
AddCSLuaFile("cl_init.lua")
require("glon")

local BM = {}
BM.Offers = {}

function BM:CheckPlayer(ply)
	for k, v in pairs(BM.Offers) do
		if k == ply:Name() then
		return true
		end
	end
	return false
end

function BM:FindPlayer(Name)
	local amount = 0
	local match
	
	if Name == "" then 
		return
	end
	
	for _,v in pairs(player.GetAll()) do
		if v:GetName():lower():find( Name:lower() ) then
			amount = amount+1
			match = v
		end
	end
	
	if not match then
		return false
	end
	
	if amount > 1 then
		return false
	elseif amount == 1 and match:IsPlayer() then
		return match
	elseif not match:IsPlayer() then
		return false
	end
	
	return false
end

function SendBMList(ply)
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	if ply then rp = ply end
	umsg.Start("blackmarketupdate", rp)
	local list = ""
	status, error = pcall( function() list = glon.encode(BM.Offers) end )
	umsg.String( list )
	umsg.End()
end

concommand.Add("gmt_bmwrite", function(ply, cmd, args)
		if !args[1] then return end
		local message = string.Trim(args[1])
		if message == "" or message == " " then return end
		if BM:CheckPlayer(ply) then
			ply:ChatPrint("You already have offer on black market. You can have only one offer at the same time.")
			return ""
		end
		BM.Offers[ ply:Name() ] = message
		PrintMessage(HUD_PRINTTALK, "Black Market: New offer available")
		SendBMList()
	end)

concommand.Add("gmt_bmcontact", function(ply, cmd, args)
		if !args[1] then return end
		local selply = BM:FindPlayer(string.sub(args[1], 2, 6)) --Do not use long player Name for this function
		if selply and BM:CheckPlayer(selply) then
			selply:Msg2("Black Market: "..ply:Nick().." want to talk with you about your offer")
			ply:Msg2("Black Market: Please wait for an answer from "..selply:Nick())
		end
	end)
	
concommand.Add("gmt_bmdelete", function(ply, cmd, args)
		if BM.Offers[ ply:Name() ] then BM.Offers[ ply:Name() ] = nil end
		SendBMList()
	end)
	
hook.Add( "PlayerSay", "BMSay", function( ply, text, team, death )
	if string.lower(string.sub(text, 1, 12)) == "/blackmarket" then
		umsg.Start("showblackmarket", ply)
		umsg.End()
		return ""
	end
end)

hook.Add( "PlayerInitialSpawn", "BMSpawn", function( ply )
	SendBMList(ply)
end)