include("shared.lua")

local usermessage = usermessage
local hook = hook
local SafeCall = SafeCall
local RunConsoleCommand = RunConsoleCommand
local tostring = tostring
local _G = _G

module("minigames.obamasmash")

usermessage.Hook("obamasmash", function( um )

	local Id = um:ReadChar()
	
	if Id == 0 then
		AddHooks()
		GetLocation = um:ReadChar()
	elseif Id == 1 then
		SafeCall( RemoveHooks )
		
		local MoneyEarned = um:ReadLong()
		
		_G.Msg2("A total of " .. tostring(MoneyEarned) .. " GMC was created in this Minigame.")
		
	end

end )


function AddHooks()
	
	//hook.Add("ShouldCollide", "LobbyColide", ShouldCollide )

end

function RemoveHooks()
	
	RunConsoleCommand("r_cleardecals")
	//hook.Remove("ShouldCollide", "LobbyColide" )
	

end