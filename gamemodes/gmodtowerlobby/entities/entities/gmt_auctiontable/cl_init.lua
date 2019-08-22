include("shared.lua")

local CurMSG = 1
local MsgDelay = 0

function ENT:Initialize()
    self.Items = {}
end

function ENT:OnRemove()

	for k, v in pairs( self.Items ) do
		if IsValid( v.Ent ) then v.Ent:Remove() end
	end

end

function ENT:GetPlyName()
	if self.DisplayName != "" then return string.upper(self.DisplayName) else return "NO BIDS YET!" end
end

function ENT:Draw()
	if !IsValid(self) then return end
	self:DrawModel()
	if self.DisplayBid == nil then return end

	if CurTime() > MsgDelay then
		if CurMsg == 1 then CurMsg = 2 else CurMsg = 1 end
		MsgDelay = CurTime() + self.MsgInterval
	end

	cam.Start3D2D( self:LocalToWorld(Vector(0,15,35)), self:GetAngles() + Angle(0,180,90), .075 )

		if #self.Items > 0 then

			if CurMsg == 1 then
				draw.DrawText("HIGHEST BID: " .. string.Comma(self.DisplayBid) .. " GMC","GTowerSkyMsgSmall",0,0,Color( 255, 255, 255 ),TEXT_ALIGN_CENTER)
			else
				draw.DrawText("BID BY: " .. self:GetPlyName() ,"GTowerSkyMsgSmall",0,0,Color( 255, 255, 255 ),TEXT_ALIGN_CENTER)
			end

		end

	cam.End3D2D()

	cam.Start3D2D( self:LocalToWorld(Vector(0,-15,35)), self:GetAngles() + Angle(180,180,-90), .075 )

		if #self.Items > 0 then

			if CurMsg == 1 then
				draw.DrawText("HIGHEST BID: " .. string.Comma(self.DisplayBid) .. " GMC","GTowerSkyMsgSmall",0,0,Color( 255, 255, 255 ),TEXT_ALIGN_CENTER)
			else
				draw.DrawText("BID BY: " .. self:GetPlyName() ,"GTowerSkyMsgSmall",0,0,Color( 255, 255, 255 ),TEXT_ALIGN_CENTER)
			end

		end

	cam.End3D2D()

		for k, v in pairs( self.Items ) do

		if not IsValid( v.Ent ) then continue end

	    local ang = Angle( ( CurTime() + v.AngOffset )*8%360, (CurTime()+v.AngOffset)*18%360, (CurTime()+v.AngOffset)*12%360 )

	    --  lazy river
	    local pos = self:GetPos() + Vector( 0, 0, -400 ) + v.PosOffset + self:GetRight() * ( v.Pos - 500 ) + self:GetForward() * -100
	    local Visible = v.Return == 0
	    if Visible then

	    	v.Ent:SetPos( self:GetPos() + Vector(0,0,50) )
				v.Ent:SetModelScale(0.35)
		    v.Ent:SetAngles( ang )
		    v.Ent:DrawModel()

	    elseif RealTime() > v.Return then

	    	v.Return = 0
	    	v.PosOffset = VectorRand() * 100 + self:GetForward() * ( math.random() - 0.5 ) * 300

	    end

	end

end

function ENT:ReceiveUpdate(bid, name)
	self.DisplayBid = bid
	self.DisplayName = name
end

function ENT:ReceiveItem(id)

		if #self.Items > 0 then return end

		local Item = GTowerItems:Get( id )
		if not Item then return end
		local Model = Item.ComparableModel
		local Skin = Item.ModelSkinId

		local ent = ClientsideModel( Model, RENDERGROUP_BOTH )
		local pos = VectorRand() * 100 + self:GetForward() * ( math.random() - 0.5 ) * 300
		ent:SetPos( self:GetPos() + Vector( 0, 0, -400 ) + pos )
		ent:SetNoDraw( true )
		ent:SetSkin( Skin or 0 )

		table.insert( self.Items, {
			Ent = ent,
			AngOffset = ( math.random() - 0.5 ) * 100 * 2,
			PosOffset = pos,
			Pos = math.random() * 1000,
			Return = 0,
		} )
end

net.Receive("UpdateAuctionTable",function()
	local ent = net.ReadEntity()
	local bid = tonumber(net.ReadInt(32))
	local name = tostring(net.ReadString())
	local id = net.ReadInt(32)

	if ( id != 0 && IsValid(ent) ) then
		ent:ReceiveItem(id)
	end

	if !IsValid(ent) then return end

	ent:ReceiveUpdate(bid,name)
end)

net.Receive("SetClItem",function()
	local ent = net.ReadEntity()
	local id = net.ReadInt(32)

	if !IsValid(ent) then return end

	ent:ReceiveItem(id)
end)

net.Receive("OpenBidWindow",function()

	local admin = net.ReadBool()
	local auctable = net.ReadEntity()

	if admin then
		local frame = vgui.Create( "DFrame" )
		frame:SetSize( 500, ScrH() )
	frame:Center()
	frame:MakePopup()

	local DScrollPanel = vgui.Create( "DScrollPanel", frame )
	DScrollPanel:Dock( FILL )

  local SortedItems = {}

  for k,v in pairs(GTowerItems.Items) do
    table.insert(SortedItems,v)
  end

  table.sort( SortedItems, function( a, b ) return a.Name < b.Name end )

	for k,v in pairs(SortedItems) do
		local DButton = DScrollPanel:Add( "DButton" )
		DButton:SetText( v.Name )
		DButton:Dock( TOP )
		DButton:DockMargin( 0, 0, 0, 1 )
		DButton.DoClick = function()

			net.Start("ReceiveItem")
			net.WriteEntity( auctable )
			net.WriteInt( v.MysqlId, 32 )
			net.SendToServer()

			frame:Close()

		end

	end
		return
	end

		local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "Choose a bid!" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( false )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "DPanel", Window )

	local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
	TextEntry:SetText( 0 )
	TextEntry:SetNumeric( true )
	TextEntry:SetUpdateOnType( true )
	TextEntry:SetWide( 100 )
	TextEntry:RequestFocus()
	TextEntry:SetKeyBoardInputEnabled( true )
	TextEntry.OnValueChange = function( panel )
		value = tonumber( panel:GetValue() )

		if !value || value < 0 || value > Money() then
			value = math.Clamp( value or 0, 0, Money() )
			panel:SetText( value )
		end
	end
	TextEntry.UpdateConvarValue = TextEntry.OnValueChange
	TextEntry.AllowInput = function( panel, sInt )
		local strNumericNumber = "1234567890"

		-- We're going to make it only allow numbers ONLY, fuck floats, fuck negatives
		if sInt == "." || sInt == "-" || sInt == "[" || sInt == "]" || sInt == "(" || sInt == "%" then return true end
		if !string.find(strNumericNumber, sInt) then return true end

		return false
	end

	local TextEntryDesc = vgui.Create( "DLabel", InnerPanel )
	TextEntryDesc:SetText( "BID AMOUNT" )
	TextEntryDesc:SizeToContents()
	TextEntryDesc:SetContentAlignment( 5 )
	TextEntryDesc:SetTextColor( color_white )

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function()
		Window:Close()
		net.Start("ReceiveBid")
		net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
		net.WriteEntity(LocalPlayer())
		net.WriteInt(TextEntry:GetValue(),32)
		net.SendToServer()
	end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( strButtonCancelText or "Cancel" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = TextEntryDesc:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w, h + 115 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	TextEntry:CenterHorizontal()
	TextEntry:AlignBottom( 5 )
	TextEntryDesc:CenterHorizontal()
	TextEntryDesc:AlignBottom( 30 )

	Window:MakePopup()
	Window:DoModal()
end)
