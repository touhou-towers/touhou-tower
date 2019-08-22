
local EntityMeta = FindMetaTable("Entity")
local MessageName = "EntMsg"
local SavedMessages = {}

module("EntityMessages", package.seeall )




if SERVER then

	function EntityMeta:StartUmsg( um )
		
		umsg.Start( MessageName, um )
			umsg.Entity( self )
	
	end
	
	function EntityMeta:EndUmsg()	
		umsg.End()
	end

else

	usermessage.Hook( MessageName, function( um )
		
		//um.SentTime = CurTime()
		
		local Ent = um:ReadEntity()
		
		if !IsValid( Ent ) then
			//Trial: Attempt to save the user message for later use
			/*
			local Index = Ent:EntIndex()
			
			if !SavedMessages[ Index ] then
				SavedMessages[ Index ] = { um }
			else
				table.insert( SavedMessages[ Index ], um )
			end
			*/
			return
		end
		
		if type( Ent.ReceiveUmsg ) == "function" then
			Ent:ReceiveUmsg( um )
		end
	
	end )
	/*
	local function DumpEntityMessages( ent, Index )
	
		if !IsValid( ent ) then
			return
		end
		
		for _, um in pairs( SavedMessages[ Index ] ) do
			
			if CurTime() - um.SentTime < 60 && type( Ent.ReceiveUmsg ) == "function" then
				
				SafeCall( ent.ReceiveUmsg, ent, um )
				
			end
			
		end
		
		SavedMessages[ Index ] = nil
		
	end
	
	hook.Add("OnEntityCreated", "CheckOldUmsg", function( ent )
	
		local Index = ent:EntIndex()
		
		if SavedMessages[ Index ] then
			
			timer.Simple( DumpEntityMessages, ent, Index )
		
		end
	
	end )
	*/
end