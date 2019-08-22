AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Models = { "models/Zed/malezed_04.mdl",
			"models/Zed/malezed_06.mdl",
			"models/Zed/malezed_08.mdl"
}

//ENT.Model = Model( "models/Zed/malezed_06.mdl" )
//ENT.Model = Model( "models/Zombie/Fast.mdl" )
//ENT.Model = ENT.Models[math.random( 1, #ENT.Models )]

ENT.HP = 100
ENT.Damage = 20
ENT.Points = 8

ENT.SAlert = { "room209/ghost/alert", 3 }
ENT.SAttack = { "room209/ghost/attack", 3 }
ENT.SDie = { "room209/ghost/death", 3 }
ENT.SIdle = { "room209/ghost/idle", 5 }
ENT.SMiss = { "GModTower/Zom/zombie/miss/miss", 2 }
ENT.SPain = { "room209/ghost/pain", 3 }

function ENT:Initialize()
	self:Precache()
	self:SetModel( table.Random(self.Models) )

	self:SetHullSizeNormal()
	self:SetHullType( HULL_HUMAN )
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( CAP_MOVE_GROUND )
	self:CapabilitiesAdd( CAP_INNATE_MELEE_ATTACK1 )

	self:SetMaxYawSpeed( 5000 )
	self:ClearSchedule()
	self:UpdateEnemy( self:FindEnemy() )

	self:SetHealth( self.HP )
end

/*function ENT:Precache()
	for _, mdl in ipairs( self.Models ) do
		util.PrecacheModel( mdl )
	end
end*/
