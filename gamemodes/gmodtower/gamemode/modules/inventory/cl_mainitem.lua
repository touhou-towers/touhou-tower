
local PANEL = {}
PANEL.DEBUG = false
local OpenTime = 1 / 0.5 // 0.5 seconds

local BorderSize = 7
local SpaceBetweenItems = 4

local BackSelect = surface.GetTextureID( "inventory/inv_item_extended" )
local GhostEntity =  nil

local BackgroundColor = Color( 255, 255, 255, 150 )
local SelectedBackgroundColor = Color( 155, 255, 155, 255 )

surface.CreateFont( "InvTinyText", { font = "Oswald", size = 16, weight = 400 } )

local function MenuSetTextHatHeight()
	Derma_StringRequest( "Set Height",
		"Set Text Hat height (10 Max)",
		"",
		function( out ) RunConsoleCommand("gmt_hatheight", out ) end,
		nil,
		"Update",
		"Cancel"
	)
end

local function MenuSetTextHat()
	Derma_StringRequest( "Set Text",
		"Set text (12 Characters Max)",
		"",
		function( out ) RunConsoleCommand("gmt_hattext", out ) end,
		nil,
		"Update",
		"Cancel"
	)
end

function PANEL:Init()

	self.CanDrawBackground = true
	self.Id = nil
	self.ItemName = ""
	self.CanEntCreate = true

	self.OriginX = 0
	self.OriginY = 0

	self.Ticker = draw.NewTicker( 4, 2, math.random( 2, 3 ) )

	self.MouseRotation = 0

	self.FuncDrawItem = EmptyFunction
	self.NormalPaint = self.Paint
	self.ItemBackgroundColor = BackgroundColor

	self.BaseClass.Init( self )

	self:SetSize( GTowerItems.InvItemSize, GTowerItems.InvItemSize )
end

function PANEL:DrawName()

	local x, y = 2, 2
	local w, h = self:GetWide(), 16

	surface.SetDrawColor( 0, 0, 0, 100 )

	--render.SetScissorRect( self.x + x, self.y + y, x + w, y + h, true )
		surface.DrawRect( x, y, w, h )
		draw.TickerText( string.upper( tostring( self.ItemName ) ), "InvTinyText", Color( 255, 255, 255 ), self.Ticker, self:GetWide() )
	--render.SetScissorRect( 0, 0, 0, 0, false )

	if self.DEBUG then
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawOutlinedRect( 0,0, self:GetWide(), self:GetTall() )
	end
end

function PANEL:DrawBackground()

	surface.SetDrawColor(
		self.ItemBackgroundColor.r,
		self.ItemBackgroundColor.g,
		self.ItemBackgroundColor.b,
		self.ItemBackgroundColor.a
	)
	surface.SetTexture( BackSelect )
	surface.DrawTexturedRect( 0, 0, 64, 64 )

end

function PANEL:Paint( w, h )

	if self.CanDrawBackground then
		self:DrawBackground()
	end

	self:FuncDrawItem()

end

function PANEL:RemoveEntity()
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil
	end
end

function PANEL:ResetDrawing()
	self.ItemName = ""
	self.PaintOver = EmptyFunction
end

function PANEL:ItemPaintOver()
	local Item = self:GetItem()

	if Item then
		Item:PaintOver( self )
	end
end

function PANEL:OnModelCreated()
	local Item = self:GetItem()

	if Item then

		local look, cam = Item:GetRenderPos( self.Entity )

		self:SetLookAt( look )
		self:SetCamPos( cam )

	end

end

function PANEL:PerformLayout()
	local Item = self:GetItem()

	if Item then

		if Item.DrawModel == true then //Draw client side model

			self:SetModel( Item.Model, Item.ModelSkinId )
			self.FuncDrawItem = self.BaseClass.Paint

			if self.DEBUG then Msg("Item(".. self.Id..") drawing model\n") end

		else
			self:RemoveEntity()

			if type( Item.Draw ) == "function" then //Draw the custom item set by item

				self.FuncDrawItem = self.DrawCustomItem
				if self.DEBUG then Msg("Item(".. self.Id..") drawing custom\n") end

			else

				self.FuncDrawItem = EmptyFunction
				if self.DEBUG then Msg("Item(".. self.Id..") drawing normal\n") end
			end
		end

		if Item.DrawName == true || self.DEBUG then
			self.ItemName = Item.Name
			self.PaintOver = self.DrawName

		elseif Item.PaintOver then
			self.PaintOver = self.ItemPaintOver
		else
			self:ResetDrawing()
		end

		if Item.DrawSelected && Item:DrawSelected() then
			self.ItemBackgroundColor = SelectedBackgroundColor
		else
			self.ItemBackgroundColor = BackgroundColor
		end

		if self:IsMouseInWindow() then
			self:ShowToolTip()
		end

		self.CanEntCreate = Item.CanEntCreate

	else
		self.ItemBackgroundColor = BackgroundColor
		self.FuncDrawItem = EmptyFunction
		self:ResetDrawing()
	end

	if self.DEBUG then Msg("Main item: Performing layout, ITEM: ".. tostring( self.Id ) .."\n") end

end

function PANEL:DrawCustomItem()
	local Item = self:GetItem()
	if Item then
		Item:Draw( self )
	end
end

function PANEL:OpenMenu()

	local Item = self:GetItem()
	local CommandId = self:GetCommandId()

	if !Item then return end
	local Price = Item.StorePrice or 0

	local Menu = {
		[1] = {
			["type"] = "text",
			["Name"] = Item.Name,
			["order"] = -10,
			["closebutton"] = true
		}
	}

	if Item.CanUse then
		table.insert( Menu, {
			["Name"] = Item.UseDesc or "Use",
			["function"] = function()
				RunConsoleCommand("gmt_invuse", CommandId )
				hook.Call("InventoryUse", GAMEMODE, CommandId )
			end
		} )
	end

	if Item.CanTexthat then
		table.insert( Menu, {
			["Name"] = "Set Text",
			["function"] = function()
				MenuSetTextHat()
			end
		} )
	end

	if Item.CanTextHeight then
		table.insert( Menu, {
			["Name"] = "Set Height",
			["function"] = function()
				MenuSetTextHatHeight()
			end
		} )
	end

			table.insert( Menu, {
			["Name"] =  "Send To Trunk",
			["canclose"] = true,
			["sub"] = {
				[1] = {
					["Name"] = "Yes",
					["function"] = function()
						RunConsoleCommand("gmt_invtobank", CommandId )
						hook.Call("InventoryRemove", GAMEMODE, CommandId )
					end
				}
			}
		} )

	local HookTable = hook.GetTable().InvExtra

	if HookTable then
		for _, v in pairs( HookTable ) do

			local b, rtn = pcall( v, Item )

			if b then
				table.insert( Menu, rtn )
			else
				ErrorNoHalt( rtn )
			end

		end
	end

	if Item.ExtraMenuItems then
		Item:ExtraMenuItems( Menu )
	end

	if Item.CanRemove then
		local Name = "Discard"
		local SellPrice = Item:SellPrice()

		if SellPrice > 0 then
			Name = "Sell (".. SellPrice .." GMC)"
		end
		table.insert( Menu, {
			["Name"] =  Name,
			["canclose"] = true,
			["sub"] = {
				[1] = {
					["Name"] = "Yes",
					["function"] = function()
						RunConsoleCommand("gmt_invremove", CommandId )
						hook.Call("InventoryRemove", GAMEMODE, CommandId )
					end
				}
			}
		} )
	end

	if #Menu > 1 then
		GtowerMenu:OpenMenu( Menu )
	end

end

function PANEL:OnMousePressed( mc )
	if mc == MOUSE_RIGHT then
		self:OpenMenu()
		return
	end

	local Item = self:GetItem()

	if Item then
		self:StartDrag()
	end
end


function PANEL:OnMouseReleased( mc )

	if self:IsDragging() then
		self:CheckDropItem()
		self:StopDrag()
	end

end


function PANEL:OnCursorEntered()
	self:ShowToolTip()
end

function PANEL:ShowToolTip()
	//Show tooltip if tem exists
	local Item = self:GetItem()

	if Item then
		GTowerItems:ShowTooltip( Item.Name, Item.Description, self )
	end
end

function PANEL:OnCursorExited()
	GTowerItems:HideTooltip()
	GTowerItems:CheckSubClose()
end

hook.Add( "GtowerHideMenus", "GitAwayYoTooltip", function() 
timer.Simple(.5, function()
	GTowerItems:HideTooltip()
	GTowerItems:CheckSubClose()
	end)
end)

function PANEL:OnMouseWheeled( delta )
	self.MouseRotation = math.NormalizeAngle(self.MouseRotation + delta * 15)

	// try to snap to world axes
	for i=-180, 180, 90 do
		if (self.MouseRotation > i - 15 && self.MouseRotation < i + 15) then
			self.MouseRotation = i
			break
		end
	end

	self:DragUpdateRotation()
end



/*===========================
 == External functions
=============================*/

function PANEL:IsEquipSlot()
	return GTowerItems:IsEquipSlot( self.Id )
end
PANEL.Equippable = PANEL.IsEquipSlot

function PANEL:OriginalPos( x, y )
	self.OriginX = x
	self.OriginY = y

	if self.DEBUG then Msg("New item(".. self.Id ..") position: " .. x .. " " .. y .. "\n") end

	self:ForcePosition()
end

/*===========================
 == Internal functions
=============================*/

function PANEL:SetId( id )
	self.Id = id

	self:UpdateDrawBackground()
end

function PANEL:UpdateDrawBackground()
	self.CanDrawBackground = self:IsEquipSlot() == false
end

function PANEL:ForcePosition()
	self:SetPos( self.OriginX, self.OriginY )
end

function PANEL:IsMouseInWindow()
    local x,y = self:CursorPos()
    return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end

function PANEL:UpdateParent()

	if self:IsDragging() then
		return
	end

	local parent = self:GetOriginalParent()

	if parent then
		self:SetParent( parent )
		self:SetVisible( true )

	else
		self:SetVisible( false )

	end

end

function PANEL:GetCursorParent()

	if GTowerItems.MainInvPanel && GTowerItems.MainInvPanel:IsMouseInWindow() then
		return GTowerItems.MainInvPanel
	end

	if GTowerItems.DropInvPanel && GTowerItems.DropInvPanel:IsMouseInWindow() then
		return GTowerItems.DropInvPanel
	end

	local Tbl = hook.GetTable().GTowerInvHover

	if Tbl then
		for k, v in pairs( Tbl ) do

			local b, ret = pcall( v, self )


			if b then
				if ret then
					return ret
				end
			else
				Msg("Inventory: GetCursorParent: COULD NOT CALL: "  .. k .. " ("..ret..")\n")
			end
		end
	end

	return nil

end

/*===========================
 == DRAGGING
=============================*/

function PANEL:StartDrag()

	if self:OnStartDrag() == true then
		return
	end

	self.Think = self.DraggingThink
	self.DragCanDrop = false
	self.GhostHitNormal = Vector(0,0,1)
	self.MouseRotation = 0
	self:SetParent( nil )

	//self:UpdateModel()
	self:SetAlpha( 125 )
	self:SetZPos( 2 )

	self.BackupCheckParentLimit = self.CheckParentLimit
	self.CheckParentLimit = nil

	if self.DEBUG then Msg2("Start dragging object") end
end

function PANEL:StopDrag()
	self:DragDestroyEntity()

	if self:OnStopDrag() == true then
		GTowerItems:HideTooltip()
		return
	end

	self.Think = EmptyFunction
	self:SetAlpha( 255 )

	self:UpdateParent()
	self:ForcePosition()
	self:SetZPos( 0 )

	self.CheckParentLimit = self.BackupCheckParentLimit

	if self.DEBUG then Msg2("STOP dragging") end
end

function PANEL:IsDragging()
	return self.Think == self.DraggingThink
end

function PANEL:DraggingThink()

	local Parent = self:GetCursorParent()
	self:SetPos( gui.MouseX() - self:GetWide()/2 , gui.MouseY() - self:GetTall()/2 )

	if !Parent then

		if self.CanEntCreate then

			if !GhostEntity then
				self:UpdateModel()
			end

			self:DraggingEntThink()

		end

		return
	end

	if GhostEntity then
		self:DragDestroyEntity()
	end

end

function PANEL:UpdateModel()

	local Item = self:GetItem()

	if !Item then
		return
	end

	if Item.Model && util.IsValidModel( Item.Model ) then

		if !GhostEntity then
			self:DragCreateEntity( Item )
		else
			GhostEntity:SetModel( Item.Model )
			GhostEntity:SetSkin( Item.ModelSkinId or 1 )
		end

	else

		Msg("Model for item: " .. tostring(Item.Name) .. " (".. tostring(  Item.Model ) ..") is invalid!\n")

	end

end

function PANEL:DragCreateEntity( item )

	if !GhostEntity then
		GhostEntity = ClientsideModel( item.Model )
	end

	if item.ItemScale then
		GhostEntity:SetModelScale(item.ItemScale,0)
	end

	GhostEntity:SetModel( item.Model )
	GhostEntity:SetSkin( item.ModelSkinId or 1 )
	GhostEntity:SetSolid( SOLID_VPHYSICS );
	GhostEntity:SetMoveType( MOVETYPE_NONE )
	GhostEntity:SetNotSolid( true );
	GhostEntity:SetColor( Color( 255, 100, 100, 150 ) )
	GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )

	GhostEntity.Item = item

	if self.DEBUG then Msg2("Creating ghost entity with model: " .. model ) end
end

function PANEL:DragDestroyEntity()

	if IsValid( GhostEntity ) then
		GhostEntity:Remove()
	end

	GhostEntity = nil

end

function PANEL:DragUpdateRotation()
	if !self.GhostHitNormal then
		return
	end

	local BaseAngle = self.GhostHitNormal:Angle()

	if AngleWithinPrecisionError(BaseAngle.p, 270) || AngleWithinPrecisionError(BaseAngle.p, 90) then
		BaseAngle.y = 0
	end

	BaseAngle:RotateAroundAxis( BaseAngle:Right(), -90 )
	BaseAngle:RotateAroundAxis( BaseAngle:Up(), self.MouseRotation )

	if IsValid( GhostEntity ) then

		local itm = GhostEntity.Item
		local Pos = GhostEntity:GetPos()

		if itm.Manipulator then
			itm.Manipulator( BaseAngle, Pos, self.GhostHitNormal )
		end

		GhostEntity:SetAngles( BaseAngle )
	end
end

function PANEL:GetTrace()
	local ply = LocalPlayer()
	return util.QuickTrace(
		ply:GetShootPos(),
		gui.ScreenToVector( gui.MousePos() ) * GTowerItems.MaxDistance,
		self:GetTraceFilter()
	)
end

function PANEL:CheckTraceHull()
	return GTowerItems:CheckTraceHull( GhostEntity, gui.ScreenToVector( gui.MousePos() ) )
end

function PANEL:DraggingEntThink()

	if !IsValid( GhostEntity ) then
		return
	end

	local Trace = self:GetTrace()
	local min = GhostEntity:OBBMins()

	if Trace.Hit && self:AllowDrop( Trace ) then
		self.GhostHitNormal = Trace.HitNormal
		GhostEntity:SetColor( Color(100, 255, 100, 190) )
	else
		self.GhostHitNormal = Vector(0,0,1)
		GhostEntity:SetColor( Color(255, 100, 100, 190) )
	end

	self:DragUpdateRotation()
	local NewPos = Trace.HitPos - self.GhostHitNormal * min.z
	local itm = GhostEntity.Item
	local BaseAngle = GhostEntity:GetAngles()

	if itm.Manipulator then
		NewPos = itm.Manipulator( BaseAngle, NewPos, self.GhostHitNormal )
	end

	GhostEntity:SetPos( NewPos )

	if !self:CheckTraceHull() then
		GhostEntity:SetColor( Color(255, 100, 100, 190) )
	end

end

function PANEL:CheckDropItem()

	local Parent = self:GetCursorParent()

	if self.DEBUG then Msg2("Checking drop item: " .. tostring(Parent)  ) end

	if Parent == nil then

		local Trace = self:GetTrace()

		if Trace.Hit then
			local AimPos = gui.ScreenToVector( gui.MousePos() )

			self:OnDropFloor( self.MouseRotation, AimPos )
		end

		return

	end

	local VguiDrop = hook.Call("InvGuiDrop", GAMEMODE, self )

	if VguiDrop && self:OnSlotDrop( VguiDrop ) == true then
		return
	end

	if self:FinalDrop() == true then
		return
	end

	if Parent.CheckDrop then
		Parent:CheckDrop( self )
	end

end

/*===========================
 == THINGS TO BE OVERWRITTEN WHEN NECESSARY
=============================*/

function PANEL:GetItem()
	return self.Id && GTowerItems:GetItem( self.Id )
end

function PANEL:GetCommandId()
	return self.Id .. "-1"
end

function PANEL:OnDropFloor( Rotation, AimPos )

	RunConsoleCommand("gm_invspawn",
		self:GetCommandId() ,
		Rotation,
		AdvRound(AimPos.x, 4),
		AdvRound(AimPos.y, 4),
		AdvRound(AimPos.z, 4)
	)

	hook.Call("InventoryDrop", GAMEMODE, self:GetCommandId() )

	if self.DEBUG then Msg2("Dropping entity: " .. tostring(self.Id) ) end

end

function PANEL:AllowPosition( panel )

	local Item = self:GetItem()

	if Item then
		if !GTowerItems:AllowPositionEx( Item, panel ) then
			return false
		end
	end

	return true
end

function PANEL:OnSlotDrop( panel )

	if panel:AllowPosition( self ) && self:AllowPosition( panel ) then

		RunConsoleCommand("gm_invswap",
			self:GetCommandId(),
			panel:GetCommandId()
		)

		hook.Call("InventorySwap", GAMEMODE, self:GetCommandId(), panel:GetCommandId() )

		return true
	end

end

function PANEL:GetTraceFilter()
	return LocalPlayer()
end

function PANEL:OnStopDrag()

end

function PANEL:FinalDrop()

end

function PANEL:AllowDrop()
	return true
end

function PANEL:GetOriginalParent()
	return GTowerItems:GetOriginalParent( self.Id )
end

function PANEL:OnStartDrag()
	GTowerItems:OpenDropInventory()
end

vgui.Register("GtowerInvItem",PANEL, "DModelPanel2")

concommand.Add("gmt_invtracehull", function()
	if IsValid( GhostEntity ) then
		PrintTable( GTowerItems:TraceHull( GhostEntity ) )
	end
end )
