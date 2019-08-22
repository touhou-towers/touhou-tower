
AddCSLuaFile( "cl_init.lua" )


if ( !require( "furryfinder" ) ) then
	SQLLog( "error", "Unable to load furryfinder module. steamgroups module disabled." )
	return
end

local playerMeta = FindMetaTable( "Player" )

if ( !playerMeta ) then
	SQLLog( "error", "Unable to get Player meta table. steamgroups module disabled." )
	return
end


local function GetPlayerBySteamID( steamid )
	for _, v in ipairs( player.GetAll() ) do
		if ( v:SteamID() == steamid ) then
			return v
		end
	end
	
	return nil
end

function playerMeta:RequestGroupStatus( group )

	if ( type( group ) == "table" ) then
	
		for _, v in pairs( group ) do
			self:RequestGroupStatus( v )
		end
		
		return
	end
	
	return furryfinder.RequestGroupStatus( self:SteamID(), group )
end

// checks for membership in all groups
function playerMeta:IsGroupMemberAll( groups )
	for _, v in ipairs( groups ) do
		if ( !self:IsGroupMember( v ) ) then
			return false
		end
	end
	return true
end

// checks for membership in at least one group
function playerMeta:IsGroupMemberOne( groups )
	for _, v in ipairs( groups ) do
		if ( self:IsGroupMember( v ) ) then
			return true
		end
	end
	return false
end

function playerMeta:IsGroupMember( group )	
	return self:IsGroupX( group, "IsMember" )
end

function playerMeta:IsGroupOfficer( group )
	return self:IsGroupX( group, "IsOfficer" )
end

function playerMeta:IsGroupX( group, x )
	if ( !self.GroupStatus || !self.GroupStatus[ group ] ) then
		return nil // unknown case, haven't requested yet
	end
	
	return self.GroupStatus[ group ][ x ]
end


hook.Add( "GSGroupStatus", "GMTGroupStatus", function( steamUser, steamGroup, isMember, isOfficer )

	local ply = GetPlayerBySteamID( steamUser )
	
	if ( !ply ) then return end
	
	if ( !ply.GroupStatus ) then
		ply.GroupStatus = { }
	end
	
	ply.GroupStatus[ steamGroup ] = 
	{
		Group = steamGroup,
		IsMember = isMember,
		IsOfficer = isOfficer,
	}
	
end )