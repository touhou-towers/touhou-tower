


module("InventorySaver", package.seeall )

local Mat = Material( "effects/tool_tracer" )

MinLoadPosition = Vector()
MaxLoadPosition = Vector()
OnLoadStage = false

usermessage.Hook("InvSaver", function( um )

	local MsgId = um:ReadChar()

	if MsgId == 0 then
	
		MinLoadPosition = um:ReadVector()
		MaxLoadPosition = um:ReadVector()
		OnLoadStage = true
		
		print( MinLoadPosition, MaxLoadPosition )

		util.Effect("invload_box", EffectData() )
	
	elseif MsgId == 1 then
		OnLoadStage = false
	end
	
end )