
include('shared.lua')

-- Fonts
surface.CreateFont( "suitePanelBig",{ font = "Trebuchet", size = 45, weight = 700, antialias = false, additive = false })
surface.CreateFont( "suitePanelSmall",{ font = "Trebuchet", size = 30, weight = 800, antialias = false, additive = false })

ENT.matBackdrop 		= surface.GetTextureID( "func_touchpanel/terminal_backdrop04" )
ENT.matButtonOpen 		= surface.GetTextureID( "func_touchpanel/button_open04" )
ENT.matButtonClose 		= surface.GetTextureID( "func_touchpanel/button_close04" )
ENT.matButtonLock 		= surface.GetTextureID( "func_touchpanel/button_lock04" )
ENT.matButtonUnlock		= surface.GetTextureID( "func_touchpanel/button_unlock04" )

function ENT:Initialize()
	-- Set Model
	self:SetModel( "models/func_touchpanel/terminal04.mdl" )

end
/*
function ENT:UpdateRoomId( val )
	self.RoomId = tonumber( val )

	if self.RoomId != 0 then
		self.DrawLoading =  self.DrawActualLoaded
	end
end

function ENT:RoomIdChanged( name, old, new )
	if new != 0 then
		self.DrawLoading =  self.DrawActualLoaded
		cookie.Set("GMTSuitePanel" .. self:EntIndex(), new )
	end
end
*/

function ENT:Think()

	local Skin = tonumber( self:GetSkin() )

	if Skin && Skin != 0 then
		self.DrawLoading =  self.DrawActualLoaded
		self.RoomId = Skin
	end

end


-- Now here's the fun part...

function ENT:Draw()

	self.Entity:DrawModel()

	// Aim the screen forward
	local ang = self.Entity:GetAngles()
	local rot = Vector( -180, 0, -90 )
	ang:RotateAroundAxis( ang:Right(), rot.x )
	ang:RotateAroundAxis( ang:Up(), rot.y )
	ang:RotateAroundAxis( ang:Forward(), rot.z )

	// Place screen at the front of the model
	local pos = self.Entity:GetPos() - ( self.Entity:GetRight() * 0.8 )

	//TODO: CHECK FOR DISTANCE (120)

	// Start the fun
	cam.Start3D2D( pos, ang, 0.025 )

		local cur_x, cur_y, visible = self:MakeEyeTrace( LocalPlayer() )

		-- Draw the panel
		self:DrawPanel( cur_x, cur_y, visible )

	cam.End3D2D()

end

function ENT:OnRoomLock()
	if !GtowerRooms then return false end

	local Owner = GtowerRooms:RoomOwner( self.RoomId )

	if Owner then
		return Owner.GRoomLock
	end

	return false
end

function ENT:LocalOwner()
    return self.RoomId == LocalPlayer().GRoomId
end

function ENT:DrawLoadingWaiting()
	draw.DrawText(  "Loading" .. string.rep( ".", CurTime() % 4 ), "suitePanelBig", -140, -140, Color( 255, 255, 255, 255 ) )
	draw.DrawText( "Vacant", "suitePanelSmall", -140, -68, Color( 255, 255, 255, 200 ) )
end

function ENT:DrawActualLoaded()
	draw.DrawText( "Suite #" .. self.RoomId, "suitePanelBig", -140, -140, Color( 255, 255, 255, 255 ) )
	draw.DrawText( GtowerRooms:RoomOwnerName( self.RoomId ) , "suitePanelSmall", -140, -68, Color( 255, 255, 255, 200 ) )
end

function ENT:GetPanelColor()
	//TODO
	//Nuggets: #096FFF

	local Room = GtowerRooms:Get( self.RoomId )

	if Room && !Room.HasOwner then return Color( 225,225,225, 255 ) end

	local Room = GtowerRooms:Get( self.RoomId )
	--local Owner = Room.Owner

	if Room && Room.HasOwner then

		if !Room.Owner then return Color( 255, 100, 100, 255 ) end
		if !IsValid(Room.Owner) then return Color( 255, 100, 100, 255 ) end

		if self:LocalOwner() then
			return Color( 100, 255, 100, 255 )
		elseif Room.Owner.GRoomLock then
			return Color( 255, 100, 100, 255 )
		else
			return Color( 100, 100, 255, 255 )
		end
	end

	return Color( 255, 100, 100, 255 )

end

ENT.DrawLoading =  ENT.DrawLoadingWaiting


-- Big 2-button Terminal
function ENT:DrawPanel( cur_x, cur_y, onscreen )
    local col = self:GetPanelColor()

	-- Backdrop
	surface.SetDrawColor( col.r, col.g, col.b, 255 )
	surface.SetTexture( self.matBackdrop )
	surface.DrawTexturedRect( -360, -180, 720, 360 )

	self:DrawLoading()


	-- Open Button
	if onscreen && cur_x < 80 && cur_x > -70 && cur_y > -30 && cur_y < 160 then
		surface.SetDrawColor( col.r, col.g, col.b, 255)
		onscreen = false
	//elseif self:GetNetworkedBool(2) == true then
	//    surface.SetDrawColor( col.r, col.g, col.b, 160)
	else
	    surface.SetDrawColor( col.r, col.g, col.b, 96)
	end


	surface.SetTexture( self.matButtonOpen )
	surface.DrawTexturedRect( -180, -180, 360, 360 )


	-- Close Button
	if onscreen && cur_x > 80 && cur_x < 240 && cur_y > -30 && cur_y < 160 then
		surface.SetDrawColor( col.r, col.g, col.b, 255)
		onscreen = false
	//elseif self:GetNetworkedBool(2) == false then
	//    surface.SetDrawColor( col.r, col.g, col.b, 160)
	else
	    surface.SetDrawColor( col.r, col.g, col.b, 96)
	end

	surface.SetTexture( self.matButtonClose )
	surface.DrawTexturedRect( 0, -180, 360, 360 )


	-- Lock Button
	if onscreen && cur_x < -70 && cur_x > -240 && cur_y > -30 && cur_y < 60 then
		surface.SetDrawColor( col.r, col.g, col.b, 255)
	elseif self:OnRoomLock() && !onscreen then
		 surface.SetDrawColor( col.r, col.g, col.b, 200)
	else
	    surface.SetDrawColor( col.r, col.g, col.b, 96)
	end

	surface.SetTexture( self.matButtonLock )
	surface.DrawTexturedRect( -360, -180, 360, 360 )

	-- Unlock Button
	if onscreen && cur_x < -70 && cur_x > -240 && cur_y > 70 && cur_y < 160 then
		surface.SetDrawColor( col.r, col.g, col.b, 255)
	elseif !self:OnRoomLock() && !onscreen then
		surface.SetDrawColor( col.r, col.g, col.b, 200)
	else
	    surface.SetDrawColor( col.r, col.g, col.b, 96)
	end

	surface.SetTexture( self.matButtonUnlock )
	surface.DrawTexturedRect( -360, -180, 360, 360 )

end


hook.Add("GtowerMouseEnt", "GtowerMouseSuitePanel", function(ent, mc)

	if ent:GetClass() != "func_suitepanel" then return end
	if ent:GetPos():Distance( LocalPlayer():GetShootPos() ) > 65 then return end

	local cur_x, cur_y, visible = ent:MakeEyeTrace( LocalPlayer() )

	if vgui.CursorVisible() && visible && cur_x > -230 && cur_x < 224 && cur_y > -150 && cur_y < -35 then

		local owner = GtowerRooms:RoomOwner( ent.RoomId )

		if !IsValid(owner) then return end

		GtowerClintClick:ClickOnPlayer( owner , mc )

	elseif ent:LocalOwner() || LocalPlayer():IsAdmin() then

		RunConsoleCommand( "gtower_suitepanel", ent:EntIndex(), math.Round(cur_x), math.Round(cur_y) )

	end

	return true
end)
