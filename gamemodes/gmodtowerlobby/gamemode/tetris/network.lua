local umsg = umsg
local hook = hook
local ClientNetwork = ClientNetwork
local Msg = Msg
local pairs= pairs

module("tetrishighscore")

local Groups = {
	{1,2,3,4,5},
	{6,7,8,9,10}
}

local function CheckGroup( ply, group )

	if !ply._SendTetrisHigh then
		ply._SendTetrisHigh = {}
	end
	
	for _, v in pairs( group ) do
		
		if HighScore[ v ] && ply._SendTetrisHigh[ v ] != HighScore[ v ][3] then
			return true
		end
	
	end
	
	return false

end

function SendItemsToPlayer( ply, groupid )
	
	local group = Groups[ groupid ]
	
	if CheckGroup( ply, group ) == true then
		
		umsg.Start("TetHiS", ply )
			umsg.Char( 0 )
			umsg.Char( group[1] )
			
			for _, v in pairs( group ) do
				
				local score = HighScore[ v ]
				
				if score then
					umsg.String( score[2] )
					umsg.Short( score[3] )
				else
					umsg.String("")
					umsg.Short( 0 )
				end
				
			end
			
		umsg.End()
		
	end

end

function SendNetworkPackets( ply )
	
	for k, v in pairs( Groups ) do
		if CheckGroup( ply, v ) == true then
			ClientNetwork.AddPacket( ply, "SendTetrisHigh" .. k , SendItemsToPlayer, k )
		end
	end

end

hook.Add("SQLConnect", "SendTetrisHighScores", SendNetworkPackets )