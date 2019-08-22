
function GTowerItems:EnableDebug()
	
	hook.Add("HUDPaint", "GtowerDebugInventory", function()
		local EyeTrace = LocalPlayer():GetEyeTrace()
		local Ent = EyeTrace.Entity
		
		if IsValid( Ent ) then
			local ItemId = GTowerItems:FindByEntity( Ent )
			local FontHeight = draw.GetFontHeight("Default")
			local Owner = tostring( Ent:GetDTEntity(5) )
			
			surface.SetFont("Default")
			surface.SetTextColor( 255,255,255,255 )
			
			
			if ItemId then
				local Item = GTowerItems:Get( ItemId ) 
				
				surface.SetTextPos( ScrW() / 2, ScrH() / 2 )
				surface.DrawText( Item.Name .. " ("..  ItemId..") " .. Item.UniqueName )
				
				surface.SetTextPos( ScrW() / 2, ScrH() / 2 + FontHeight + 2 )
				surface.DrawText( "Owner: ".. Owner ) 
			else
				
				surface.SetTextPos( ScrW() / 2, ScrH() / 2 )
				surface.DrawText( "ClassName: " .. Ent:GetClass() .. "(".. Ent:EntIndex() ..")" )
				
				surface.SetTextPos( ScrW() / 2, ScrH() / 2 + FontHeight + 2 )
				surface.DrawText( "Model: " .. Ent:GetModel() )
			
			end		
		end	
	end)

end

function GTowerItems:DisableEnough()
	hook.Remove("HUDPaint", "GtowerDebugInventory")
end

concommand.Add("gmt_invdebug", function( ply, cmd, args )
	
	if args[1] == "1" then
		GTowerItems:EnableDebug()
	elseif args[1] == "0" then
		GTowerItems:DisableEnough()
	else
		
		local EyeTrace = LocalPlayer():GetEyeTrace()
		local Ent = EyeTrace.Entity
		
		if IsValid( Ent ) then
			Msg("ClassName: " .. Ent:GetClass() .. "\n")
			Msg("Model: " .. Ent:GetModel() .. "\n")		
		end
		
	end

end )