REPL_EVERYONE = 0
REPL_PLAYERONLY = 1

NWTYPE_STRING = 0
NWTYPE_NUMBER = 1
NWTYPE_FLOAT = 2
NWTYPE_CHAR = 3
NWTYPE_SHORT = 4
NWTYPE_BOOL = 5
NWTYPE_BOOLEAN = NWTYPE_BOOL
NWTYPE_ANGLE = 6
NWTYPE_VECTOR = 7
NWTYPE_ENTITY = 8

NWGlobal = {}
NWPlayer = {}

function GetWorldEntity()
	return game.GetWorld()
end

function RegisterNWTableGlobal(nwtable)
	table.Merge( NWGlobal, nwtable )
end

function RegisterNWTablePlayer(nwtable)
	table.Merge( NWPlayer, nwtable )
end

local meta = FindMetaTable( "Entity" )
if ( !meta ) then return end

function meta:SetNet(vname,var)
	if self:IsPlayer() then
		local nwtype
		for i=1,#NWPlayer do
			if NWPlayer[i][1] == vname then
				nwtype = NWPlayer[i][3]
			end
		end
		
		if nwtype == NWTYPE_STRING then
			self:SetNWString(vname,var)
		elseif (nwtype == NWTYPE_NUMBER || nwtype == NWTYPE_CHAR || nwtype == NWTYPE_SHORT) then
			self:SetNWInt(vname,var)
		elseif nwtype == NWTYPE_FLOAT then
			self:SetNWFloat(vname,var)
		elseif (nwtype == NWTYPE_BOOL || nwtype == NWTYPE_BOOLEAN) then
			self:SetNWBool(vname,var)
		elseif nwtype == NWTYPE_ANGLE then
			self:SetNWAngle(vname,var)
		elseif nwtype == NWTYPE_VECTOR then
			self:SetNWVector(vname,var)
		elseif nwtype == NWTYPE_ENTITY then
			self:SetNWEntity(vname,var)
		end
	elseif self == game.GetWorld() then
		local nwtype
		for i=1,#NWGlobal do
			if NWGlobal[i][1] == vname then
				nwtype = NWGlobal[i][3]
			end
		end
		
		if nwtype == NWTYPE_STRING then
			SetGlobalString(vname,var)
		elseif (nwtype == NWTYPE_NUMBER || nwtype == NWTYPE_CHAR || nwtype == NWTYPE_SHORT) then
			SetGlobalInt(vname,var)
		elseif nwtype == NWTYPE_FLOAT then
			SetGlobalFloat(vname,var)
		elseif (nwtype == NWTYPE_BOOL || nwtype == NWTYPE_BOOLEAN) then
			SetGlobalBool(vname,var)
		elseif nwtype == NWTYPE_ANGLE then
			SetGlobalAngle(vname,var)
		elseif nwtype == NWTYPE_VECTOR then
			SetGlobalVector(vname,var)
		elseif nwtype == NWTYPE_ENTITY then
			SetGlobalEntity(vname,var)
		end
	end
end

function meta:GetNet(vname)
	if self:IsPlayer() then
		local nwtype
		for i=1,#NWPlayer do
			if NWPlayer[i][1] == vname then
				nwtype = NWPlayer[i][3]
			end
		end
		
		if nwtype == NWTYPE_STRING then
			return self:GetNWString(vname)
		elseif (nwtype == NWTYPE_NUMBER || nwtype == NWTYPE_CHAR || nwtype == NWTYPE_SHORT) then
			return self:GetNWInt(vname)
		elseif nwtype == NWTYPE_FLOAT then
			return self:GetNWFloat(vname)
		elseif (nwtype == NWTYPE_BOOL || nwtype == NWTYPE_BOOLEAN) then
			return self:GetNWBool(vname)
		elseif nwtype == NWTYPE_ANGLE then
			return self:GetNWAngle(vname)
		elseif nwtype == NWTYPE_VECTOR then
			return self:GetNWVector(vname)
		elseif nwtype == NWTYPE_ENTITY then
			return self:GetNWEntity(vname)
		end
	elseif self == game.GetWorld() then
		local nwtype
		for i=1,#NWGlobal do
			if NWGlobal[i][1] == vname then
				nwtype = NWGlobal[i][3]
			end
		end
		
		if nwtype == NWTYPE_STRING then
			return GetGlobalString(vname,var)
		elseif (nwtype == NWTYPE_NUMBER || nwtype == NWTYPE_CHAR || nwtype == NWTYPE_SHORT) then
			return GetGlobalInt(vname)
		elseif nwtype == NWTYPE_FLOAT then
			return GetGlobalFloat(vname)
		elseif (nwtype == NWTYPE_BOOL || nwtype == NWTYPE_BOOLEAN) then
			return GetGlobalBool(vname)
		elseif nwtype == NWTYPE_ANGLE then
			return GetGlobalAngle(vname)
		elseif nwtype == NWTYPE_VECTOR then
			return GetGlobalVector(vname)
		elseif nwtype == NWTYPE_ENTITY then
			return GetGlobalEntity(vname)
		end
	end
end

local function AssignGlobalVariables()
	if #NWGlobal == 0 then return end
	for i=1,#NWGlobal do
		game.GetWorld():SetNet(NWGlobal[i][1],NWGlobal[i][2])
	end
end
hook.Add( "Initialize", "VariableAssignGlobal", AssignGlobalVariables )

local function AssignPlayerVariables( ply )
	if #NWPlayer == 0 then return end
	for i=1,#NWPlayer do
		ply:SetNet(NWPlayer[i][1],NWPlayer[i][2])
	end
end
hook.Add( "PlayerInitialSpawn", "VariableAssignPlayer", AssignPlayerVariables )