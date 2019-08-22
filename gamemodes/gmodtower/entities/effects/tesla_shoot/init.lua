
local matBeam		 		= Material( "cable/blue_elec" )
local WhiteColor = Color( 255, 255, 255, 255 )
local Time = 0.1

function EFFECT:Init( data )
	
	local StartPos = data:GetOrigin()
	local EndPos = data:GetStart()
	local Count = data:GetScale()
	local BreakupCount = data:GetRadius()
	local Owner = data:GetEntity()
	local Life = data:GetMagnitude()
	
	if !IsValid(Owner) then return end
	
	self.DieTime = CurTime() + Life
	
	self.Traces = {}
	
	for i=1, Count do
		
		local Tesla = tesla.New()
		
		Tesla:SetMaxAngle( 10 )
		Tesla:SetFilter( { Owner:GetOwner(), Owner } )
		
		if Tesla:AttemptFindList( StartPos, EndPos ) then
			Tesla:BreakUpTrace( 4 )
			local List = Tesla:Get()
			local EndList = {}
			
			EndList.Start = CurTime() + math.Rand( 0, 5 )
			EndList.End = EndList.Start + math.Rand( 5, 10 )
			
			for k, v in ipairs( List ) do
				EndList[ k ] = { v, v + VectorRand() * 32 }
			end
			
			table.insert( self.Traces, EndList )
		end
		
	end
	
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render()
	
	render.SetMaterial( matBeam )
	
	local TimeProgress = 1 - (self.DieTime - CurTime()) / Time
	local Alpha 
	
	if TimeProgress < 0.5 then
		Alpha = math.cos( math.pi / 2 * TimeProgress - math.pi / 4 )
	else
		Alpha = -2 * TimeProgress + 2
	end
	
	for _, List in pairs( self.Traces ) do
		
		local Count = #List
		
		render.StartBeam( Count )

		for k, v in ipairs( List ) do
		
			render.AddBeam( 
				LerpVector( TimeProgress , v[1], v[2] ),
				Alpha * 15,
				Lerp( k/Count , List.Start, List.End ), 
				Color(255,255,255,255 ) 
			)
			
		end
			
		render.EndBeam()
		
	end
	
end