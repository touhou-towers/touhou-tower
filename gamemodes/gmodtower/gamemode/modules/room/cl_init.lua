
GtowerRooms = {}
GtowerRooms.Rooms = {}


local QueryPanel = nil

include("shared.lua")
include("room_maps.lua")
include("cl_closet.lua")

NoPartyMsg = CreateClientConVar("gmt_ignore_party","0",true,false)

usermessage.Hook("GRoom", function(um)

    local id = um:ReadChar()

    if id == 0 then
        GtowerRooms:LoadRooms( um )
    elseif id == 1 then
		GtowerRooms:RemoveOwner( um )
	elseif id == 2 then
		GtowerRooms:ShowRentWindow( um )
	elseif id == 3 then
		GtowerNPCChat:StartChat( {
			Entity = GtowerRooms.NPCClassname,
			Text = T("RoomNotAvalible")
		} )
	elseif id == 4 then
		GtowerRooms:ShowNewRoom( um )
	elseif id == 5 then
		local Minutes = um:ReadChar()

		GtowerMessages:AddNewItem( T("RoomLongAway", Minutes) )
	//elseif id == 6 then
	//	local itemid = um:ReadChar()
	//
	//	GtowerMessages:AddNewItem( GetTranslation("RoomNotEnoughMoney", GtowerRooms.RoomUps[ itemid ].name ) )
	//elseif id == 7 then
	//	local itemid = um:ReadChar()
	//	local level = um:ReadChar()
	//
	//	GtowerRooms:AskNewRoom( itemid, level )
	elseif id == 8 then
		GtowerMessages:AddNewItem( T("RoomInventoryOwnRoom") )
	//elseif id == 9 then
	//	GtowerRooms:RecieveRefEnts( um )
	elseif id == 10 then
		GtowerMessages:AddNewItem( T("RoomNotOwner") )
	elseif id == 11 then
		GtowerMessages:AddNewItem( T("RoomCheckedOut") )
	elseif id == 12 then
		GtowerMessages:AddNewItem( T("RoomAdminDisabled") )
	elseif id == 13 then
		local Maximun = um:ReadChar() + 120
		GtowerMessages:AddNewItem( T("RoomMaxEnts", Maximun ) )
	elseif id == 14 then
		GtowerRooms:GetEntIndexs( um )
	elseif id == 15 then
		GtowerMessages:AddNewItem( T("RoomAdminRemoved") )
	else
		Msg("Recieved GRoom of unkown id: " .. tostring(id) .. "\n")
	end

end )

hook.Add("GTowerScorePlayer", "AddRoomNumber", function()

	GtowerScoreBoard.Players:Add(
		"Room #",
		5,
		75,
		function(ply)
			return (ply.GRoomId && ply.GRoomId > 0 && tostring(ply.GRoomId)) or " - "
		end,
		99
	)

end )

hook.Add("GTowerAdminPly", "AddSuiteRemove", function( ply )

	local PlyId = ply:EntIndex()

	if ply.GRoomId then
		return {
			["Name"] = "Remove Room",
			["function"] = function() RunConsoleCommand("gt_act", "remroom", PlyId ) end
		}
	end

end )


function GtowerRooms:Get( id )
	if !self.Rooms || !id then return end

	if !self.Rooms[ id ] then
		self.Rooms[ id ] = {}
	end

	return self.Rooms[ id ]
end

function GtowerRooms:ShowNewRoom( um )
	local RoomId = um:ReadChar()

	GtowerNPCChat:StartChat( {
		Text = T("RoomGet", RoomId )
	})

	GtowerMessages:AddNewItem( T( "RoomGetSmall", RoomId ) )
	GtowerMessages:AddNewItem( "NOTE: Selling suites for profit is illegal." )
end


function GtowerRooms:ShowRentWindow( um )
	local Answer = um:ReadChar()

	if Answer == -2 then

		GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = T("I am sorry, the server is having some issues with the enties at the moment. \n Come back later."),
		})

	elseif Answer == -1 then
		/* GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = T("RoomReturn", LocalPlayer():GetName() ),
			Responses = {
				{
					Response = T("yes"),
					Text = T("RoomReturnYes"),
					Func = function() RunConsoleCommand("gmt_dieroom") end
				},
				{
					Response = T("no"),
					Text = T("RoomReturnNo")
				},
			}
		}) */

		GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = "Hello " .. LocalPlayer():GetName() .. ", \nWhat can I do for you?",
			Responses = {
				{
					Response = T("checkout"),
					Text = T("RoomReturnYes"),
					Func = function() RunConsoleCommand("gmt_dieroom") end
				},
				--TODO
				--{
				--	Response = T("cleanup"),
				--	Text = T("RoomCleanUp"),
				--	Responses ={
				--		{
				--			Response = T("yes"),
				--			Func = function() RunConsoleCommand("gmt_resetroom") end
				--		},
				--		{
				--			Response = T("no"),
				--		},
				--
				--	},
				--},
				{
					Response = T("cancel"),
					Text = T("RoomReturnNo")
				},
			}
		})

	elseif Answer == 0 then

		GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = T("RoomNotAvalible", LocalPlayer():GetName() ),
		})

	else

		GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = T("RoomRoomsAvalible", LocalPlayer():GetName(), Answer ),
			Responses = {
				{
					Response = T("yes"),
					//Text = GetTranslation("RoomGet"),
					Text = T("RoomWait"),
					Func = function() RunConsoleCommand("gmt_acceptroom") end
				},
				{
					Response = T("no"),
					Text = T("RoomDeny")
				},
			}
		})

	end
end

function GtowerRooms:RemoveOwner( um )

	local RoomId = um:ReadChar()
	local Room = self:Get( RoomId )

	Room.Owner = nil

end

function GtowerRooms.ReceiveOwner( ply, roomid )
	local Room = GtowerRooms:Get( roomid )

	if Room then
		Room.HasOwner = true
		Room.Owner = ply
	end

end

RoomsHats = {}

function GtowerRooms:LoadRooms( um )

	local Count = um:ReadChar()

	for i=1, Count do

		local RoomId = um:ReadChar()
		local ValidOwner = um:ReadBool()

		local Room =  self:Get( RoomId )

		Room.Hats = {}

		if ValidOwner then
			Room.HasOwner = true

			/*if GtowerHats.Hats then
				Room.Hats[ 0 ] = true

				for k, hat in ipairs( GtowerHats.Hats ) do
					if hat.unique_name then
						Room.Hats[ k ] = um:ReadBool()
					end
				end
			end*/

		else

			Room.Owner = nil
			Room.HasOwner = false

		end
		RoomsHats[RoomId] = Room.Hats


	end

end

function GtowerRooms:GetEntIndexs( um )

	local Count = um:ReadChar()

	for i=1, Count do
		local Room = self:Get( i )

		Room.EntId = um:ReadShort()
	end

	 GtowerRooms:FindRefEnts()
end

function GtowerRooms:FindRefEnts()

	local MapData = self.RoomMapData[ game.GetMap() ]

	if !MapData then
		Msg("GtowerRooms: map data not found\n")
		return
	end

	for _, v in pairs( ents.FindByClass( MapData.refobj ) ) do
		local EntIndex = v:EntIndex()

		for _, Room in pairs( self.Rooms ) do
			if Room.EntId == EntIndex then
				Room.RefEnt = v
				Room.StartPos = v:LocalToWorld( MapData.min )
				Room.EndPos = v:LocalToWorld( MapData.max )

				OrderVectors( Room.EndPos, Room.StartPos )
			end
		end

	end

end

function GtowerRooms:RoomOwner( RoomId )
	if !RoomId then return end
    return self:Get( RoomId ).Owner
end

function GtowerRooms:RoomOwnerName( RoomId )
    local Room = self:Get( RoomId )

    if IsValid( Room.Owner ) && Room.Owner:IsPlayer() then
        return Room.Owner:Name()
    elseif Room.HasOwner then
		return T("RadioLoading")
    else
		return T("vacant") .. string.rep( ".", CurTime() * 3 % 4 )
    end

end

function GtowerRooms:AdminRoomDebug()
	local tbl =  GtowerRooms.RoomMapData[ CurMap ]

	if tbl then
		local EntList = ents.FindByClass( tbl.refobj )
		OrderVectors( tbl.min, tbl.max )

		for _, v in pairs( EntList ) do
			DEBUG:Box( v:LocalToWorld( tbl.min ), v:LocalToWorld( tbl.max ) )
		end
	end
end

SuitePanelPos = {

  Vector(4732.000000, -11127.599609, 4152.009766),
  Vector(4732.000000, -11511.599609, 4152.009766),
  Vector(4732.000000, -11895.599609, 4152.009766),
  Vector(4732.000000, -12279.599609, 4152.009766),
  Vector(4496.000000, -12507.599609, 4152.009766),
  Vector(4356.000000, -12071.599609, 4152.009766),
  Vector(4356.000000, -11687.599609, 4152.009766),
  Vector(4356.000000, -11303.599609, 4152.009766),
  Vector(4356.000000, -10919.599609, 4152.009766),
  Vector(2703.600098, -10364.000000, 4152.009766),
  Vector(2319.600098, -10364.000000, 4152.009766),
  Vector(1935.599976, -10364.000000, 4152.009766),
  Vector(2080.399902, -9987.990234, 4152.009766),
  Vector(2464.399902, -9987.990234, 4152.009766),
  Vector(2848.399902, -9987.990234, 4152.009766),
  Vector(4356.000000, -9223.629883, 4152.009766),
  Vector(4356.000000, -8839.629883, 4152.009766),
  Vector(4356.000000, -8455.629883, 4152.009766),
  Vector(4356.000000, -8071.629883, 4152.009766),
  Vector(4592.000000, -7855.629883, 4152.009766),
  Vector(4732.000000, -8279.629883, 4152.009766),
  Vector(4732.000000, -8663.629883, 4152.009766),
  Vector(4732.000000, -9047.629883, 4152.009766),
  Vector(4732.000000, -9431.629883, 4152.009766)

}

SuitePanels = {}

timer.Create("CheckOverlays",1,0,function()

  if table.Count( SuitePanels ) >= 24 then return end -- 24 suites

  for k,v in pairs(ents.GetAll()) do
    if v:GetClass() == "func_suitepanel" then
      for k,pos in pairs(SuitePanelPos) do
        if v:GetPos():IsEqualTol( pos, 5 ) then
          table.insert(SuitePanels,v)
        end
      end
    end
  end
end)

local SuiteName = CreateClientConVar( "gmt_suitename", "", true, true )

local names = {}

net.Receive('gmt_senddoortexts',function()
	names = net.ReadTable()
end)

hook.Add( "PostDrawOpaqueRenderables", "DrawSuiteOverlays", function()

  if !SuitePanels then return end

  local alpha = 25
  local alphaNumber = 255

  for k,v in pairs(SuitePanels) do

	if !IsValid(LocalPlayer()) || !IsValid(v) then continue end

  if (LocalPlayer():GetPos():Distance(v:GetPos()) > 5000) then continue end

  alpha = 25
  alphaNumber = 255

	local ang = v:GetAngles()
	local rot = Vector( -180, 0, -90 )
	ang:RotateAroundAxis( ang:Right(), rot.x )
	ang:RotateAroundAxis( ang:Up(), rot.y )
	ang:RotateAroundAxis( ang:Forward(), rot.z )
	local pos = v:GetPos()
	// Start the fun
	cam.Start3D2D( pos - (v:GetRight() * -1.5), ang, 0.5 )
  local col = v:GetPanelColor()
  surface.SetDrawColor(col.r,col.g,col.b,alpha)
  
	local owner = GtowerRooms:RoomOwner( v.RoomId )
	if owner && IsValid(owner) then surface.SetDrawColor(col.r,col.g,col.b,alpha)
		if owner:GetNWBool("Party") then surface.SetDrawColor(colorutil.Rainbow(75)) end
	end
  
  surface.SetMaterial(Material("gui/gradient_up"))
  surface.DrawTexturedRect(-150,-110,105,250)
  --surface.DrawRect(-145,-110,100,250)
  draw.DrawText(v.RoomId,"GTowerSkyMsg",-97,-75,Color(col.r,col.g,col.b,alphaNumber),TEXT_ALIGN_CENTER)
	cam.End3D2D()
	
	pos = v:GetPos() + Vector(0,0,75)
	
	if !owner || !IsValid(owner) then continue end
	local name = "LOADING"
	name = ( names[owner] or "" )
	
	if owner:GetNWBool("Party") then
		cam.Start3D2D( pos - (v:GetRight() * 2.5), ang, 0.1 )
			draw.DrawText("PARTY!!!","GTowerSkyMsg",-480 + math.sin(CurTime()*2)*4,0,colorutil.Rainbow(75),TEXT_ALIGN_CENTER)
		cam.End3D2D()
		continue
	end
	
	cam.Start3D2D( pos - (v:GetRight() * 2.5), ang, 0.1 )
		draw.DrawText(string.upper(name),"GTowerSkyMsg",-480,0,Color(255,255,255),TEXT_ALIGN_CENTER)
	cam.End3D2D()

  end
end )

local Settings = {}
Settings.Btns = {}
Settings.Names = {
	[1] = "Drinks",
	[2] = "Movies",
	[3] = "Music",
	[4] = "Games",
	[5] = "TV Shows",
	[6] = "A Piano",
}

net.Receive("gmt_partymessage", function()
	if NoPartyMsg:GetBool() then return end
	local invString = net.ReadString()
	local roomid = net.ReadString()
	
	local Question = Msg2( invString )
	Question:SetupQuestion(
	function() RunConsoleCommand( "gmt_joinparty", roomid ) end,
	function() end,
	function() end,
	nil,
	{120, 160, 120},
	{160, 120, 120})
end)

hook.Add("OpenSideMenu", "OpenSuiteOwner", function()

	local PlyId = LocalPlayer():EntIndex()
	local ply = ents.GetByIndex( PlyId )
	local RoomId = ply.GRoomId

  if ( !RoomId || RoomId == 0 ) then return end

		local Form = vgui.Create("DForm")

		Form:AddItem( vgui.Create("SuiteEntCount", Form) )

		Form:SetName( "Room #" .. RoomId )

		local Kick = Form:Button(T("RoomKickPlayers"))
		Kick.DoClick = function() RunConsoleCommand("gmt_roomkick") end
	
	if LocalPlayer():GetNWBool("Party") then
		local Kick = Form:Button("End Party")
		Kick.DoClick = function() RunConsoleCommand("gmt_endroomparty") end
	else
	
		local Kick = Form:Button("Start Party")
		--Kick.DoClick = function() RunConsoleCommand("gmt_startroomparty") end
		Kick.DoClick = function()
local frame = vgui.Create( "DFrame" )
frame:SetSize( 525, 400 )
frame:SetTitle("Your party will include...")
frame:SetBackgroundBlur(true)
frame:Center()
frame:MakePopup()

local txt = vgui.Create("DLabel",frame)
txt:SetPos( 25,50 )
txt:SetText( "You can start a party for 250 GMC.\nThis will announce to everyone on the server and provide a teleport to your suite.\nParties can last up to 2 minutes.\n\nSelect what will be part of your party:" )
txt:SetContentAlignment(5)
txt:SizeToContents()

for k,v in pairs(Settings.Names) do
	Settings.Btns[k] = vgui.Create("DCheckBoxLabel")
	Settings.Btns[k]:SetParent(frame)
	Settings.Btns[k]:SetPos(25, 125 + (25*k))
	Settings.Btns[k]:SetText(v)
	Settings.Btns[k]:SizeToContents() 
end

local DermaButton = vgui.Create( "DButton", frame )
DermaButton:SetText( "START PARTY (250 GMC)" )	
DermaButton:SetPos( 25, 350 )
DermaButton:SetSize( 475, 30 )					
DermaButton.DoClick = function()

	local endString = ""

	for k,v in pairs(Settings.Btns) do
		
		local num = 1
	
		local isChecked = v:GetChecked()

		if !isChecked then num = 0 end
		
		if k == #Settings.Btns then
			endString = endString .. tostring(num)
		else
			endString = endString .. tostring(num) .. ","
		end
	end
	RunConsoleCommand( "gmt_startroomparty", endString )
frame:Close()	
end
		end
		
		end
		
		local Kick = Form:Button("Set Suite Name")
		Kick.DoClick = function()
		Derma_StringRequest(
		"Set Suite Name",
		"Setting a name on your suite offers a good way to express youself.\nThe Name will appear above your suite door.\nSet to blank to remove.\nAbusive names will get you banned.",
		"",
		function( text ) RunConsoleCommand('gmt_suitename',text) end,
		function( text ) end
		)
		end

		return Form

end )

hook.Add("FindStream", "StreamInSuite", function( ent )

	local RoomId = GtowerRooms.PositionInRoom( ent:GetPos() )

	if RoomId then

		for _, Stream in pairs( BassStream.List ) do
			local StreamEnt = Stream:GetEntity()

			if IsValid( StreamEnt ) && GtowerRooms.PositionInRoom( StreamEnt:GetPos() ) == RoomId then
				return Stream
			end

		end

	end


end )


local PANEL = {}

function PANEL:PerformLayout()

	local RoomId = LocalPlayer().GRoomId

	if ( RoomId && RoomId != 0 ) then

		local Count = LocalPlayer().GRoomEntityCount

		self:SetText( "Suite count: " .. tostring(Count) .. "/" .. tostring(LocalPlayer():GetSetting("GTSuiteEntityLimit")) )
		self:SizeToContents()

	end

end

vgui.Register("SuiteEntCount", PANEL, "DLabel")
