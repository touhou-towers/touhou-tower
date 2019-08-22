

function DissolveMSG( um )

	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end
	
	local eff = EffectData()
	eff:SetEntity( ent )
	
	util.Effect( "disappear", eff )
	
end

usermessage.Hook( "Dissolve", DissolveMSG )