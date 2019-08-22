

-----------------------------------------------------
-- Extra net library functions
module( "net", package.seeall )

/*
	WriteBool(Boolean)
	Total Bits:
		* 1 bit
*/
function WriteBool(Boolean)

	net.WriteBit( Boolean )

end

function ReadBool()

	return (net.ReadBit() == 1)

end

/*
	WriteAngle2(Angle)
	Total Bits: 
		* 30 Bits
*/
function WriteAngle2( Angle ) -- Needa save dem bits

	local ang = Angle:Normalize()

	ang.p, ang.y, ang.r = math.Round(ang.p), math.Round(ang.y), math.Round(ang.r)

	if ang.p < 0 then 
		ang.p = ang.p * -1
		net.WriteBit( true )
	else
		net.WriteBit( false ) 
	end

	if ang.y < 0 then 
		ang.y = ang.y * -1
		net.WriteBit( true )
	else
		net.WriteBit( false ) 
	end

	if ang.r < 0 then 
		ang.r = ang.r * -1
		net.WriteBit( true )
	else
		net.WriteBit( false ) 
	end

	local packedAngle = bit.lshift(bit.band(Angle.p, 0x1FF), 18) + bit.lshift(bit.band(Angle.y, 0x1FF), 9) + bit.band(Angle.r, 0x1FF)
	net.WriteInt( packedAngle, 27 )

end

function ReadAngle2()

	local pNeg, yNeg, rNeg = (net.ReadBit()==1), (net.ReadBit()==1), (net.ReadBit()==1)
	local packedAngle = net.ReadInt( 27 )
	local p,y,r = bit.band(bit.rshift( packedAngle, 18 ), 0x1FF), bit.band(bit.rshift( packedAngle, 9 ), 0x1FF), bit.band( packedAngle, 0x1FF )
	if pNeg then p = p * -1 end
	if yNeg then y = y * -1 end
	if rNeg then r = r * -1 end
	return Angle( p, y, r )

end

/*
	WriteChar(Character)
		Total Bits: 8
*/
function WriteChar(Character)

	net.WriteInt( Character, 8 )

end

function ReadChar()

	return net.ReadInt( 8 )

end

/*
	WriteShort(Short)
		Total Bits: 16
*/
function WriteShort( Short )

	net.WriteInt( Short, 16 )

end

function ReadShort( )

	return net.ReadInt( 16 )

end


/*
	WriteLong(Long)
		Total Bits: 32
*/
function WriteLong( Long )

	net.ReadInt( Long, 32 )

end

function ReadLong()

	return net.ReadInt( 32 )

end

/*
	WritePlayer( ply )
		Total Bits: 8
*/
function WritePlayer( ply )

	if not ply:IsValid() then return end
	net.WriteInt( ply:EntIndex(), 8 )

end

function ReadPlayer()

	return ents.GetByIndex( net.ReadInt( 8 ) )

end

/*
	https://developer.valvesoftware.com/wiki/SteamID
	WriteSteamID( steamId )
		Total Bits: 29 bits
*/
function WriteSteamID( steamId )

	local Type = tonumber( string.sub( steamId, 7, 7 ) ) -- 2 bits
	local ID = string.sub( steamId, 11 ) -- 28 bits, bits don't need to be changed for a while
	print( "Type: "..Type )
	print( "ID: "..ID )
	//bit.lshift(bit.band(Angle.p, 0x1FF), 18)
	// 1073741823 = (2^28) - 1
	// 1073741823 = Max steam ID
	// 4 = (2^2) - 1
	local PackedSteamID = bit.lshift( bit.band( ID, 0x40000000 ), 30 ) + bit.band( Type, 0x3 )
	
	net.WriteInt( PackedSteamID, 32 )

end

function ReadSteamID()

	local Recive = net.ReadInt( 32 )
	print(Recive)
	local ID = bit.band( bit.rshift( Recive, 30 ), 0x40000000 )
	local Type = bit.band( Recive, 0x3 )
	return "STEAM_0:"..Type..":"..ID

end

function BroadcastRP( rp )

	if( !IsValid(rp) ) then return end
	local plyList = rp:GetPlayers()
	for _, v in pairs(plyList) do
		if( IsValid(v) ) then net.Send( v ) end
	end

end