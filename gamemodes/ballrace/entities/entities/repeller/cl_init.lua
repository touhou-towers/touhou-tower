include('shared.lua')

usermessage.Hook("br_electrify", function(um)
	local repeller = um:ReadEntity()
	local ball = um:ReadEntity()
	local link = um:ReadBool()
	
	if !IsValid(repeller) || !IsValid(ball) then return end
	
	if !ball.Links then
		ball.Links = {}
	end
	
	if link && ball.Links then
		ball.Links[repeller] = true
		local edata = EffectData()
		
		edata:SetOrigin(repeller:LocalToWorld(repeller:OBBCenter()))
		edata:SetEntity(ball)
		edata:SetAttachment(repeller:EntIndex())
		
		util.Effect("lightning", edata)
	else
		ball.Links[repeller] = false
	end
end)