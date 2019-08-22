

-----------------------------------------------------
module( "PlayerMenu", package.seeall )

RADIAL = nil
PlayerMenuEnabled = CreateClientConVar( "gmt_playermenu", 1, true, false )

Commands = {
	{
		"Add To Group",
		function( ply )
			RunConsoleCommand( "gmt_groupinvite", ply:EntIndex() )
		end,
		function( ply )
			return !GTowerGroup:IsInGroup( ply ) && !GTowerGroup:IsInGroup( LocalPlayer() )
		end
	},
	{
		"Trade",
		function( ply )
			RunConsoleCommand( "gmt_trade", ply:EntIndex() )
		end,
		function( ply )
			return true
		end
	},
	{
		"Friend",
		function( ply )
			LocalPlayer():ConCommand( "gmt_friend " .. ply:SteamID64() )
		end,
		function( ply )

			if !file.Exists("gmtower/friends.txt", "DATA") then return true end

			local Friends = string.Explode(" ", file.Read("gmtower/friends.txt", "DATA"))
			return !table.HasValue( Friends, ply:SteamID64() )
		end
	},
	{
		"Unfriend",
		function( ply )
			LocalPlayer():ConCommand( "gmt_unfriend " .. ply:SteamID64() )
		end,
		function( ply )

			if !file.Exists("gmtower/friends.txt", "DATA") then return false end

			local Friends = string.Explode(" ", file.Read("gmtower/friends.txt", "DATA"))
			return table.HasValue( Friends, ply:SteamID64() )
		end
	},
	{
		"Block",
		function( ply )
			BlockPlayer(ply)
		end,
		function( ply )

			if !file.Exists("gmtower/blocks.txt", "DATA") then return true end

			local Blocks = string.Explode(" ", file.Read("gmtower/blocks.txt", "DATA"))
			return !table.HasValue( Blocks, ply:SteamID64() )
		end
	},
	{
		"Unblock",
		function( ply )
			BlockPlayer(ply)
		end,
		function( ply )

			if !file.Exists("gmtower/blocks.txt", "DATA") then return false end

			local Blocks = string.Explode(" ", file.Read("gmtower/blocks.txt", "DATA"))
			return table.HasValue( Blocks, ply:SteamID64() )
		end
	},
	{
		"Slay",
		function( ply )
			RunConsoleCommand( "gt_act", "slay", ply:EntIndex() )
		end,
		function( ply )
			return LocalPlayer():IsAdmin()
		end,
		Color( 121, 121, 0, 200 )
	},
	{
		"Cancel",
		nil,
		function( ply )
			return true
		end,
		Color( 121, 0, 0, 200 )
	},
}

function Show( ply )

	if !PlayerMenuEnabled:GetBool() then return end

	--Hide()
	--GTowerMainGui:ToggleCursor( true )

	gui.EnableScreenClicker( true )
	RADIAL = vgui.Create( "DRadialMenu" )
	RADIAL:SetSize( ScrH(), ScrH() )
	-- RADIAL:SetPaintDebug( true )
	-- RADIAL:SetRadiusPadding( 50 )
	RADIAL:SetRadiusScale( 0.35 )
	-- RADIAL:SetDegreeOffset( 90 )
	-- RADIAL:SetAlignMode( RADIAL_ALIGN_CENTER )
	RADIAL:Center()
	-- RADIAL:MakePopup()
	/*RADIAL.Paint = function( self, w, h )
		local x, y = self:LocalCursorPos()
		surface.SetDrawColor( Color( 16, 77, 121, 200 ) )
		for i=0, 4 do
			surface.DrawLine( w/2, h/2, x + i, y + i )
		end
	end*/

	-- Add items
	for id, info in ipairs( Commands ) do

		local name = info[1] //string.Uppercase( info[1] )
		local func = info[2]
		local available = info[3]
		local color = info[4] or Color( 16, 77, 121, 200 )

		if !available || !available( ply ) then continue end

		local p = vgui.Create( "DButton" )
		p:SetSize( 150, 30 )
		p:SetFont( "GTowerHUDMain" )
		p:SetColor( Color( 255, 255, 255 ) )
		p:SetText( name )
		p.DoClick = function( self )
			if func then
				func( ply )
			end
			Hide()
		end

		p.Paint = function( self, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, color )

			if self.Hovered then
				draw.RoundedBox( 8, 0, 0, w, h, Color( color.r + 60, color.g + 60, color.b + 60, 255 ) )
			end
		end

		RADIAL:AddItem( p )
		-- RADIAL:AddItem( p, math.Rand(10,35) )
	end

	local p = vgui.Create( "DLabel" )
	p:SetSize( 100, 30 )
	p:SetText( string.upper( ply:Name() ) )
	p:SetColor( Color( 255, 255, 255 ) )
	p:SetFont( "GTowerHUDMainLarge" )
	p:SetContentAlignment(5)
	p:SizeToContents()
	p:SetWide( p:GetWide() + 10 )
	p.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, Color( 16 - 30, 77 - 30, 121 - 30, 225 ) )
	end

	RADIAL:SetCenterPanel( p )

end

function Hide()

	if ValidPanel( RADIAL ) then
		RADIAL:Remove()
		--GTowerMainGui:ToggleCursor( false )
		gui.EnableScreenClicker( false )
	end

end

function IsVisible()
	return ValidPanel( RADIAL )
end
