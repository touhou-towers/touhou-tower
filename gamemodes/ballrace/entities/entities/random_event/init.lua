ENT.Type 			= "anim"
ENT.Base			= "base_point"

function ENT:Initialize()

	self.Trigger = false

end

function ENT:Think()

	if !self.Trigger || !self.RelayA || !self.RelayB then return end

	local roll = math.random( 0, 1 )
	if roll == 0 then
		ents.FindByName( self.RelayA )[1]:Fire( "Trigger", 0, 0 )
	else
		ents.FindByName( self.RelayB )[1]:Fire( "Trigger", 0, 0 )
	end

	self.Trigger = false

end

function ENT:KeyValue( key, value )

	if key == "relaya" then
		self.RelayA = value
	elseif key == "relayb" then
		self.RelayB = value
	end

end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Trigger" then
		self.Trigger = true
	end

end