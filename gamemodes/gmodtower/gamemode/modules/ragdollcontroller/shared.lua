
local metaPlayer = FindMetaTable("Player")

function metaPlayer:IsRagdoll()
	
	return self.Ragdoll
	
end

RegisterNWTablePlayer( { { "Ragdolled", false, NWTYPE_BOOLEAN, REPL_EVERYONE } } )