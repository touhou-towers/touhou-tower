
concommand.Add("gmt_leavegroup", function( ply, cmd, args )
	if #args != 0 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	local Group = ply:GetGroup()

	if Group then
		Group:RemovePlayer( ply )
	end

end )

concommand.Add("gmt_groupinvite", function( ply, cmd, args )

	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	local TargetPly = ents.GetByIndex( tonumber( args[1] ) )

	if not IsValid( TargetPly ) or not TargetPly:IsPlayer() || ply == TargetPly then
		return
	end

	if TargetPly:HasGroup() then

		net.Start( "GGroup" )
			net.WriteInt( 3, 16 )
		net.Send( ply )

		/*umsg.Start("GGroup", ply)
			umsg.Char( 3 )
	    umsg.End()*/
		return
	end

	local Group = ply:GetGroup()

	if !Group then
		Group = GTowerGroup:NewGroup( ply )
	end

	Group:SendRequest( TargetPly )

end )

concommand.Add("gmt_acceptgroup", function( ply, cmd, args )

	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	if ply:HasGroup() then

		net.Start( "GGroup" )
			net.WriteInt( 4, 16 )
		net.Send( ply )

		/*umsg.Start("GGroup", ply)
		umsg.Char( 4 )
	    umsg.End()*/

		return
	end

	local GroupId = tonumber( args[1] )
	if !GroupId then return end

	local Group = GTowerGroup:Get( GroupId )

	if Group then
		Group:AcceptRequest( ply )
	else

		net.Start( "GGroup" )
			net.WriteInt( 5, 16 )
		net.Send( ply )

	    /*umsg.Start("GGroup", ply)
		umsg.Char( 5 )
	    umsg.End()*/
	end

end )

concommand.Add("gmt_denygroup", function( ply, cmd, args )
	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	if ply:HasGroup() then
		return
	end

	local GroupId = tonumber( args[1] )
	if !GroupId then return end

	local Group = GTowerGroup:Get( GroupId )

	if Group then
	    Group:DenyRequest( ply )
	else

		net.Start( "GGroup" )
			net.WriteInt( 5, 16 )
		net.Send( ply )

	    /*umsg.Start("GGroup", ply)
		umsg.Char( 5 )
	    umsg.End()*/
	end
end)

concommand.Add("gmt_groupremove", function( ply, cmd, args )
	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	local TargetPlyId = tonumber( args[1] )
	local TargetPly = ents.GetByIndex( args[1] )

	if !IsValid( TargetPly ) || !TargetPly:IsPlayer() || !ply:GroupOwner() then return end

	local Group = ply:GetGroup()

	if Group:HasPlayer( TargetPly ) then
		Group:RemovePlayer( TargetPly )
	end

end )


concommand.Add("gmt_groupmakeowner", function( ply, cmd, args )
	Msg( ply , " gmt_groupmakeowner\n")
	PrintTable( args )
	Msg("\n")

	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, cmd, args )
		end
		return
	end

	if !ply:GroupOwner() then return end

	local Group = ply:GetGroup()
	local TargetPly = ents.GetByIndex( tonumber( args[1] ) )

	Msg( ply , " making ", TargetPly , " group owner.")

	if !IsValid( TargetPly ) || !TargetPly:IsPlayer() || !Group:HasPlayer( TargetPly ) then
		return
	end

	Group:SetOwner( TargetPly )

	local rp = RecipientFilter()
	rp:AddPlayer( ply )
	rp:AddPlayer( TargetPly )

	net.Start( "GGroup" )
		net.WriteInt( 8, 16 )
		net.WriteInt( TargetPly:EntIndex(), 16 )
	net.Send( rp )

	/*umsg.Start("GGroup", rp)
	umsg.Char( 8 )
	umsg.Char( TargetPly:EntIndex() )
	umsg.End()*/

end )
