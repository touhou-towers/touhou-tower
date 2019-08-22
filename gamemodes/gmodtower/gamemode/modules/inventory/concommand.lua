
local DEBUG = false

concommand.Add( "gm_invspawn", function( ply, command, args )

	if #args != 5 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

    local ItemId = 	args[1]
    local Rotation = 	tonumber( args[2] )
    local AimVec = Vector( tonumber( args[3] ) , tonumber( args[4] ) , tonumber( args[5] ) )

	--AimVec = AimVec:Normalize()

	local Message = ply:DropItem( ItemId, AimVec, Rotation )

	if DEBUG then
		Msg( ply, " dropping ent " .. tostring(ItemId) .. " on the floor. ", Message ," (Rotation: " .. Rotation .. ")\n")
	end
end )

concommand.Add( "gm_invswap", function( ply, command, args )
    if #args != 2 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

    local ItemId1 = 	args[1]
    local ItemId2 = 	args[2]

	ply:InvSwap( ItemId1, ItemId2 )

	if DEBUG then
		Msg( ply, " swapping the items " .. ItemId1 .. " and " .. ItemId2 .. ".\n")
	end

end )

concommand.Add( "gmt_invtobank", function( ply, command, args )

	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

	local ItemSlot = GTowerItems:NewItemSlot( ply, args[1] )
	local Item = ItemSlot:Get()
	local Slot = GTowerItems:NewItemSlot( ply, "-2" ) //In the bank!

	if !Item then return end

	Slot:FindUnusedSlot( Item, true )

	if !Slot:IsValid() then
		ply:Msg2('Sorry, your trunk is full!')
		return
	end

	Slot:Set( Item )
	Slot:ItemChanged()

	ItemSlot:Remove()
	ItemSlot:ItemChanged()

	ply:Msg2("Item has been moved to your trunk.")

	hook.Call("InvRemove", GAMEMODE, ItemSlot )

end )

concommand.Add( "gm_invgrab", function( ply, command, args )
    if #args != 2 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

    local EntIndex = 	tonumber( args[1] )
	local Slot = args[2]


	if EntIndex > 0 then
		local Ent = ents.GetByIndex( EntIndex )

		if !IsValid(Ent) then
			if GTowerHackers then
				GTowerHackers:NewAttemp( ply, 1, command, args )
			end
			return
		end

		if DEBUG then
			Msg( ply, " grabbing " .. tostring( Ent ) .. " from the floor - Slot #".. tostring(Slot) ..".\n")
		end

		if Ent:GetPos():Distance( ply:GetShootPos() ) < GTowerItems.MaxDistance && IsValid( Ent ) && !Ent:IsPlayer() then
			local Owner = Ent:GetOwner()

			if !IsValid(Owner) then
				ply:InvGrabEnt( Ent, Slot )
			end
		end
	end

end )

concommand.Add( "gmt_invuse", function( ply, command, args )
	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

	ply:InvUse( args[1] )

end )

concommand.Add( "gmt_invremove", function( ply, command, args )
	if #args != 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

	ply:InvRemove( args[1] )

end )

concommand.Add( "gm_invmove", function( ply, command, args )
	if #args != 5 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

	if ply.NextInvMove && CurTime() < ply.NextInvMove then
		return
	end
	ply.NextInvMove = CurTime() + 0.1

	local EntIndex = 	tonumber( args[1] )
	local Rotation = tonumber( args[2] )
	local AimVec = Vector( tonumber( args[3] ) , tonumber( args[4] ) , tonumber( args[5] ) ):GetNormal()

	if EntIndex <= 0 then
		return
	end

	local Ent = ents.GetByIndex( EntIndex )

	if !IsValid( Ent ) then
		return
	end

	local ShootPos = ply:GetShootPos()

	if !IsValid( Ent:GetOwner() ) && !Ent:IsPlayer() && Ent:GetPos():Distance( ShootPos ) < GTowerItems.DragMaxDistance then //make sure it is a valid entity and it is not too far away

		local ItemId = GTowerItems:FindByEntity( Ent )

		if !ItemId then return end

		local Item = GTowerItems:CreateById( ItemId, ply )

		if !Item then return end

		local AllowAnywhere = ClientSettings:Get( ply, "GTAllowInvAllEnts" ) == true

		if Item.AllowAnywhereDrop then
			if Ent.PlayerOwner != ply && !( ply:IsAdmin() || ply:GetSetting( "GTAllowInvAllEnts" ) ) then
				return
			end
		end

		if !Item.AllowAnywhereDrop && !AllowAnywhere && !ply:HasControl( Ent ) then
			return false
		end

		local Trace = util.QuickTrace(
			ShootPos,
			AimVec * GTowerItems.MaxDistance,
			{ ply, Ent }
		)

		if !Item.AllowAnywhereDrop && !AllowAnywhere && hook.Call("GTowerInvDrop", GAMEMODE, ply, Trace, Item, true ) != true then
			return
		end

		local OldPos = Ent:GetPos()
		local OldAng = Ent:GetAngles()

		if Trace.Hit then

			local min = Ent:OBBMins()
			local Ang = Trace.HitNormal:Angle()

			// fix some odd issues with models!
			if AngleWithinPrecisionError(Ang.p, 270) || AngleWithinPrecisionError(Ang.p, 90) then
				Ang.y = 0
			end

			Ang:RotateAroundAxis( Ang:Right(), -90 )
			Ang:RotateAroundAxis( Ang:Up(), Rotation )

			local Pos = Trace.HitPos - Trace.HitNormal * min.z

			if ( Item.Manipulator ) then
				Pos = Item.Manipulator( Ang, Pos, Trace.HitNormal)
			end

			Ent:SetPos( Pos /*Trace.HitPos - Trace.HitNormal * min.z*/ )
			Ent:SetAngles( Ang )

			if Ent.LoadRoom && type( Ent.LoadRoom ) == "function" then
				Ent:LoadRoom()
			end

			//Feature: Only allow the player to sit on the entity if it is the local player.
			if !GTowerItems:CheckTraceHull( Ent, {Ent, ply, ply:GetVehicle() } ) then //Not a really good place to put it, eh?
				Ent:SetPos( OldPos )
				Ent:SetAngles( OldAng )
			end

			local Phys = Ent:GetPhysicsObject()
			if IsValid( Phys ) then
				Phys:EnableMotion( Item.EnablePhyiscs )
			end
		end

	end

	if DEBUG then
		Msg( ply, " moving the entity " .. tostring( Ent ) .. ".\n")
	end

end )
