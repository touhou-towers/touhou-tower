
GTowerItems.EntGrab = {}
local DEBUG = false

local function OnDropFloor( panel, Rotation, AimPos )

	if GTowerItems:TooFarAway( LocalPlayer():GetShootPos() ) then
		Msg2( T("InventoryTooFar") )
		return
	end

	local ent = GTowerItems:GetGrabEntity()

	if ent then
		RunConsoleCommand("gm_invmove",
			ent:EntIndex(),
			Rotation,
			AimPos.x,
			AimPos.y,
			AimPos.z
		)
	end

	if DEBUG then Msg2("Moving entity: " .. tostring(ent) .. " with vectors: " .. tostring(AimPos) ) end

end

local function OnGrabEntity( self, panel )
	GTowerItems:GrabEndEntity( panel )
	return true
end

local function GetTraceFilter( panel, ent )
	return { LocalPlayer(), GTowerItems.EntGrab.Ent }
end

local function OnStopDrag( panel )
	GTowerItems:DeleteGrabEntity()
	panel:Remove()

	return true
end

local function AllowDrop( panel, trace )
	return !GTowerItems:TooFarAway( LocalPlayer():GetShootPos() )
end

local function GetItem( panel )
	return GTowerItems.EntGrab.Item
end

hook.Add("GtowerMouseEnt", "OpenInventory", function( ent, mc )
	if !vgui.CursorVisible() then return end

	if ent:GetPos():Distance( LocalPlayer():GetShootPos() ) > GTowerItems.MaxDistance then
		return
	end

	local ItemId = GTowerItems:FindByEntity( ent )

	if DEBUG then
		Msg2("Attemping to grab: " .. tostring(ent) .. "\n")
	end

	if ItemId == nil then return end

	GTowerItems:GrabEntity( ent, ItemId )
	GTowerItems:OpenAll()

	return true

end )

function GTowerItems:GetGrabEntity()
	return GTowerItems.EntGrab.Ent
end

function GTowerItems:GrabEntity( ent, ItemId )

	self.EntGrab.ItemId = ItemId
	self.EntGrab.Ent = ent
	self.EntGrab.Item = self:CreateById( ItemId )

	local panel = vgui.Create("GtowerInvItem")

	self.EntGrab.VGUI = panel

	panel:SetId( 0 )
	panel:StartDrag()

	panel.MouseRotation = ent:GetForward():Angle().y
	panel:DragUpdateRotation()

	panel.OnDropFloor = OnDropFloor
	panel.OnSlotDrop = OnGrabEntity
	panel.GetTraceFilter = GetTraceFilter
	panel.OnStopDrag = OnStopDrag
	panel.AllowDrop = AllowDrop
	panel.GetItem = GetItem

end

function GTowerItems:TooFarAway()
	if !IsValid( self.EntGrab.Ent ) then
		return false
	end

	return self.EntGrab.Ent:GetPos():Distance( LocalPlayer():GetShootPos() ) > GTowerItems.DragMaxDistance
end


function GTowerItems:GrabEndEntity( slot )

	if IsValid( GTowerItems.EntGrab.Ent ) then

		local EntIndex = GTowerItems.EntGrab.Ent:EntIndex()

		RunConsoleCommand("gm_invgrab", EntIndex, slot:GetCommandId()  )

	end

end

function GTowerItems:DeleteGrabEntity()

	GTowerItems.EntGrab = {
		Ent = nil,
		VGUI = nil,
		ItemId = nil,
		Item = nil
	}

end

hook.Add( "GtowerHideMenus","StopDragInventory", function()
	if GTowerItems.EntGrab.VGUI then
		GTowerItems.EntGrab.VGUI:StopDrag()
	end
end )

hook.Add( "PreDrawHalos", "InventoryHalo", function()

	if !vgui.CursorVisible() then return end

	local cursorvec = GetMouseVector()
	local origin = LocalPlayer().CameraPos or LocalPlayer():GetShootPos()
	trace = util.TraceLine( { start = origin,
								  endpos = origin + cursorvec * 9000,
								  filter = { LocalPlayer() }
	} )

	local ent = trace.Entity
	local ItemId = GTowerItems:FindByEntity( ent )

	if IsValid( ent ) && ItemId then

		local color = Color( 50, 50, 150 )
		local dist = ent:GetPos():Distance( origin )

		if dist > GTowerItems.MaxDistance then
			color = Color( 150, 50, 50 )
		end

		halo.Add( {ent}, color, 4, 4, 1 )
	end

end )
