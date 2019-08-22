
module( "emote", package.seeall )

// List of emotes available
Commands = {
	[1] = "agree",
	[2] = "beckon",
	[3] = "bow",
	[4] = "disagree",
	//[5] = "give",
	[5] = "group",
	[6] = "no",
	[7] = "dance",
	[8] = "sexydance",
	[9] = "sit",
	[10] = "wave",
	[11] = "yes",
	[12] = "taunt",
	[13] = "cheer",
	//[14] = "zombie",
	[14] = "flail",
	[15] = "laugh",
	[16] = "suicide",
	[17] = "lay",
	[18] = "robot",
}

SitAnims = {
	"sit_zen",
	"zombie_slump_idle_02",
}

function IsEmoting( ply )

	return ply:GetNWBool("Emoting") --ply.EmoteID && ply.EmoteID > 0

end

hook.Add( "CalcMainActivity", "Sitting", function( ply )

	if ply:GetNWBool("Sitting") then

		if ply:GetModel() == "models/player/midna.mdl" then
			return ply.CalcIdeal, ply:LookupSequence( "midna_sit" )
		end

		ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_BUSY_SIT_GROUND, true )
		return ply.CalcIdeal, ply:LookupSequence( SitAnims[1] )

	end

	if ply:GetNWBool("Laying") then

		if ply:GetModel() == "models/player/midna.mdl" then
			return ply.CalcIdeal, ply:LookupSequence( "midna_lay" )
		end

		return ply.CalcIdeal, ply:LookupSequence( "zombie_slump_idle_01" )

	end
end )

---
module( "emote", package.seeall )
surface.CreateFont( "MikuHUDMainLarge", { font = "Oswald", size = 38, weight = 400 } )
surface.CreateFont( "MikuHUDMain", { font = "Oswald", size = 24, weight = 400 } )
usermessage.Hook( "EmoteSit", function( um )

	local ply = ents.GetByIndex( um:ReadShort() )
	if IsValid( ply ) then
		ply.IsSitting = um:ReadBool() or false
		ply.SitAnim = um:ReadChar() or 1
	end

end )

usermessage.Hook( "EmoteLay", function( um )

	local ply = ents.GetByIndex( um:ReadShort() )
	if IsValid( ply ) then
		ply.IsLaying = um:ReadBool() or false
	end

end )

RADIAL = nil

local gradient = surface.GetTextureID( "VGUI/gradient_up" )
local gradientdown = surface.GetTextureID( "VGUI/gradient_down" )
function string.Uppercase( str )

	return str:gsub("^%l", string.upper)

end
hook.Add( "GtowerShowContextMenus", "ShowEmote", function()

	if ValidPanel( RADIAL ) then
		RADIAL:Remove()
	end

	RADIAL = vgui.Create( "DRadialMenu" )
	RADIAL:SetSize( ScrH(), ScrH() )
	-- RADIAL:SetPaintDebug( true )
	-- RADIAL:SetRadiusPadding( 50 )
	RADIAL:SetRadiusScale( 0.5 )
	-- RADIAL:SetDegreeOffset( 90 )
	-- RADIAL:SetAlignMode( RADIAL_ALIGN_CENTER )
	RADIAL:Center()
	RADIAL:SetPaintSelectColor( Color( 0, 150, 255, 255 ) )
	-- RADIAL:MakePopup()
	/*RADIAL.Paint = function( self, w, h )
		local x, y = self:LocalCursorPos()
		surface.SetDrawColor( Color( 16, 77, 121, 200 ) )
		for i=0, 4 do
			surface.DrawLine( w/2, h/2, x + i, y + i )
		end
	end*/

	local commands = emote.Commands

	if UCHAnim && UCHAnim.IsPig( LocalPlayer() ) then
		commands = { "taunt", "wave" }
	end

	-- Add items
	for id, emote in ipairs( commands ) do
		if emote == "taunt" && !( UCHAnim && UCHAnim.IsPig( LocalPlayer() ) ) then
			continue
		end

		local name = string.Uppercase( emote )
		if emote == "sexydance" then name = "Sexy Dance" end
		if emote == "danceforever" then name = "Dance 2" end

		local p = vgui.Create( "DButton" )
		p:SetSize( 80, 30 )
		p:SetFont( "MikuHUDMain" )
		p:SetColor( Color( 255, 255, 255 ) )
		p:SetText( name )
		p.DoClick = function(self)
			RunConsoleCommand( "say", "/" .. emote )
			net.Start( "EmoteAct" )
				net.WriteString(emote)
			net.SendToServer()
			GtowerMainGui:GtowerHideContextMenus()
		end
		p.Paint = function( self, w, h )
			p:SetColor( Color( 255, 255, 255, 150 ) )
			draw.RoundedBox( 8, 0, 0, w, h, Color( 16, 77, 121, 150 ) )
			/*surface.SetDrawColor( Color( 16, 77, 121, 200, 255 ) )
			surface.SetTexture( gradient )
			surface.DrawTexturedRect( 0, 0, w, h )*/

			if self.Hovered then
				p:SetColor( Color( 255, 255, 255 ) )
				/*surface.SetDrawColor( Color( 16 + 60, 77 + 60, 121 + 60, 255 ) )
				surface.SetTexture( gradient )
				surface.DrawTexturedRect( 0, 0, w, h )*/
				//surface.DrawRect( 0, 0, w, h )
				draw.RoundedBox( 8, 0, 0, w, h, Color( 16 - 30, 77 - 30, 121 - 30, 255 ) )
				draw.RoundedBox( 8, 0, 0, w, h - 2, Color( 16 + 30, 77 + 30, 121 + 30, 255 ) )
			end
		end

		RADIAL:AddItem( p )
		-- RADIAL:AddItem( p, math.Rand(10,35) )
	end

	local p = vgui.Create( "DLabel" )
		p:SetSize( ScrH() / 8, 30 )
		p:SetText( "EMOTE" )
		p:SetColor( Color( 255, 255, 255 ) )
		p:SetFont( "MikuHUDMainLarge" )
		p:SetContentAlignment(5)
		p.Paint = function( self, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, Color( 16 - 30, 77 - 30, 121 - 30, 225 ) )
		end
	RADIAL:SetCenterPanel( p )

end )

hook.Add( "GtowerHideContextMenus", "HideEmote", function()
	if ValidPanel( RADIAL ) then
		RADIAL:Remove()
	end

end )

hook.Add( "UpdateAnimation", "EmoteControlHead", function( ply )

	if ply:GetNWBool("Sitting") then

		local aim = ply.CameraAngle or Angle( 0, 0, 0 )

		if !ply.BodyAngle then
			ply.BodyAngle = aim.y
		end

		ply:SetPoseParameter( "breathing", 0.4 )
		ply:SetPoseParameter( "head_pitch", aim.p - 30 )
		//ply:SetPoseParameter( "head_yaw", math.NormalizeAngle( aim.y - ply.BodyAngle ) )

	else
		ply.BodyAngle = nil
	end
end )
