
local function RespawnAllow( ply )

	// ragdolled players should not be able to force respawn
	if ( ply.Ragdolled ) then return false end
	
	if ( ply:IsAdmin() ) then return true end
	
	if ( !ply:Alive() && ply:GetSetting( "GTAllowForceModel" ) ) then return true end

	return false
	
end

local function CanForce( ply )

	if ( !Animation ) then
		Msg ( "Animation module not loaded!\n" )
		return false
	end
	
	if ( !IsValid( ply ) ) then return false end
	
	if ( ply:IsAdmin() || ply:GetSetting( "GTAllowForceModel" ) ) then return true end
	
	if ( ply.NextForce == nil ) then
	
		ply.NextForce = 0
		return false
		
	end
	
	if ( ply.NextForce > CurTime() ) then return false end
	
	return false
	
end

local function SetNextForce( ply, val )
	
	if ( !IsValid( ply ) ) then return end
	
	ply.NextForce = val
	
end

concommand.Add( "gmt_respawn", function( ply, cmd, args )

	if ( !RespawnAllow( ply ) ) then return end
	
	ply:UnSpectate()
	
	local pos = ply:GetPos()
	local ang = ply:EyeAngles()
	
	ply:Spawn()
	
	ply:SetPos( pos )
	ply:SetEyeAngles( ang )

end )


// forces an animation on the current player
concommand.Add( "gmt_forceanim", function( ply, cmd, args )

	if ( #args == 0 ) then return end
	
	if ( ply:IsAdmin() || ply:GetSetting( "GTAllowForceModel" ) ) then 
		
		if ( !CanForce( ply ) ) then return end
		
		local arg = args[ 1 ] 
	
		Animation.PlayAnim( ply, arg )
		
		SetNextForce( ply, CurTime() + 1 )
		
	end
	
end )

// forces the model (and optional scale) on the current player
concommand.Add( "gmt_forcemodel", function( ply, cmd, args )

	if ( #args == 0 ) then return end
	

	if ( !CanForce( ply ) ) then return end
	
	ply:SetModel( args[ 1 ] )
	
	if ( #args > 1 ) then
	
		local scale = tonumber( args[ 2 ] ) or 1
		
		Animation.ScaleModel( ply, scale )
		
	end
	
	SetNextForce( ply, CurTime() + 1 )
	
end )
