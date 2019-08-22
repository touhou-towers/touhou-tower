
include("shared.lua")
include("cl_selectweapon.lua")
include("cl_closebutton.lua")

PvpBattle.SelectedItems = {}

usermessage.Hook("PvpB", function( um ) 

	local Id = um:ReadChar()
	
	if Id == 1 then		
		local OpenStore = um:ReadBool()
		
		local Count = um:ReadChar()
		PvpBattle.SelectedItems = {}
		
		for i=1, Count do
			local Id = um:ReadChar()
			local Value = um:ReadShort() + 32768
			
			PvpBattle.SelectedItems[ Id ] = Value
		end	
		
		if PvpBattle.DEBUG then
			Msg("PVPBATLE: Recienved selected weapons: \n")
			PrintTable( PvpBattle.SelectedItems )
		end
		
		local discount = um:ReadFloat()
		hook.Call("PvpBattleUpdate", GAMEMODE, OpenStore, discount )
		
	end

end )