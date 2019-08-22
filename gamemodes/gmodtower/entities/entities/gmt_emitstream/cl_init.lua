
include('shared.lua')

function ENT:Initialize()	
	
	self:SetNetworkedVarProxy("CurChan", self.StreamChanged )

end

function ENT:Draw()

end

function ENT:GetStream()
	if self.EmitStream then
		return self.EmitStream
	end

	local Owner = self:GetOwner()
	
	if IsValid( Owner ) then
		return Owner.EmitStream
	end
end

function ENT:InLimit( loc )
	return true
end

function ENT:SetStream( Stream )
	self.EmitStream = Stream
end


function ENT:StopStream()
	if self.EmitStream then
		self.EmitStream:Stop()
		self.EmitStream = nil
	end
end

function ENT:ToggleStream()

	if !self.EmitStream then return end

	if self.EmitStream.IsMuted then

		self.EmitStream.Stream:setvolume( 1 )
		self.EmitStream.IsMuted = false

	else

		self.EmitStream.Stream:setvolume( 0 )
		self.EmitStream.IsMuted = true

	end

end

function ENT:NewStream( URL )

	self:StopStream()
	
	self.EmitStream = BassStream.New( URL )
	
	if ( !self.EmitStream ) then return end
	
	self.EmitStream:SetEntity( self )
	
end

function ENT:Think()
	self:StreamThink()
end

function ENT:StreamThink()
	
	if self.EmitStream then
		self.EmitStream:Think( self:GetPos() )
	end
	
end

function ENT:StreamChanged( name, oldval, nwc )
	if string.len( nwc ) < 4 then return end
	if nwc == self.CurrentStream then return end

	self.CurrentStream = nwc
	
	if ( !self.NewStream ) then return end
	
	self:NewStream( self.CurrentStream )
	
end

function ENT:OnRemove()
	if BassStream.DEBUG then
		print("Removing entity!")
	end

	self:StopStream()
end

usermessage.Hook("emitselect", function(um)
	
	local ent = um:ReadLong()
	
	Derma_StringRequest( "Set music", 
		"Set the music of entity " .. ent , 
		"", 
		function( out ) RunConsoleCommand("gmt_emitset", ent, out ) end,
		nil,
		"SET", 
		"Cancel" 
	)

end )