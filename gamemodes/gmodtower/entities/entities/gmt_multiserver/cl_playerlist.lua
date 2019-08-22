
//Dark 051526 80
//Dark rounded box for background 40%
//Font: abbaca

local BackgroundColor = Color( 0x16, 0x34, 0x55, 0.7 * 255 )

function ENT:UpdatePlayerList()

	local EachHeight = self.DefaultTextHeight + 4
	local MaxSpace = math.floor( (self.TotalHeight - self.TopHeight) / EachHeight ) - 2

	local function CalculateYPos( Tbl )

		if !Tbl.MinList then
			Tbl.MinList = table.Count( Tbl.PlayerList )
		end

		Tbl.Height = Tbl.MinList * self.DefaultTextHeight
		Tbl.y = self.PlayerStartY

	end

	self.PlayerGui =  {
		Title = "CURRENT PLAYERS",
		x = self.TotalMinX + self.TotalWidth * (2/4) - self.PlayerWidth / 2 ,
		PlayerList = self.ServerPlayers or {},
		MinList = self.ServerMaxPlayers or 0,
		EachHeight = EachHeight
	}

	local PlayerList, ColorList = self:MakeList( self.WaitingList, MaxSpace )

	self.WaitingGui = {
		Title = "QUEUE",
		x = self.TotalMinX + self.TotalWidth * (1/3) * 0.5 - self.PlayerWidth / 2,
		PlayerList = PlayerList,
		ColorList = ColorList,
		EachHeight = EachHeight
	}

	CalculateYPos( self.PlayerGui )
	CalculateYPos( self.WaitingGui )


	//Fill the empty slots with something
	local Difference = self.PlayerGui.MinList - table.Count( self.PlayerGui.PlayerList )
	for i=1, Difference do
		table.insert( self.PlayerGui.PlayerList, "" )
	end

end

function ENT:DrawPlayers()

	if self.PlayerGui then self:DrawPlayerList( self.PlayerGui ) end
	if self.WaitingGui then  self:DrawPlayerList( self.WaitingGui, self.ServerMinPlayers ) end

end
surface.CreateFont( "MikuHUDMainSmall", { font = "Oswald", size = 18, weight = 400 } )
function ENT:DrawPlayerList( List, PlyCount )

	local x = List.x
	local y = List.y
	local players = List.PlayerList

	local Count = math.max( table.Count( players ), List.MinList ) + 1
	local TotalHeight = Count * List.EachHeight
	local CurY = y + 2

	if Count % 2 == 0 then
		TotalHeight = TotalHeight + 8
	else
		TotalHeight = TotalHeight + 1
	end

	draw.RoundedBox( 2, x, y, self.PlayerWidth, TotalHeight, BackgroundColor )

	surface.SetFont( "MikuHUDMainSmall" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( x + 4, CurY - 2 )
	surface.DrawText( List.Title )

		// Draw player count

		local count = (#players or 0)
		local cx = x + 155

		if PlyCount && PlyCount > 0 then
			count = count .. "/" .. PlyCount .. " min"
			cx = x + 125
		end

		surface.SetTextPos( cx, CurY - 2 )
		surface.DrawText( count )



	local DrawDark = true
	CurY = CurY + List.EachHeight

	for k, v in pairs( players ) do

		if DrawDark then
			surface.SetDrawColor( 0, 0, 0, 100 )
			surface.DrawRect( x, CurY - 2, self.PlayerWidth, List.EachHeight )
		end

		if v != "" then
			if List.ColorList then
				if List.ColorList[k] == true then
					surface.SetTextColor( 80, 255, 80, 255 )
				else
					surface.SetTextColor( 255, 255, 255, 255 )
				end
			end

			surface.SetTextPos( x + 12, CurY - 2)
			surface.DrawText( v )
		end

		CurY = CurY + List.EachHeight
		DrawDark = not DrawDark
	end

end
