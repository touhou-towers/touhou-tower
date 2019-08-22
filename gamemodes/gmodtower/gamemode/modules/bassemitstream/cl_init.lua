
concommand.Add( "gmt_stopallstreams", function( ply, cmd, args )

	if !IsValid( ply ) || ply != LocalPlayer() || !BASS then return end

	for k, v in ipairs( ents.FindByClass( "gmt_emitstream" ) ) do

		if !IsValid(v) && !v.EmitStream then return end
		v:StopStream()

	end

end )

concommand.Add( "gmt_emitstream", function( ply, cmd, args )

	RunConsoleCommand( "gmt_bassemitstart", args[1] )

end )

concommand.Add( "gmt_endstream", function( ply, cmd, args )

	RunConsoleCommand( "gmt_bassemitend" )

end )

concommand.Add( "gmt_stopstream", function( ply, cmd, args )

	if !args[1] then return end

	target = args[1]

	for _, v in ipairs( player.GetAll() ) do

		if string.find( v:GetName(), target, 1, true ) then
			target = v
			break
		end

	end

	if type( target ) != "string" then

		for k, v in ipairs( ents.FindByClass( "gmt_emitstream" ) ) do

			if v:GetOwner() == target then

				v:StopStream()

			end

		end

		return

	end

end )

concommand.Add( "gmt_alterstream", function( ply, cmd, args )

	if !args[1] then return end

	target = args[1]

	for _, v in ipairs( player.GetAll() ) do

		if string.find( v:GetName(), target, 1, true ) then
			target = v
			break
		end

	end

	if type( target ) != "string" then

		for k, v in ipairs( ents.FindByClass( "gmt_emitstream" ) ) do

			if v:GetOwner() == target then

				v:ToggleStream()

			end

		end

		return

	end

end )

hook.Add( "OpenSideMenu", "OpenStreams", function()

	if #ents.FindByClass( "gmt_emitstream" ) == 0 then return end

	local Form = vgui.Create( "DForm" )
	Form:SetName( "EmitStream" )

	local StopAllStreams = Form:Button( "Stop All Streams" )
	StopAllStreams.DoClick = function() RunConsoleCommand( "gmt_stopallstreams" ) end

	for k, v in ipairs( ents.FindByClass( "gmt_emitstream" ) ) do

		if IsValid( v ) && IsValid( v:GetOwner() ) then

			if v:GetOwner() == LocalPlayer() then

				local StopMyStream = Form:Button( "Stop My Stream" )
				StopMyStream.DoClick = function() RunConsoleCommand( "gmt_bassemitend" ) end

			end

			if IsValid( v.EmitStream ) then
				local PlayerStream = Form:Button( "Toggle: " .. v:GetOwner():Name() )
				PlayerStream.DoClick = function() RunConsoleCommand( "gmt_alterstream", v:GetOwner():Name() ) end
			end

		end

	end

	return Form

end )


/*local EmitStreamList = {}

concommand.Add( "gmt_emitbrowse", function( ply, cmd, args )

	if !ply:IsPrivAdmin() then return end

	local dir = args[1]

	if dir then
		dir = string.Replace( dir, " ", "%20" ) //encode spaces
	else
		dir = "random" //random is default
	end

	local function EmitStreamEntries( contents, size )

		if contents != "" then //make sure theres actual content retrived

			EmitStreamList = string.Explode( "\n", contents ) //add the files

			table.remove( EmitStreamList, #EmitStreamList ) //remove the null one

			DisplayEmitBrowse( dir ) //now display the derma panel

		else

			ply:PrintMessage( HUD_PRINTCONSOLE, "Error, no files found.\n" ) //welp

		end

	end

	http.Get("http://emit.macdguy.org/list.php?f=" .. dir, "", EmitStreamEntries ) //get the data from the site

end )

function DisplayEmitBrowse( dir )

	if ValidPanel( EmitPanel ) then return end

	local safedir = string.Replace( dir, "%20", " " )

	EmitPanel = vgui.Create( "DFrame" )
	EmitPanel:SetPos( 50, 25 )
	EmitPanel:SetSize( 450, 450 )
	EmitPanel:SetTitle( "EmitBrowse - " .. safedir .. "/" )
	EmitPanel:SetVisible( true )
	EmitPanel:SetDraggable( true )
	EmitPanel:ShowCloseButton( true )
	EmitPanel:MakePopup()

	local EmitList = vgui.Create( "DListView" )
	EmitList:SetParent( EmitPanel )
	EmitList:SetPos( 12.5, 37.5 )
	EmitList:SetSize( 425, 362.5 )
	EmitList:SetMultiSelect( false )
	EmitList:AddColumn("MP3")

	if EmitStreamList then
		for k,v in ipairs( EmitStreamList ) do
			EmitList:AddLine(v)
		end
	end

	local stream
	function EmitList:OnRowSelected( LineID, Line )
		stream = Line:GetColumnText( 1 )
	end

	local EmitPlay = vgui.Create( "DButton", EmitPanel )
	EmitPlay:SetText( "Emit" )
	EmitPlay:SetPos( 12.5, 412.5 )
	EmitPlay:SetSize( 100, 25 )
	EmitPlay.DoClick = function()
		surface.PlaySound( "ui/buttonclick.wav" )

		if stream then
			stream = string.Replace( stream, " ", "%20" ) //encode spaces
			RunConsoleCommand( "gmt_emitstream", "http://emit.macdguy.org/" .. dir .. "/" .. stream .. ".mp3" )
		end

	end

	local EmitStop = vgui.Create( "DButton", EmitPanel )
	EmitStop:SetText( "Stop" )
	EmitStop:SetPos( 338.5, 412.5 )
	EmitStop:SetSize( 100, 25 )
	EmitStop.DoClick = function()

		surface.PlaySound( "ui/buttonclick.wav" )
		RunConsoleCommand( "gmt_endstream" )

	end

end*/
