

-----------------------------------------------------
local showMessage = CreateClientConVar( "gmt_admin_showumsg", 0, true, false )
local showGraph = CreateClientConVar( "gmt_admin_showumsggraph", 0, true, false )

local ReadList = {}

local function LoadUsermessageHooks()

	local _R = debug.getregistry()
	local bf_read = _R["bf_read"]
	local OldRead = {
		ReadAngle = bf_read.ReadAngle,
		ReadBool = bf_read.ReadBool,
		ReadChar = bf_read.ReadChar,
		ReadEntity = bf_read.ReadEntity,
		ReadFloat = bf_read.ReadFloat,
		ReadLong = bf_read.ReadLong,
		ReadShort = bf_read.ReadShort,
		ReadString = bf_read.ReadString,
		ReadVector = bf_read.ReadVector,
		ReadVectorNormal = bf_read.ReadVectorNormal
	}

	bf_read.ReadAngle = function(um)
		local data = OldRead.ReadAngle(um)
		table.insert( ReadList,{ type="Angle", val=tostring(data), bits=12*8 } )
		return data
	end

	bf_read.ReadBool = function(um)
		local data = OldRead.ReadBool(um)
		table.insert( ReadList,{ type="Bool", val=tostring(data), bits=1 } )
		return data
	end

	bf_read.ReadChar = function(um)
		local data = OldRead.ReadChar(um)
		table.insert( ReadList, { type="Char", val=data, bits=8 } )
		return data
	end

	bf_read.ReadEntity = function (um)
		local data = OldRead.ReadEntity(um)
		table.insert( ReadList, { type="Entity", val=tostring(data), bits=16 } )
		return data
	end

	bf_read.ReadFloat = function (um)
		local data = OldRead.ReadFloat(um)
		table.insert( ReadList, { type="Float", val=tostring(data), bits=32 } )
		return data
	end

	bf_read.ReadLong = function (um)
		local data = OldRead.ReadLong(um)
		table.insert( ReadList, { type="Long", val=tostring(data), bits=32 } )
		return data
	end

	bf_read.ReadShort = function (um)
		local data = OldRead.ReadShort(um)
		table.insert( ReadList, { type="Short",val=tostring(data), bits=16 } )
		return data
	end

	bf_read.ReadString = function (um)
		local data = OldRead.ReadString(um)
		local bits = ( string.len( data ) + 1 ) * 8
		table.insert( ReadList, { type="String",val="\""..data.."\"", bits=bits } )
		return data
	end

	bf_read.ReadVector = function (um)
		local data = OldRead.ReadVector(um)
		table.insert( ReadList, { type="Vector",val=tostring(data), bits=12*8 } )
		return data
	end

	bf_read.ReadVectorNormal = function (um)
		local data = OldRead.ReadVectorNormal(um)
		table.insert(ReadList, { type="VectorNormal", val=tostring(data), bits=3*8 } )
		return data
	end

end


local function ClearReadList()
	ReadList = {}
end

local function ReadListToString()

	local str = ""
	local totalbits = 0

	for k, v in pairs( ReadList ) do
		str = str .. v.type .. "(" .. v.val .. ") Bits: " .. v.bits .. "\n"

		totalbits = totalbits + v.bits
	end

	return str, totalbits

end

local usermessages = nil

local function LoadIncomingMessages()

	_G["LOADED_IC"] = _G["LOADED_IC"] or usermessage.IncomingMessage

	usermessage.IncomingMessage = function( strName, bfObject )

		// Clear previous messages
		ClearReadList()

		// Get the incoming messages
		LOADED_IC( strName, bfObject )

		local str, bits = ReadListToString()

		// Print out the results
		if showMessage:GetBool() then
			MsgN( "===\tUserMessage \"" .. 
				  ( strName or "" ) .. 
				  "\" received on " .. os.date() .. 
				  "\t===\n" .. str ..
				  "Total Bits: " .. bits )
		end

		// Add to graph
		if showGraph:GetBool() then

			if !usermessages then usermessages = {} end

			table.insert( usermessages, { strName, bits } )

			if #usermessages > ScrW() then
				table.remove( usermessages, 1 )
			end

		end

	end
	
end

local function SetupUsermessage()

	if ( LocalPlayer().IsAdmin && LocalPlayer():IsAdmin() ) && ( showMessage:GetBool() || showGraph:GetBool() ) then

		timer.Simple( 2, function()

			LoadUsermessageHooks()
			LoadIncomingMessages()

		end )

	end

end

hook.Add( "InitPostEntity", "LoadUsermessages", SetupUsermessage )
hook.Add( "OnReloaded", "LoadUsermessages", SetupUsermessage )

local large = 200
hook.Add( "HUDPaint", "GraphUsermessages", function()

	if ( LocalPlayer().IsAdmin && LocalPlayer():IsAdmin() ) && showGraph:GetBool() then

		if !usermessages then usermessages = {} end

		for id, user in pairs( usermessages ) do

			local name = user[1]
			local bits = user[2]

			local x = id * 2
			local height = bits / 2

			if x > ScrW() then
				usermessages = {}
			end

			surface.SetDrawColor( Color( 255, 255, 255, 50 ) )
			surface.DrawRect( x, ScrH() - height, 2, height )

			if bits > large then

				surface.SetFont( "small" )
				local tw, th = surface.GetTextSize( bits )
				surface.SetTextColor( 255, 0, 0, 255 )

				surface.SetTextPos( x - ( tw / 2 ) + 1, ScrH() - height - th )
				surface.DrawText( bits )

				surface.SetTextPos( x - ( tw / 2 ) + 1, ScrH() - height - th - 10 )
				surface.DrawText( name )

			end

		end

	else
		if usermessages then usermessages = nil end
	end

end )