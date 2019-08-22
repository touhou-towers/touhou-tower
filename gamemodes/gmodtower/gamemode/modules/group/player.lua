

local meta = FindMetaTable( "Player" )
if (!meta) then 
    Msg("ALERT! Could not hook Player Meta Table\n")
    return 
end

function meta:GetGroup()
	return self._GTowerPlyGroup
end


function meta:HasGroup()
	return self._GTowerPlyGroup && self._GTowerPlyGroup:IsValid()
end
/*
function meta:SetGroup( Group )

	if self:IsBot() then
		return
	end
	
	Group:AddPlayer( self )
	
	hook.Call("GTowerGroupChanged", GAMEMODE, self, Group, true )
	
	return true
end



function meta:RemoveGroup()
	
	local Group = self:GetGroup()
	
	if Group then
		Group:RemovePlayer( self )
	end	
	
	hook.Call("GTowerGroupChanged", GAMEMODE, self, Group, false )
end
*/

function meta:GroupOwner()
	local Group = self:GetGroup()
	
	return Group && Group.Owner == self	
end