ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	if self.Parent then
		local Parent = ents.FindByName( self.Parent )

		if IsValid(Parent[1]) then
			self:SetParent( Parent[1] )
		end
	end

	self.ReFire = CurTime()
end

function ENT:StartTouch( ent )
	if ent:GetClass() != "player_ball" then return end

	//Msg( self.Sound )
	if self.Sound then self:EmitSound( self.Sound, 100, 100 ) end
	if self.Relay then ents.FindByName( self.Relay )[1]:Fire( "Trigger", 0, 0 ) end
end

function ENT:KeyValue( key, value )
	if key == "sound" then
		self.Sound = value

	elseif key == "relay" then
		self.Relay = value

	elseif key == "parentname" then
		self.Parent = value
	end
end

function ENT:AcceptInput( input, activator, ply )
end
