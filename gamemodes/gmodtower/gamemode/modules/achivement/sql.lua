
hook.Add("SQLStartColumns", "SQLLoadAchivements", function()
	SQLColumn.Init( {
		["column"] = "achivement",
		["selectquery"] = "HEX(achivement) as achivement",
		["selectresult"] = "achivement",
		["update"] = function( ply )
			return GtowerAchivements:GetData( ply )
		end,
		["defaultvalue"] = function( ply )
			GtowerAchivements:Load( ply, 0x0 )
		end,
		["onupdate"] = function( ply, val )
			GtowerAchivements:Load( ply, val )
		end,
		["UnimportantUpdate"] = true
	} )
end )

function GtowerAchivements:GetData( ply )

	if !ply._Achivements then
		return
	end

	local Data = Hex()

	for k, v in pairs( ply._Achivements ) do
		Data:SafeWrite( k )
		Data:SafeWrite( math.floor( v ) )
	end

	return Data:Get()

end

function GtowerAchivements:NetworkUpdate( ply, id )

	if !ply._AchivementNetwork then
		ply._AchivementNetwork = { id }

	elseif !table.HasValue( ply._AchivementNetwork, id ) then
		table.insert( ply._AchivementNetwork, id )

	end

	ClientNetwork.AddPacket( ply, "AchivementNetwork", GtowerAchivements.PlayerNetworkSend )

end


function GtowerAchivements:Load( ply, val )

	ply._Achivements = {}

	local Data = Hex( val )

	while Data:CanRead( 1 ) do

		local k = Data:SafeRead()
		local v = Data:SafeRead()

		if k then
			ply._Achivements[ k ] = v or 0
		end

	end

end
