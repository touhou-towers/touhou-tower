AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( self.Model )
	self:DrawShadow( false )

	self.Text = 10

	timer.Create("CountDown",1,self.Time,function()

		self.Time = self.Time - 1
		self.Text = self.Time

	end)

	if self.KVText then
		if string.len( self.KVText ) < 3 then
			self.Text = tonumber( self.KVText )
		else

			for k, v in pairs( self.Messages ) do
				if type( v ) == "table" then
					if v.Name == self.KVText then
						self.Text = k
					end
				elseif v == self.KVText then
					self.Text = k
				end
			end

		end
	end

	if self.Text == 1 then
		Msg( "gmt_skymsg: Could not find text id for: '", self.KVText, "'\n")
	end

	self:SetSkin( self.Text )

	self.KVText = nil

	timer.Simple( 0.0, function() self:UpdateDirection() end)
end






function ENT:UpdateDirection()
	if !IsValid( self ) then return end

	local Tbl = self.Messages[ self.Text ]

	if type( Tbl ) == "table" then
		if Tbl.IginoreTrace == false then
			return
		end
	end


	local EntPos = self:GetPos()
	local Trace = {}

	local function SolicQuickTrace( dir )
		return util.TraceLine( {
			start = EntPos,
			endpos = EntPos + dir,
			mask = MASK_PLAYERSOLID,
			filter = self
		} )
	end

	table.insert( Trace, SolicQuickTrace( Vector(0,-5000,0) ) )
	table.insert( Trace, SolicQuickTrace( Vector(0,5000,0)  ) )
	table.insert( Trace, SolicQuickTrace( Vector(-5000,0,0) ) )
	table.insert( Trace, SolicQuickTrace( Vector(5000,0,0)  ) )


	for _, v in pairs( Trace ) do
		if v.StartPos:Distance( v.HitPos ) < 64 then
			self:SetAngles( ( v.HitNormal * -1 ):Angle() )
			return
		end
	end

	if Trace[1].Fraction + Trace[2].Fraction > Trace[3].Fraction + Trace[4].Fraction then
		self:SetAngles( Angle(0,90,0) )
	end

end

function ENT:KeyValue( key, value )

	if key == "text" then
		self.KVText = string.Trim( value )
	elseif key == "time" then
		self.Time = value
	end

end
