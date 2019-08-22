include("shared.lua")

local usermessage = usermessage
local hook = hook


module("minigames.rabbitwar")

LocalPlayerInGame = false

usermessage.Hook("rabbitfight", function( um )

	local Id = um:ReadChar()
	
	if Id == 0 then
		AddHooks()
	elseif Id == 1 then
		RemoveHooks()
	end



end )

function InGame( ply )
	if ply == LocalPlayer() then
		return LocalPlayerInGame
	end
end

function AddHooks()

	LocalPlayerInGame = true
end

function RemoveHooks()

	
	LocalPlayerInGame = false
end