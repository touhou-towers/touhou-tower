local Textures = {
	"gmod_tower/balls/hud_message_completed",
	"gmod_tower/balls/hud_message_failed",
	"gmod_tower/balls/hud_message_endgame"
}
local PanelGui = nil
local PanelYPos = 0
local MessagEndTime = 0

local function PanelGuiThink()
	
	local TimeLeft = MessagEndTime - CurTime()
	
	if TimeLeft < 0 || !ValidPanel( PanelGui ) then
		if ValidPanel( PanelGui ) then
			PanelGui:Remove()
			PanelGui = nil
		end
	
		hook.Remove( "Think", "UpdateMsgGuiItem" )
		return
	end
	
	-- If going from the left to the middle screen
	-- Takes one second
	if TimeLeft > 8 - 1 then
		
		local Perc = 8 - TimeLeft
		local Source = PanelGui:GetWide() * -1
		local Target = ScrW() / 2 - PanelGui:GetWide() / 2
		
		PanelGui:SetPos( Source + (Target-Source) * Perc, PanelYPos )
		
	elseif TimeLeft <= 1 then //Going away into the right
		
		local Perc = TimeLeft
		local Source = ScrW() / 2 - PanelGui:GetWide() / 2
		local Target = ScrW() + 1
		
		PanelGui:SetPos( Source + (Target-Source) * (1-Perc), PanelYPos )
		
	else //Standing in the middle of screen
		
		PanelGui:SetPos( ScrW() / 2 - PanelGui:GetWide() / 2, PanelYPos )
		
	end
	

end

function ShowHudMessage( id )
	
	if ValidPanel( PanelGui ) then
		PanelGui:Remove()
		PanelGui = nil
	end
	
	MessagEndTime = CurTime() + 8
	
	PanelGui = vgui.Create("DImage")
	PanelGui:SetImage( Textures[ id ] )
	PanelGui:SizeToContents()
	
	PanelYPos = ScrH() / 2 - PanelGui:GetTall() / 2
	
	PanelGui:SetPos( PanelGui:GetWide() * -1, PanelYPos )
	
	hook.Add("Think", "UpdateMsgGuiItem", PanelGuiThink )

end

net.Receive( "roundmessage", function( len, pl )
	local Id = net.ReadInt(3)
	ShowHudMessage(Id)
end )

/*
function UpdateState(world, name, old, new)
	if new == STATE_INTERMISSION then
		timer.Simple( 0.0, ShowHudMessage, new )
	end
end
*/