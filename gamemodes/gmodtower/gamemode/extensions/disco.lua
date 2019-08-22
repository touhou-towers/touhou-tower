
if SERVER then
	return
end

module("disco", package.seeall )

local MetaTable = {
	__index = getfenv()
}

function New( ent )
	
	return setmetatable( {
		Ent = ent,
		NextThink = CurTime(),
	}, MetaTable )
	
end

function Think( self )
	
	if self.NextThink < CurTime() then
		self:RandomLazers()
	end
	
end

function RandomLazers( self, count )

	//How many lazers are going to be drawn
	count = count or 10
	
	

end
