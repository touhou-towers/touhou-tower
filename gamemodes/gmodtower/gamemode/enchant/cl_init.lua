
include('shared.lua')
include("sh_base.lua")
include("sh_hook.lua")
include("sh_load.lua")

module("enchant", package.seeall )

function New( Name, ply )
	
	local NewItem = _New( Name, ply or LocalPlayer(), false )
	
	NewItem:Init()
	
	return NewItem
	
end


function _Removed( item )
	item:OnRemove()
end

Items = {}

usermessage.Hook("enchant", function( um )
	
	local Id = um:ReadChar()
	
	if DEBUG then
		print("Recieve NW: id = " .. Id .. "\n")
	end
	
	if Id == 0 then
		
		local ItemId = um:ReadShort()
		
		if Items[ ItemId ] then
			if DEBUG then
				Msg("Custom msg: " .. Items[ ItemId ]._Type .. "\n" )
			end
		
			Items[ ItemId ]:RecieveUmsg( um )
		else
			ErrorNoHalt("Item of invalid ID (".. ItemId ..")")
		end
	
	elseif Id == 1 then
		
		local Name = um:ReadString()
		local ItemId = um:ReadShort()
		local Player = um:ReadEntity()
		local DieTime
		
		if um:ReadBool() == true then
			DieTime = um:ReadFloat()
		end
		
		local NewItem = _New( Name, Player )
		
		NewItem._Id = ItemId
		Items[ ItemId ] = NewItem
		
		if DieTime then
			NewItem._DieTime = DieTime
		end
		
		NewItem:Init( um )
		
		if DEBUG then
			Msg("New enchant: " .. Name .. " ("..ItemId..") - " .. tostring(Player) .. " - " .. tostring(DieTime) .."\n" )
		end
		
	elseif Id == 2 then
		
		local ItemId = um:ReadShort()
		
		if Items[ ItemId ] then
			Items[ ItemId ]:_Destroy( um )
			
			if DEBUG then
				Msg("Custom DESTROY: " .. Items[ ItemId ]._Type .. "\n" )
			end
			
		end
		
		Items[ ItemId ] = nil
		
	elseif Id == 3 then
		
		local ItemId = um:ReadShort()
		local DieTime = um:ReadFloat()
		
		if Items[ ItemId ] then
			Items[ ItemId ]._DieTime = DieTime
		end
		
		if DEBUG then
			Msg("Updating dietime (".. ItemId .."):".. DieTime .."\n")
		end
		
	end
	

end )