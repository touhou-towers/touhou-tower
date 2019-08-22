
GTowerGroup.GroupMembers = {}
GTowerGroup.GroupOwner = nil

local IgnoreGroups = CreateClientConVar( "gmt_ignore_group", "0", true, false )
local haloGroup = CreateClientConVar( "gmt_groupglow", 1, true, false )

function GTowerGroup:InGroup()
	return IsValid( GTowerGroup.GroupOwner )
end

function GTowerGroup:GetGroup()
	if !self:InGroup() then
		return
	end

	return self.GroupMembers
end

function GTowerGroup:IsInGroup( ply )
	if ply == nil then
		return self:InGroup()
	end

	for _, v in pairs( self.GroupMembers ) do
		if v == ply then
			return true
		end
	end

	return false
end


/* =======================
	Sendinding / Recieving requests
 ========================= */


function GTowerGroup:RequestJoin( ply )
    if ply == LocalPlayer() then return end

    GtowerMessages:AddNewItem( T("Group_invite_send", ply:GetName() ) )

    RunConsoleCommand("gmt_groupinvite", ply:EntIndex() )

end

function GTowerGroup:RecieveInvite( id, ent )
	local GroupId = id
	local Inviter = ents.GetByIndex( ent )

	Msg("Recieved group(".. GroupId ..") invite: " .. tostring(Inviter) .. "\n")

	if !IsValid( Inviter ) || !Inviter:IsPlayer() then return end

	if IgnoreGroups:GetBool() then
		RunConsoleCommand("gmt_denygroup", GroupId )
		return
	end

	surface.PlaySound("gmodtower/misc/notifygroup.wav")

	local Question = GtowerMessages:AddNewItem( T("GroupInvite", Inviter:GetName() ) , 25.0)
	local function EndRequest( rtn )
		if rtn == 1 then
			RunConsoleCommand("gmt_acceptgroup", GroupId )
		else
			RunConsoleCommand("gmt_denygroup", GroupId )
		end
	end


	Question:SetupQuestion(
        function(GroupId) EndRequest( 1 ) end , //accept
        function(GroupId) EndRequest( 2 ) end , //decline
        function(GroupId) EndRequest( 3 ) end , //timeout
        GroupId,
        {120, 160, 120},
        {160, 120, 120}
    )
end

hook.Add( "PreDrawHalos", "GroupHalos", function()

	local group = GTowerGroup.GroupMembers

	if group && haloGroup:GetBool() then
		halo.Add( group, Color( 255, 242, 40 ), 3, 3, 1, true, true )
	end

end )