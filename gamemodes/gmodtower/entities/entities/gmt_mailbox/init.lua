
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("gmt_sendnamelist")

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 2

	local ent = ents.Create( "gmt_mailbox" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self.Entity:SetModel( self.Model )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end


end

function ENT:Use( ply )

	if IsPlayer( ply ) then
		self:StartUmsg( ply )
		self:EndUmsg()
	end



end

concommand.Add("gmt_copysuggestions",function(ply)
	if !ply:IsAdmin() then return end

	SQL.getDB():Query("SELECT * FROM `gm_name_suggestions`",
	function( res, status, err )
		if res[1].status != true then
			ErrorNoHalt( res[1].err )
			SQLLog('error', res[1].err )
			return
		end

		local names = {}
		for k,v in pairs(res[1].data) do
			table.insert(names, v.name .. ": " .. v.suggestion)
		end

		net.Start("gmt_sendnamelist")
		net.WriteTable(names)
		net.Send(ply)

	end	)

end)

concommand.Add("gmt_namesuggestion", function( ply, cmd, args, str )

	local Message = str

	if !Message || string.len( Message ) <= 2 then
		return
	end

	if ply.NoNameChange then
		ply:SendLua([[
			local m = Msg2("You've already made a suggestion.")
			m:SetIcon("cancel")
			m:SetColor(Color(0, 115, 207))
		]])
		return
	end

	SQL.getDB():Query("SELECT * FROM `gm_name_suggestions` WHERE player='"..ply:SQLId().."'",
	function( res, status, err )
		if res[1].status != true then
			ErrorNoHalt( res[1].err )
			SQLLog('error', res[1].err )
			return
		end

		if #res[1].data > 0 then
			ply:SendLua([[
				local m = Msg2("You've already made a suggestion.")
				m:SetIcon("cancel")
				m:SetColor(Color(0, 115, 207))
			]])
			ply.NoNameChange = true
		end

	end	)

	if ply.NoNameChange then return end

	local EscapedName = SQL.getDB():Escape( ply:Name() )
	local EscapedMessage = SQL.getDB():Escape( Message )

	SQL.getDB():Query("INSERT INTO `gm_name_suggestions`(`player`,`name`,`suggestion`) VALUES (".. ply:SQLId() ..",'".. EscapedName .."','".. EscapedMessage .."')",
	function( res, status, err )
		if res[1].status != true then
			ErrorNoHalt( res[1].err )
			SQLLog('error', res[1].err )
			return
		end
		ply:SendLua([[
			local m = Msg2("Thank you for your suggestion.")
			m:SetIcon("heart")
			m:SetColor(Color(0, 115, 207))
		]])
		ply.NoNameChange = true
		ply:SendLua([[surface.PlaySound("vo/npc/female01/vanswer0]]..math.random(6,9)..[[.wav")]])
	end	)


end )
