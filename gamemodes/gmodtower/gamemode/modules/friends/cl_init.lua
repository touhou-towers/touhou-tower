
-----------------------------------------------------

// The file path your friends will be written to

local enable_notice = CreateClientConVar("gmt_notify_friendjoin","1",true)

LocalFilename = "gmtower/friends.txt"
BlockList = "gmtower/blocks.txt"

local function GetPendingFriend(id)

  PendingFriend = player.GetBySteamID64( id )

  if !PendingFriend then return "an unknown player"
  else return PendingFriend:GetName() end

end

concommand.Add("gmt_friend",function(ply, cmd, args, str)

  // Returns nil if the string contains nothing or letters
  local StrNum = tonumber(str)

  // Check if someone just entered random stuff with the command
  if StrNum == nil then
    local Message = Msg2("Right-click players in the TAB menu to add them as a friend.")

    return
  end

  // Self friending prevention
  if LocalPlayer():SteamID64() == str then
    local Message = Msg2("You can't add yourself as a friend!")

    return
  end

  // Check if the txt file already exists, if not, slightly alter the routine and write the friend to it
  if file.Exists(LocalFilename, "DATA") then

    local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))

    if table.HasValue(Friends, str) then Msg2("You've already added this player as your friend!") return end

    file.Append(LocalFilename, str.." ")

    local Message = Msg2("You are now friends with "..GetPendingFriend(str))


  else

    file.CreateDir( "gmtower" )

    file.Write(LocalFilename, str.." ")

    local Message = Msg2("You are now friends with "..GetPendingFriend(str))


  end

  // Empty cache
  player.GetBySteamID64(str).BlockStatus = nil
  player.GetBySteamID64(str).FriendStatus = nil

end)

concommand.Add("gmt_unfriend",function(ply, cmd, args, str)

  local StrNum = tonumber(str)

  if StrNum == nil then
    local Message = Msg2("Right-click players in the TAB menu to unfriend them.")

    return
  end

  if file.Exists(LocalFilename, "DATA") then

    // Get a table of all your current friends
    local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))

    // Remove the friend from the table, and rewrite the file without that friend
    if table.HasValue(Friends, str) then
      table.remove( Friends, table.KeyFromValue( Friends, str ) )
      file.Write( LocalFilename, table.concat( Friends, " " ) )

      local Message = Msg2("You are no longer friends with "..GetPendingFriend(str))


    else
      Msg2("You can't unfriend players you're not friends with!")
      return
    end

  else

    Msg2("You do not have any friends to remove!")

  end

  // Deleted friend cache for that person
  player.GetBySteamID64(str).FriendStatus = nil

end)

function GetFriendStatus(ply)
	if file.Exists("gmtower/friends.txt", "DATA") then
		local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))
		if table.HasValue(Friends, ply:SteamID64()) then
			return "Remove friend"
		else
			return "Add friend"
		end
	else
		return "Add friend"
	end
end

local function GetFriendCommand(ply)
	if GetFriendStatus(ply) == "Add friend" then
		return "gmt_friend"
	else
		return "gmt_unfriend"
	end
end

function CheckFriendship(ply)
	if file.Exists("gmtower/friends.txt", "DATA") then
		local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))
		if table.HasValue(Friends, ply:SteamID64()) then
			return true
		else
			return false
		end
	else
		return false
	end
end

hook.Add( "ExtraMenuPlayer", "AddFriendButton", function( ply )
    if ply != LocalPlayer() && !CheckBlocked(ply) then

		return {
			["Name"] = GetFriendStatus(ply),
			["function"] = function() if ply:IsBot() then return end LocalPlayer():ConCommand( GetFriendCommand(ply).." "..ply:SteamID64() ) end,
			["order"] = 1
		}

	end
end )

function BlockPlayer(ply)

  if LocalPlayer() == ply then
    local Message = Msg2("You can't block yourself!")

    return
  end

	if !file.Exists(BlockList, "DATA") then
		file.CreateDir( "gmtower" )
		file.Write(BlockList, "")
	end

	local Blocked = string.Explode(" ", file.Read(BlockList, "DATA"))

	if table.HasValue(Blocked, ply:SteamID64()) then
		table.remove( Blocked, table.KeyFromValue( Blocked, ply:SteamID64() ) )
		file.Write( BlockList, table.concat( Blocked, " " ) )

		local Message = Msg2("You have unblocked "..ply:Name()..".")

	elseif !table.HasValue(Blocked, ply:SteamID64()) then
		if CheckFriendship(ply) then
			local Message = Msg2("You have blocked your friend "..ply:Name()..".")


			local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))
			table.remove( Friends, table.KeyFromValue( Friends, ply:SteamID64() ) )
			file.Write( LocalFilename, table.concat( Friends, " " ) )
		else
			local Message = Msg2("You have blocked "..ply:Name()..".")

		end

		file.Write(BlockList, ply:SteamID64().." ")
	end

  // Empty cache
  ply.FriendStatus = nil
  ply.BlockStatus = nil

end

local function GetBlockStatus(ply)
	if file.Exists(BlockList, "DATA") then
		local Blocked = string.Explode(" ", file.Read(BlockList, "DATA"))
		if table.HasValue(Blocked, ply:SteamID64()) then
			return "Unblock"
		else
			return "Block"
		end
	else
		return "Block"
	end
end

function CheckBlocked(ply)

	if file.Exists(BlockList, "DATA") then
		local Blocked = string.Explode(" ", file.Read(BlockList, "DATA"))
		if table.HasValue(Blocked, ply:SteamID64()) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function GetRelationship(ply)

	local relationship = ""
	if CheckFriendship(ply) then
		relationship = "Friend"
	elseif CheckBlocked(ply) then
		relationship = "Blocked"
	else
		relationship = ""
	end

	return relationship
end

hook.Add( "ExtraMenuPlayer", "AddBlockButton", function( ply )
    if ply != LocalPlayer() then

		return {
			["Name"] = GetBlockStatus(ply),
			["function"] = function() if ply:IsBot() then return end BlockPlayer(ply) end,
			["order"] = 1
		}

	end
end )

net.Receive("JoinFriendCheck",function()

  if !enable_notice:GetBool() then return end

  local ply = net.ReadEntity()

  // If the file doesn't exists that means you don't have friends to begin with.
  if !file.Exists(LocalFilename, "DATA") then return end

  // Get a table with all your friends
  local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))

  // If the player that's currently joining matches your friends, display the message

  if ply == LocalPlayer() then return end
  if !IsValid(ply) then return end

  if table.HasValue( Friends, ply:SteamID64() ) then

    // Delay the message by 0.5 secs to prevent the nickname being 'unconnected'
    timer.Simple(0.5,function()
      local Message = Msg2( [[Your friend ]]..ply:GetName()..[[ has joined tower!]] )

    end)

  end

end)
