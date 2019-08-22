/*local DEBUG = false

local function SendBallId( ply )
	umsg.Start("GtBall", ply )
		umsg.Char( 1 )
		umsg.Char( ply._PlyChoosenBall )
	umsg.End()
end

local function SetBallId( ply, BallId )
	BallId = tonumber(BallId)

	if BallId == 2 && ply:GetLevel("BallRacerCube") == 1 then
		ply._PlyChoosenBall = 2
	elseif BallId == 3 && ply:GetLevel("BallRacerIcosahedron") == 1 then
		ply._PlyChoosenBall = 3
	elseif BallId == 4 && ply:GetLevel("BallRacerCatBall") == 1 then
		ply._PlyChoosenBall = 4
	elseif BallId == 5 && ply:IsAdmin() then
		ply._PlyChoosenBall = 5
	else
		ply._PlyChoosenBall = 1
	end

	SendBallId( ply )

	hook.Call("ChangeBall", GAMEMODE, ply, ply._PlyChoosenBall )

end

hook.Add("SQLStartColumns", "SQLGetBall", function()
	GTowerSQL:NewColumn( {
		["column"] = "ball",
		["update"] = function( ply )
			return tonumber( ply._PlyChoosenBall ) or 1
		end,
		["defaultvalue"] = function( ply, onstart )
			SetBallId( ply, 1 )
		end,
		["onupdate"] = function( ply, val )
			// can't call SetBallId yet, so let it be corrected later
			ply._PlyChoosenBall = val
		end
	} )
end )

local function PlayerSendLevels( ply )

	if !ply.SQL then
		return
	end

	SetBallId(ply, ply._PlyChoosenBall or 1)

	local CanCube = ply:GetLevel("BallRacerCube") == 1
	local CanIcosahedron = ply:GetLevel("BallRacerIcosahedron") == 1
	local CanCatBall = ply:GetLevel("BallRacerCatBall") == 1

	if DEBUG then
		Msg( ply, " sql connect: ", CanCube, " ", CanIcosahedron )
	end

	umsg.Start("GtBall", ply )
		umsg.Char( 0 )
		umsg.Bool( CanCube )
		umsg.Bool( CanIcosahedron )
		umsg.Bool( CanCatBall )
	umsg.End()

end

hook.Add("SQLConnect", "SendPlayerBallLevels", PlayerSendLevels )
hook.Add("PlayerInitialSpawn", "SendPlayerBallLevels", PlayerSendLevels )

concommand.Add("gmt_setball", function( ply, cmd, args )

	local BallId = tonumber( args[1] )

	if BallId then
		SetBallId( ply, BallId )
	end

end )*/
