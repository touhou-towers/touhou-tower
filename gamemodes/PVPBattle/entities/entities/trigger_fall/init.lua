ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	if self.Parent then
		local Parent = ents.FindByName( self.Parent )

		if IsValid(Parent[1]) then
			self:SetParent( Parent[1] )
		end
	end
end

function ENT:StartTouch( ply )
	if !ply:IsPlayer() || !ply:Alive() || !IsValid(ply) then return end

	ply:ScreenFade(SCREENFADE.OUT, Color(0,0,0), 1, 120)
	PostEvent( ply, "putimestop_on" )
end

function ENT:EndTouch( ply )
	ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 0)
	PostEvent( ply, "putimestop_off" )
end

function ENT:Touch()
end

function ENT:KeyValue( key, value )
	if key == "parentname" then
		self.Parent = value
	end
end

function ENT:AcceptInput( input, activator, ply )

end
