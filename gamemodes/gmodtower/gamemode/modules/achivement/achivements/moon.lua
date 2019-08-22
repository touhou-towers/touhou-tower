

if CLIENT then return end

hook.Add("Location","MoonAchiCheck",function(ply,loc) 
	if IsValid( ply ) then
		if loc == 50 then 
			ply:AddAchivement(ACHIVEMENTS.ONESMALLSTEP,1)
			ply.MoonStoreModel = ply:GetModel()
			ply:SetModel("models/player/spacesuit.mdl")
			ply:SetGravity(0.4)
		elseif loc != 50 && ply.GLastLocation == 50 then
			ply:SetGravity(0)
			ply:SetModel(ply.MoonStoreModel)
		end
		
		if loc == 51 then 
			ply.MoonStoreModel = ply:GetModel()
			ply:SetModel("models/player/normal.mdl")
		elseif loc != 51 && ply.GLastLocation == 51 then
			ply:SetModel(ply.MoonStoreModel)
		end
		
	end
end)
