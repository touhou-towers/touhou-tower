include('shared.lua')

function ENT:Draw()

	self.Entity:DrawModel()
	
end


function EffectMsg( um )

	local msgType = um:ReadBool()
	
	local ent = um:ReadEntity()
	
	if !IsValid( ent ) then return end
	
	effectType = "disappear"
	
	if msgType then
		effectType = "reappear"
	end
	
	local effect = EffectData()
	effect:SetEntity( ent )
	
	util.Effect( effectType, effect )
	
end

usermessage.Hook( "BlockEffect", EffectMsg )