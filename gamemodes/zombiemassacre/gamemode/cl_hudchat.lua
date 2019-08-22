
-----------------------------------------------------
module( "FloatingChat", package.seeall )
Text = {}
TextColor		= Color( 250, 250, 250, 255 )
BGColor 		= Color( 20, 20, 20, 128 )
Font			= "Trebuchet18"
local function IsLookingTowards( ply, vect )
	local dot = ply:GetAimVector():DotProduct( ( vect - ply:GetPos() ):GetNormal() )
	return dot < 1
end
function Draw( id, chat )
	local ply = chat.Player
	chat.Alpha = math.Approach( chat.Alpha, chat.CurAlpha, FrameTime() * 800 )
	BGColor.a = ( chat.Alpha / 2 ) / id
	TextColor.a = chat.Alpha / id
	if chat.DieTime < CurTime() then
		chat.CurAlpha = 0
		if chat.Alpha == 0 then
			table.remove( FloatingChat.Text, id )
			return
		end
	end
	if !IsValid( ply ) || !ply:Alive() then return end
	if IsLookingTowards( LocalPlayer(), ply:GetPos() ) || LocalPlayer() == ply then
		local pos = ply:GetShootPos()
		// Try to get head bone			
		local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )
		if head then
			local bonepos, boneang = ply:GetBonePosition( head )
			if bonepos then
				pos = bonepos
			end
		end
		local pos = pos:ToScreen()
		local text = chat.Text
		// Get size
		surface.SetFont( Font )
		local w,h = surface.GetTextSize( text )
		// Draw it
		if LocalPlayer():GetPos():Distance( ply:GetPos() ) < 1000 then
			chat.ApproachY = math.Approach( chat.ApproachY, ( id * 28 ), FrameTime() * 80 )
			pos.y = pos.y + chat.ApproachY
			pos.x = pos.x - w / 2 - 5
			draw.WordBox( 4, pos.x, pos.y, text, Font, BGColor, TextColor )
		end
	end
end
hook.Add( "HUDPaint", "FloatingPaint", function()
	for id, chat in pairs( FloatingChat.Text ) do
		FloatingChat.Draw( id, chat )
	end
end )
hook.Add( "OnPlayerChat", "FloatingChat", function( ply, text, teamtext, alive )
	if IsValid( ply ) && text != "" then
		local chat = {}
			chat.Text = text
			chat.DieTime = CurTime() + 5
			chat.Player = ply
			chat.Alpha = 0
			chat.CurAlpha = 255
			chat.ApproachY = 0
		table.insert( FloatingChat.Text, 1, chat )
		if #FloatingChat.Text > 3 then
			table.remove( FloatingChat.Text, #FloatingChat.Text )
		end
	end
end )