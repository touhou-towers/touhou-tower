
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_message.lua')
AddCSLuaFile('cl_buttongui.lua')

GTowerTrivia = {}
GTowerTrivia.PlySendTable = {}
local NextTriviaThink = 0.0

local function AllowEditTrivia( ply )
	return ply:IsAdmin() || ply:GetSetting("GTAllowEditTrivia") == true
end

include('shared.lua')

function GTowerTrivia:Think()

	if NextTriviaThink > CurTime() then
		return
	end
	
	NextTriviaThink = CurTime() + 0.1
	
	for PlyIndex, Tbl in pairs( GTowerTrivia.PlySendTable ) do
		
		local ply = Entity(PlyIndex)
		
		if #Tbl > 0 && IsValid( ply ) then
			local SendItems = {}
			local SpaceLeft = 246
			
			for k, SendData in ipairs( Tbl ) do
				
				local Space = 4 + string.len( SendData[3] ) + string.len( SendData[2] ) + 1 + 1 + 1
				
				SpaceLeft = SpaceLeft - Space
				
				if SpaceLeft < 0 then
					break
				end
				
				table.insert( SendItems, table.remove( Tbl, k ) )
			
			end
		
			umsg.Start("GTriv", ply )
				umsg.Char( 0 )
				umsg.Char( #SendItems )
				
				for _, SendData in ipairs( SendItems ) do
					umsg.Long( SendData[1] )
					umsg.String( SendData[3] )
					umsg.String( SendData[2] )
					umsg.Char( SendData[4] )
				end
		
			umsg.End() 
		else
			table.remove( GTowerTrivia.PlySendTable, PlyIndex )
		end
	end

	if table.Count( GTowerTrivia.PlySendTable ) == 0 then
		Msg("Removing trivia think\n")
		GTowerTrivia:RemoveThink()
	end
end

function GTowerTrivia:HookThink()
	hook.Add("Think","GTriviaThink", GTowerTrivia.Think )
end

function GTowerTrivia:RemoveThink()
	hook.Remove("Think","GTriviaThink" )
end

local function RequestData(ply, res)
	if res[1].status != true then     
		ErrorNoHalt( res[1].error .. "\n" )
		return
	end

	local PlyIndex = ply:EntIndex()
	local ReturnTable = {}

	for k, v in pairs( res[1].data ) do
		table.insert( ReturnTable, {
			v.id,
			v.question,
			v.cat,
			k
		} )
	end
		
	GTowerTrivia.PlySendTable[ PlyIndex ] = ReturnTable
	GTowerTrivia:HookThink()
end

//Requesting for data
concommand.Add( "gm_triv1", function( ply, cmd, args )
	
	if !AllowEditTrivia( ply ) then
		return
	end
	
	local Page = math.max( tonumber( args[1] or 0 ), 0 )
	local Search = tostring( args[2] )
	
	//local RequestMin = Page * GTowerTrivia.ItemsPerPage + 1
	//local RequestMax = RequestMin + GTowerTrivia.ItemsPerPage - 1
	//local RequestIDs = {}
	
	//for i=RequestMin, RequestMax do
	//	table.insert( RequestIDs, i )
	//end	
	
	local EndQuery = "SELECT `id`,`question`,`cat` FROM gm_jeopardy" // WHERE `id` IN (".. string.Implode(",", RequestIDs )  .. ")"
	
	if string.len( Search ) > 0 then
		local EscapedSearch =  SQL.getDB():Escape(Search)
		EndQuery = EndQuery .. " WHERE `question` LIKE '%" .. EscapedSearch .. "%' OR `cat` LIKE '%"..EscapedSearch.."%'"
	end
	
	EndQuery = EndQuery .. " LIMIT " .. Page * GTowerTrivia.ItemsPerPage .. "," .. GTowerTrivia.ItemsPerPage
	
	 SQL.getDB():Query( EndQuery, function(res) RequestData(ply, res) end)
end )

local function TriviaUpdateStatus(res)
	if res[1].status != true then     
		ErrorNoHalt( res[1].error .. "\n" )
		return
	end
end

concommand.Add( "gm_triv2", function( ply, cmd, args )
	if !AllowEditTrivia( ply ) then
		return
	end
	
	local Question =  SQL.getDB():Escape( args[1] or "" )
	local Category =  SQL.getDB():Escape( args[2] or "" )
	local Answer1 =  SQL.getDB():Escape( args[3] or "" )
	local Answer2 =  SQL.getDB():Escape( args[4] or "" )
	local Answer3 =  SQL.getDB():Escape( args[5] or "" )
	local Answer4 =  SQL.getDB():Escape( args[6] or "" )
	local PlySQLId = ply:SQLId()
	
	if string.len ( Question ) < 6 then
		return
	end
	
	if string.len ( Category ) < 3 then
		return
	end
	
	if string.len ( Answer1 ) < 1 then
		return
	end
	
	if string.len ( Answer2 ) < 1 then
		return
	end
	
	local Query = "INSERT INTO `gm_jeopardy`(`question`,`cat`,`ans1`,`ans2`,`ans3`,`ans4`,`AddedBy`) "
	Query = Query .. "VALUES('" .. Question .."','"..Category.."','"..Answer1.."','"..Answer2.."','"..Answer3.."','"..Answer4.."'," .. PlySQLId .. ")"

	 SQL.getDB():Query( Query, TrivaUpdateStatus )
end )

local function UpdateTriviaToPlayer( ply, res )
	if res[1].status != true then     
		ErrorNoHalt( res[1].error .. "\n" )
		return
	end

	if !res[1].data || #res[1].data == 0 then
		return
	end

	local Data = res[1].data[1]
	
	umsg.Start("GTriv", ply )
		umsg.Char( 1 )
		
		umsg.Long( Data["id"] )
		umsg.String( Data["question"] )
		umsg.String( Data["cat"] )
		umsg.String( Data["ans1"] )
		umsg.String( Data["ans2"] )
		umsg.String( Data["ans3"] )
		umsg.String( Data["ans4"] )
		umsg.Bool( tobool( Data["enabled"] ) )
				
	umsg.End()
end

concommand.Add( "gm_triv3", function( ply, cmd, args )
	if !AllowEditTrivia( ply ) then
		return
	end
	
	local Index = math.max( tonumber( args[1] or 0 ), 1 )
	local Query = "SELECT `id`,`question`,`cat`,`ans1`,`ans2`,`ans3`,`ans4`,`enabled` FROM gm_jeopardy WHERE `id`=" .. Index

	 SQL.getDB():Query( Query, function(res) UpdateTriviaToPlayer(ply, res) end)
end )

local function UpdateTriviaQuestion(ply, res)
	umsg.Start("GTriv", ply )
		umsg.Char( 2 )

		if res[1].status != true then     
			ErrorNoHalt( res[1].error .. "\n" )
			Msg( Query .. "\n")
			umsg.Bool( false )
			umsg.String( res[1].error )
		end

		umsg.Bool( true )
	umsg.End() 
end

concommand.Add( "gm_triv4", function( ply, cmd, args )
	if !AllowEditTrivia( ply ) then
		return
	end
	
	local SQLId =  SQL.getDB():Escape( args[1] or "" )
	local Question =  SQL.getDB():Escape( args[2] or "" )
	local Category =  SQL.getDB():Escape( args[3] or "" )
	local Answer1 =  SQL.getDB():Escape( args[4] or "" )
	local Answer2 =  SQL.getDB():Escape( args[5] or "" )
	local Answer3 =  SQL.getDB():Escape( args[6] or "" )
	local Answer4 =  SQL.getDB():Escape( args[7] or "" )
	local PlySQLId = ply:SQLId()
	
	if string.len ( Question ) < 6 then
		return
	end
	
	if string.len ( Category ) < 3 then
		return
	end
	
	if string.len ( Answer1 ) < 1 then
		return
	end
	
	if string.len ( Answer2 ) < 1 then
		return
	end
	
	local Query = "UPDATE `gm_jeopardy` SET "
	Query = Query .. "`question`='" .. Question .. "',"
	Query = Query .. "`cat`='" .. Category .. "',"
	Query = Query .. "`ans1`='" .. Answer1 .. "',"
	Query = Query .. "`ans2`='" .. Answer2 .. "',"
	Query = Query .. "`ans3`='" .. Answer3 .. "',"
	Query = Query .. "`ans4`='" .. Answer4 .. "',"
	Query = Query .. "`EditedBy` = " .. PlySQLId .. ""
	Query = Query .. " WHERE `id`=" .. SQLId .. ""
	
	 SQL.getDB():Query( Query, function(res) UpdateTriviaQuestion(ply, res) end)
end )