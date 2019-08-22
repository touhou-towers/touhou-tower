
local TypeOnComp = ai_schedule.New( "TypeComp" ) //creates the schedule used on this npc
TypeOnComp:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
TypeOnComp:AddTask( "PlaySequence", { Name = "canals_arlene_tinker", Speed = 1.0  } )
TypeOnComp:EngTask( "TASK_STOP_MOVING", 			0 )

local schdChase = ai_schedule.New( "AIFighter Chase" )
schdChase:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	128 )
schdChase:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
schdChase:AddTask( "PlaySequence", 				{ Name = "canals_arlene_tinker", Speed = 1 } )
schdChase:EngTask( "TASK_GET_PATH_TO_RANGE_ENEMY_LKP_LOS", 	0 )
schdChase:EngTask( "TASK_RUN_PATH", 				0 )
schdChase:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
schdChase:EngTask( "TASK_STOP_MOVING", 			0 )
schdChase:EngTask( "TASK_FACE_ENEMY", 			0 )
schdChase:EngTask( "TASK_ANNOUNCE_ATTACK", 		0 )
schdChase:EngTask( "TASK_RANGE_ATTACK1", 		0 )
schdChase:EngTask( "TASK_RELOAD", 				0 )

//TypeOnComp:AddTask( "PlaySequence", { Name = "canals_arlene_tinker", Speed = 1.0  } )
//TypeOnComp:AddTask( "PlaySequence", { Name = "canals_arlene_tinker", Speed = 1.0  } )
//TypeOnComp:EngTask( "TASK_WAIT", 2.2 )


/*schdChase:EngTask( "ACT_GESTURE_TURN_RIGHT180", 49.0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 )
    */

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "tasks.lua" )
include( "schedules.lua" )

function ENT:OnRemove()
	if timer.Exists("PidgeonSounds") then
		timer.Destroy("PidgeonSounds")
	end
end

function ENT:Initialize()
	self:UpdateModel()

	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	self:CapabilitiesAdd( CAP_MOVE_GROUND || CAP_ANIMATEDFACE || CAP_AIM_GUN || CAP_USE || CAP_OPEN_DOORS || CAP_FRIENDLY_DMG_IMMUNE || CAP_SQUAD )

	if self.PrintName == "Nature Store" then
		timer.Create("PidgeonSounds",25,0,function()
			self:EmitSound("ambient/creatures/pigeon_idle"..math.random(1,4)..".wav")
		end)
	end

	self:SetHealth( 100 )
	self:SetSchedule( 1 )

	if self.PrintName == "Hat Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-1.5,0,3)

		hat:SetModel("models/gmod_tower/seusshat.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetModelScale(0.89)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end
	
	if self.PrintName == "VIP Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-1.5,0,3)
		local AngOffset = Angle(10,0,0)

		hat:SetModel("models/gmod_tower/aviators.mdl")
		hat:SetPos( self:GetPos() + self:GetForward() * 2.5 + self:GetUp() * 1.5 )
		hat:SetAngles( self:GetAngles() + AngOffset )
		hat:SetModelScale(0.89)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end

	if self.PrintName == "Music Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(2,0,3)

		hat:SetModel("models/gmod_tower/headphones.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetModelScale(0.89)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end

	if self.PrintName == "Pet Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-1.1,-1,3)

		hat:SetModel("models/gmod_tower/catears.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetAngles( self:GetAngles() + Angle(0,0,0) )
		hat:SetModelScale(0.89)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end

	if self.PrintName == "General Goods" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-2.2,0,3.2)
		local HatAngle = Angle(0,180,0)

		hat:SetModel("models/gmod_tower/drinkcap.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetAngles( HatAngle )
		hat:SetModelScale(0.97)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end
	
	if self.PrintName == "Toys and Gizmos Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-1.5,0,3)

		hat:SetModel("models/gmod_tower/seusshat.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetModelScale(0.89)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end

	if self.PrintName == "Electronic Store" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(-2,0.4,65)

		hat:SetModel("models/gmod_tower/klienerglasses.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetAngles(Angle(180,90,-100))
		--hat:SetModelScale(0.97)

		hat:Spawn()

		hat:FollowBone( self, 7 )
	end

	if self.PrintName == "Dueling Station" then
		local hat = ents.Create( "prop_dynamic" )
		local HatOffset = Vector(2.5,-28.5,33.5)

		hat:SetModel("models/gmod_tower/fedorahat.mdl")
		hat:SetPos( self:GetPos() + HatOffset )
		hat:SetAngles(Angle(0,0,110))

		hat:Spawn()

		hat:FollowBone( self, self:LookupBone("ValveBiped.Bip01_Head1") )
	end

	GTowerNPCSharedInit(self)


end

function ENT:SetSale( sale )

	self:SetNWBool("Sale",sale)

end

function ENT:TypeOnComp()
	self:StartSchedule( schdChase )
end

function ENT:UpdateModel()
	self:SetModel( self.Model )
end

function ENT:OnCondition( iCondition )
end

function ENT:GetRelationship( entity )
end
