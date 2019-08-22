
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ent = ents.Create( "gmt_npc_money" )
	ent:SetPos( tr.HitPos + Vector(0,0,1) )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
	self:SetSubMaterial(1,self.Material)
end

function ENT:AcceptInput( name, activator, ply )

    if name == "Use" && ply:IsPlayer() && ply:KeyDownLast(IN_USE) == false then
		timer.Simple( 0.0, function()
			if ply:GetNWBool("MoneyNpcTimeout") then ply:SendLua([[Msg2("Whoa, slow down there! You already got some dosh!")]]) return end
			ply:AddMoney( self.MoneyValue )
			ply:SetNWBool("MoneyNpcTimeout",true)
			timer.Simple(10,function() ply:SetNWBool("MoneyNpcTimeout",false) end)
		end)

    end

end
