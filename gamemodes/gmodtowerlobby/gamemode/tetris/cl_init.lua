local usermessage = usermessage
local _G = _G
local ents = ents
local IsValid = IsValid
local Msg = Msg
local GTowerChat = GTowerChat
local Color = Color
local LocalPlayer = LocalPlayer
local string = string
local pairs = pairs

module("tetrishighscore")

Score = {}

function PrintTetris()
	
	Msg("Tetris high score: \n")
	for k, v in pairs( Score ) do
		Msg("\t #",k,": ", v[1] ,"\t(",v[2],")\n")
	end
	
end

usermessage.Hook("TetHiS", function( um )
	
	local UmsgId = um:ReadChar() 
	
	if UmsgId == 0 then
		local IdStart = um:ReadChar()
		
		for i=0, 4 do
			
			local Name = um:ReadString()
			local PlyScore = um:ReadShort()
			
			if string.len( Name ) > 3 then
				Score[ IdStart + i ] = { Name, PlyScore }
			end
			
		end

	
	elseif UmsgId == 1 then
		
		local plyid = um:ReadChar()
		local Position = um:ReadLong()
		local ply = ents.GetByIndex( plyid )
		
		if IsValid( ply ) && ply:IsPlayer() && GTowerChat.Chat then
			GTowerChat.Chat:AddText("Tetris: "..ply:Name().. " is #".. Position.. " in tetris.", Color(255,255,255,255), GTowerChat.Chat:GetFilterForType("Server"))
			
			if ply == LocalPlayer() then
				PrintTetris()
			end
		end
		
	end
	
end ) 