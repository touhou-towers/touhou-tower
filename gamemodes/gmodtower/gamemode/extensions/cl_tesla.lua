


module("tesla", package.seeall )

local MetaTable = {
	__index = getfenv()
} 

function New()
	
	return setmetatable( {
		List = nil,
		Filter = nil,
		MaxAngle = 45
	}, MetaTable )
	
end

function SetMaxAngle( self, ang )
	self.MaxAngle = ang
end

function AttemptFindList( self, Start, End )
	
	local Trace = TraceLine( self, Start, End )
	
	if Trace.Fraction > 0.99 then
		//We have contact!
		SetList( self, { End, Start } )
		return true
	end
	
	//Try a double trace, around a wall or something.
	local Dir = ( End - Start ):Normalize()
			
	Dir:Rotate( Angle( math.Rand( -90, 90 ), math.Rand( -90, 90 ), 0 ) )
			
	local Trace = TraceLine( self, End, End + Dir * 1024 )
	local Trace2 = TraceLine( self, Trace.HitPos, Start  )
			
	if Trace2.Fraction > 0.9 then
		//We have inderect contact, but contact never the less.
		SetList( self, { End, Trace.HitPos, Start } )
		return true
	end	
	
	return false

end

function SetList( self, List )
	self.List = List
end

function SetFilter( self, tbl )
	self.Filter = tbl
end

function TraceLine( self, StartPos, EndPos )
	
	return util.TraceLine( {
		start = StartPos,
		endpos = EndPos,
		mask = MASK_SOLID_BRUSHONLY,
		filter = self.Filter
	} )

end

function RandTrace( self, Cur, Next ) 

	local Lenght = Cur:Distance( Next )
	local Normal = (Next-Cur):Normalize()
	
	math.randomseed( CurTime() * Lenght )
		
	local Ratio = math.Rand( 0.2, 0.8 )
	
	Normal:Rotate( Angle( math.Rand( -self.MaxAngle, self.MaxAngle ), math.Rand( -self.MaxAngle, self.MaxAngle ), 0 ) )
		
	local Trace = TraceLine( 
		self,
		Cur,
		Cur + Normal * Ratio * Lenght 
	)
		
	if Trace.Fraction < 0.99 then
		return
	end
		
	local Trace2 = TraceLine( 
		self,
		Trace.HitPos,
		Next
	)
		
	if Trace2.Fraction < 0.99 then
		return
	end
	
	//Return the mid point that did work
	return Trace.HitPos

end

function BreakUpTrace( self, count )
	
	local NewList = { self.List[1] }
	
	for i=2, #self.List do
		
		local Cur = self.List[i-1]
		local Next = self.List[i]
		
		//Make 3 attemps to find a path
		for i=0, 3 do
			
			local Attempt = RandTrace( self, Cur, Next )
			
			if Attempt then
				table.insert( NewList, Attempt )
				break
			end
			
		end
	
	end
	
	table.insert( NewList, self.List[#self.List] )
	
	self.List = NewList
	
	if count > 0 then
		return BreakUpTrace( self, count - 1 )
	end

end

function Get( self )
	return self.List
end