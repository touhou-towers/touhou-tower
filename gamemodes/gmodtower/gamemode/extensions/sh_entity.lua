

-----------------------------------------------------
if CLIENT then return end

local meta = FindMetaTable( "Entity" )

function meta:EmitSoundInLocation( snd, vol, pitch )
	local loc = GTowerLocation:FindPlacePos(self:GetPos())
	local id = self:EntIndex()
	
  for k,v in pairs(GTowerLocation:GetPlayersInLocation(loc)) do
	v:SendLua([[ents.GetByIndex( ]]..id..[[ ):EmitSound("]]..snd..[[",]]..(vol or 100)..[[,]]..(pitch or 100)..[[)]])
  end

end
