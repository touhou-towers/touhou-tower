
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	
	//self.Entity:PhysicsInit(SOLID_VPHYSICS)
    //self.Entity:SetMoveType(MOVETYPE_NONE) // Make its movetype MOVETYPE_NONE, so it sits still.
    //self.Entity:SetSolid(SOLID_VPHYSICS)
    
    --self:UpdateModel()
    
    self.Entity:PhysicsInitSphere( 30 )
    self.Entity:SetMoveType( MOVETYPE_NONE )
    self.Entity:SetSolid( SOLID_VPHYSICS )
    self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
    self.Entity:SetTrigger( true )
    
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
    
    self.MoneyAlreadyTouch = false
end

function ENT:Touch( ply )
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if self.MoneyAlreadyTouch == true then return end
    self.MoneyAlreadyTouch = true
	
    ply:EmitSound( self.PickupSound )
    self:Fire("kill")
    
    
    --ply:AddMoney( self:GetMoneyValue() )
	ply:AddMoney( self.MoneyValue )
end

/*function ENT:GetMoneyValue()
	return 0
end*/

/*function ENT:UpdateModel()
	self.Entity:SetModel( self.Model )
end*/

concommand.Add("gmt_devmoney", function(ply, cmd, args)

    if !ply:IsAdmin() then return end
	
	local EntNames = {
		{"one", 1},
		{"ten", 10},
		{"twentyfive", 25},
		{"fifty", 50}
	}
	
	local selection = math.Clamp(tonumber(args[1] or 4), 1, 4)
	
	local EndName = Model("models/gmt_money/" .. EntNames[ selection ][ 1 ] .. ".mdl")
	
	Msg("Admin " .. ply:GetName() .. " spawning gmt_money_" .. EntNames[ selection ][ 1 ] .. "\n")
	
    local prop = ents.Create( "gmt_money_base" )
	prop:SetModel( EndName )
	prop.MoneyValue = EntNames[ selection ][ 2 ]
    prop:SetPos( ply:GetEyeTrace().HitPos + Vector(0, 0, 10) )
    prop:Spawn()

end)
