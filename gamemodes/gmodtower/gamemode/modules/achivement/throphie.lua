
hook.Add("Achivement", "GiveThrophie", function( ply, id )

	local Achivement = GtowerAchivements:Get( id )
	
	if Achivement.GiveItem then
	
		local ItemId = GTowerItems:FindByFile( Achivement.GiveItem )
		
		if ply:HasItemById( ItemId ) then 
			return
		end
		
		if !ItemId then
			Error("Could not give ".. Achivement.Name .. " thophy " .. tostring(Achivement.GiveItem) )
		end
	
		local Item = GTowerItems:CreateById( ItemId, ply ) 
		local Slot = GTowerItems:NewItemSlot( ply, "-2" ) //In the bank!
		
		if !Item then
			ply:Msg2( T("AchievementsTrophyFailed") )
		return end

		ply:Msg2( T("AchievementsTrophyGot", Item.Name) )

		if Achivement.NotGiveSlot != true then
			//You are getting a raise! A free slot!
			ply:SetMaxBank( ply:BankLimit() + 1 )
		end
		
		Slot:FindUnusedSlot( Item, true )
		
		if !Slot:IsValid() then
			return
		end
		
		Slot:Set( Item )	
		Slot:ItemChanged()
	
	end

end )

concommand.Add("gmt_resettrophies", function( ply, cmd, args )
	
	if !GtowerRooms then
		//The item could be in the suite :/
		return
	end
	
	if ply._TrophiesReset && ply._TrophiesReset > CurTime() then
		return
	end
	
	ply._TrophiesReset = CurTime() + 1.0
	
	local TrophiesGiven = 0
	
	for k, Achivement in pairs( GtowerAchivements.Achivements ) do
		
		if ply:Achived( k ) && Achivement.GiveItem then
			
			local ItemId = GTowerItems:FindByFile( Achivement.GiveItem )
			
			if !ply:HasItemById( ItemId ) then 
				
				local Item = GTowerItems:CreateById( ItemId , ply ) 
				local Slot = GTowerItems:NewItemSlot( ply, "-2" ) //In the bank!
				
				if Item then
				
					Slot:FindUnusedSlot( Item, true )
					
					if Slot:IsValid() then
						Slot:Set( Item )	
						Slot:ItemChanged()
						TrophiesGiven = TrophiesGiven + 1
					end
					
				end
				
			end
			
		end
		
	end

	if TrophiesGiven > 0 then
		
		umsg.Start("GTAchRest", ply )
			umsg.Char( TrophiesGiven )
		umsg.End()
		
	end

end )