
local function PlayerChooseRabbitDeath( ply )
	
	ply.AllowChooseRabbit = nil
	
	for _, v in pairs( player.GetAll() ) do
		if v.AllowChooseRabbit then
			return
		end
	end
	
	hook.Remove("PlayerDeath", "RemoveRabbit")
	
end

local function SendRabbitMenu( ply, admin )
	ply.AllowChooseRabbit = CurTime() + 180.0
	ply.AllowChooseRabbitPly = admin
	
	hook.Add("PlayerDeath", "RemoveRabbit", PlayerChooseRabbitDeath )
	ply:SendLua("GTowerModels.ShowRabbitMenu()")
end

concommand.Add("gmt_setallrabbit", function(ply,cmd,args) 
	
	if ply:IsAdmin() then
		for k, v in pairs( player.GetAll() ) do
			if ply:Location() == v:Location() then // && !v:IsAdmin() && !v:IsRabbit() then
				SendRabbitMenu( v, ply )
			end		
		end
	end

end )

concommand.Add("gmt_setrabbit", function(ply,cmd,args) 
	if ply:IsAdmin() then 
		local Target = ply:GetEyeTrace().Entity
		local Id = tonumber( args[1] )
		
		if args[1] then
			Target = ply
		end
		
		if IsValid( Target ) && Target:IsPlayer() then
			SendRabbitMenu( Target, ply )
			ply:Msg2("Sent rabbit to " .. Target:GetName())
		end
	end 
	
end )

concommand.Add("gmt_rabbit", function(ply,cmd,args) 

	if !ply.AllowChooseRabbit || ply.AllowChooseRabbit < CurTime() then
		return
	end
	
	ply.AllowChooseRabbit = nil
	ply.AllowChooseRabbitPly = nil
	
	local ItemId = tonumber( args[1] )
	
	if !ItemId then
		print("Could not find item: ", ItemId)
		return
	end
	
	local Rabbit = GTowerItems:Get( ItemId )
	
	if !Rabbit || Rabbit.ModelName != "redrabbit" then
		print("Could not find item: ", Rabbit)
		return
	end
	
	if GTowerModels.Get( ply ) != 0.55 then
		ply._PlyModelOverRide = { Rabbit.Model, Rabbit.ModelSkinId }
		GTowerModels.SetTemp( ply, 0.55 ) 
	else
		ply:SetModel( Rabbit.Model )
		ply:SetSkin( Rabbit.ModelSkinId )
	end
	
end )