
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()

	self.NextRandomLazers = 0
	self.NextScale = 0.2
	
	self.BaseClass.Initialize( self )
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:StopStream()
	
	self:SetModelScale( Vector(1,1,1) )
	self.NextScale = 0.2
	
	self.BaseClass.StopStream( self )
	
end

function ENT:InLimit( loc )
	return loc == self:Location()
end

function ENT:Think()

	if CurTime() > self.NextRandomLazers then
	
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetEntity( self )
			effectdata:SetMagnitude( 5.0 + math.Rand(-1,1) )
		util.Effect( "disco_light", effectdata )
		
		self.NextRandomLazers = CurTime() + 0.25 + math.Rand( -0.15, 0.15 )
	
	end
	
	local Stream = self:GetStream()
	
	if IsValid( Stream ) then	
		self:UpdateStreamVals( Stream )
	end
	
	if self.NextScale then
		
		if self.NextScale > 0.45 && math.random( 0, 8 ) == 2 then
			
			local Count = math.floor( math.Rand( 1, math.ceil( self.NextScale * 10 ) ) )
			
			if Count > 0 then
				
				for i=1, Count do
					
						local effectdata = EffectData()
							effectdata:SetEntity( self )
							effectdata:SetStart( self:GetPos() )
							effectdata:SetOrigin( util.QuickTrace( self:GetPos(), VectorRand() * 2048, self ).HitPos )
							effectdata:SetScale( 3 )
							effectdata:SetRadius( 2 )
							effectdata:SetMagnitude( 0.5 + math.Rand(0,self.NextScale*2) )
							
						util.Effect("tesla_shoot", effectdata)
					
					end
				
			end
		
		end
		
	end
	
	self.BaseClass.Think( self )
	
end

function ENT:UpdateStreamVals( Stream )

	if !Stream:IsPlaying() then
		self.NextScale = 0.2
		return
	end
	
	local Bands = Stream:fft2048()
	
	local Max = 0
	
	//for k, v in pairs( Bands ) do
	//	Max = math.max( Max, v )
	//end
	
	//cam.Start3D2D( self:GetPos(), Angle(0,0,0), 0.25 )
	
		//ATTEMPT TO CALCULATE SCALE = 0.2 to 1.0
		local Sum = 0
		local Total = 40
		
		for i=1, Total do
			Max = math.max( Max, Bands[i] )
			Sum = Sum + Bands[i]
		end
		
		local Avg = Sum/Total
		
		self.NextScale = 0.2 + math.Clamp( ( Avg / Max ) * 0.8, 0, 0.8 )
		
	/*	surface.SetDrawColor( 0, 0, 125, 125 )
		surface.DrawRect( 0, 0, Total, 150 )
		
		surface.SetDrawColor( 0, 125, 0, 255 )
		surface.DrawRect( 0, 0, Total, self.NextScale * 150 )
		
		surface.SetDrawColor( 0, 0, 125, 255 )
		surface.DrawRect( 0, 0, Total, (Avg/Max) * 150 )
		
		
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		for k, v in pairs( Bands ) do
			
			surface.DrawLine( k, 0 , k, v/Max * 150 )
			
		end	
	
	cam.End3D2D()
	*/
	self:SetModelScale( Vector(1,1,1) * self.NextScale )

	
end
/*
function ENT:DrawTranslucent()
	local Stream = self.EmitStream
	
	if !Stream then
		return
	end
	
	if Stream:getposition() >= Stream:getlength() - 1 then
		return
	end
	
	local Bands = Stream:fft2048()
	
	local Max = 0, 0
	
	for k, v in pairs( Bands ) do
		Max = math.max( Max, v )
	end
	
	cam.Start3D2D( self:GetPos(), Angle(0,0,0), 0.25 )
	
		//ATTEMPT TO CALCULATE SCALE = 0.2 to 1.0
		local Sum = 0
		local Total = 64
		
		for i=1, Total do
			Sum = Sum + Bands[i]
		end
		
		local Avg = Sum/Total
		
		self.NextScale = 0.2 + math.Clamp( ( Avg / Max ) * 0.8, 0, 0.8 )
		
		surface.SetDrawColor( 0, 0, 125, 125 )
		surface.DrawRect( 0, 0, Total, 150 )
		
		surface.SetDrawColor( 0, 125, 0, 255 )
		surface.DrawRect( 0, 0, Total, self.NextScale * 150 )
		
		surface.SetDrawColor( 0, 0, 125, 255 )
		surface.DrawRect( 0, 0, Total, (Avg/Max) * 150 )
		
		
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		for k, v in pairs( Bands ) do
			
			surface.DrawLine( k, 0 , k, v/Max * 150 )
			
		end	
	
	cam.End3D2D()
	
end
*/
