
local meta = FindMetaTable("Player")

if !meta then
	ErrorNoHalt("ERROR: Could not find Player meta table!")
	return
end

function meta:SetAchivement( id, value, add )

	if !self._Achivements then
		//ErrorNoHalt("Attention: Setting achivement: " .. id .. " before the player was loaded.\n")
		return
	end

	local Achivement = GtowerAchivements:Get( id )

	if !Achivement then
		ErrorNoHalt("Attention: Setting achivement: " .. id .. " that does not exist.\n")
		return
	end

	local OldValue = self._Achivements[ id ]

	if Achivement.BitValue == true && add then

		if add > Achivement.Value || add < 0 then
			Msg("ERROR: Achivement ".. Achivement.Name .." Adding bit bigger than Achivement.Value\n")
			return
		end

		local ActualValue = math.pow( 2, add )

		self._Achivements[ id ] = bit.bor( OldValue or 0, ActualValue )

		//Msg("Adding value: " .. ActualValue .. " ("..add..")\n")
		//Msg("ActualValue value: " .. self._Achivements[ id ] .. " (".. self:GetAchivement( id ) ..")\n")
		//Msg("\t" .. table.concat( bit.tobits( self._Achivements[ id ] ), ",") .. "\n")

	else

		if add then
			value = value + add
		end

		self._Achivements[ id ] = math.Clamp( value, 0, Achivement.Value )
	end


	if OldValue != self._Achivements[ id ] && self:GetAchivement( id ) == Achivement.Value then
		umsg.Start( "GTAchWin", self )
			umsg.Short( id )
		umsg.End()

		local sfx = EffectData()
			sfx:SetOrigin( self:GetPos() )
		util.Effect( "confetti", sfx, true, true )

		self:EmitSound( "GModTower/music/award.wav", 100, 100 )
		self:AddMoney( ( Achivement.GMC or 500 ) )

		for k,v in ipairs( player.GetAll() ) do
			if IsValid( v ) then
				--v:ChatPrint( self:Name() .. " just achieved " .. Achivement.Name )
				local SanitizedName = SafeChatName(self:Name())
				v:SendLua([[GTowerChat.Chat:AddText( "]]..SanitizedName..[[ earned the achievement ]]..Achivement.Name..[[",Color( 255, 200, 0 ) )]])
			end
		end

		hook.Call("Achivement", GAMEMODE, self, id )
	end
end

function meta:GetAchivement( id, raw )

	if !self._Achivements then
		ErrorNoHalt("Attention: Getting achivement: " .. id .. " before the player was loaded.\n")
		ErrorNoHalt( debug.traceback() )
		return 0
	end

	local Achivement = GtowerAchivements:Get( id )
	if Achivement && Achivement.BitValue == true && self._Achivements[ id ] then
		if raw != true then
			local PlyVal = bit.tobits( self._Achivements[ id ] )
			local Value = 0

			for _, v in pairs( PlyVal ) do
				if v == 1 then
					Value = Value + 1
				end
			end

			return Value

		end
	end

	return self._Achivements[ id ] or 0

end

function meta:AddAchivement( id, value )

	self:SetAchivement( id, self:GetAchivement( id ), value )

	return

end

function meta:Achived( id )
	local Achivement = GtowerAchivements:Get( id )

	if Achivement then
		return self:GetAchivement( id ) == Achivement.Value
	end
end

function meta:AchivementLoaded()
	return self._Achivements != nil
end
