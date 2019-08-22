module("NetworkQueue", package.seeall )

List = {}

local function Hook()
	hook.Add("Think", "NetworkQueue", Think )
end

function UnHook()
	hook.Remove("Think", "NetworkQueue" )
end

function Add( ply, func, ... )

	if ply == nil then
		for _, v in ipairs( player.GetAll() ) do
			self.AddPacket( v, name, func, ... )
		end
		return
	end

	local Item = {
		Func = func,
		args = {...}
	}

	if !List[ ply ] then
		List[ ply ] = {
			NextCall = 0,
			Items = {}
		}
	end

	table.insert( List[ ply ].Items, Item )

	Hook()

end

local function PlayerThink( ply, items )

	for k, v in pairs( items ) do

		local b, rtn = SafeCall( v.Func, ply, unpack( v.args ) )

		if b then

			if rtn == true then
				return true
			end

			items[ k ] = nil

		else
			items[ k ] = nil
		end

	end

	return false

end

local function RemovePlayer( ply )

	List[ ply ] = nil

	if table.Count( List ) == nil then
		return
	end

end

function Think()

	local Time = CurTime()
	local NextThink = CurTime() + 0.1

	for ply, obj in pairs( List ) do

		if !IsValid( ply ) then
			RemovePlayer( ply )
		else

			if Time > obj.NextCall then

				if PlayerThink( ply, obj.Items ) == false then
					RemovePlayer( ply )
				end

				obj.NextCall = NextThink

			end

		end

	end

end
