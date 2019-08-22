
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSubMaterial(2,self.Material)
	self:SetUseType( SIMPLE_USE )
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then

		phys:Wake()
		phys:EnableMotion(false)

	end
end

function ENT:Use( activator, caller )
	local prize
	local gmc_earn
	local ply = caller
	if IsValid( caller ) and caller:IsPlayer() then
		if self:GetState() == 0 && caller.IsSpinning != true  then
			if caller:Afford( self.Cost ) then
				caller.IsSpinning = true
				caller:AddMoney(-self.Cost)

				local bzr = ents.Create("gmt_money_bezier")

				if IsValid( bzr ) then
					bzr:SetPos( caller:GetPos() )
					bzr.GoalEntity = self
					bzr.GMC = self.Cost
					bzr.RandPosAmount = 10
					bzr:Spawn()
					bzr:Activate()
					bzr:Begin()
				end

				self:SetSpinTime(self.SpinDuration)
				self:SetState(4)
				self:SetTarget(math.random(0,15))
				self:SetUser(caller)
				prize = self:GetTarget() + 1
				timer.Simple( self.SpinDuration + self.ExtraSettleTime, function()
					self:SetState(0)
					self:SetUser(NULL)
					caller.IsSpinning = false
					self:PayOut(ply,prize)
				end)
			else
				caller:ChatPrint('You cannot spin, you have do not have enough GMC.')
			end
		end
	end
end

function ENT:PayOut(ply,prize)
	local entity_name
	local gmc_earn

	if self.SLOTS[prize][3] != nil then
		if prize == 14 then
			entity_name = self.SLOTS[prize][3][math.random(1,13)]
		elseif prize == 15 then
			entity_name = self.SLOTS[prize][3][math.random(1,12)]
		else
			entity_name = self.SLOTS[prize][3]
		end
	else
		entity_name = '[No Entity Found]'
	end

	ply:ChatPrint('Won ' .. self.SLOTS[prize][1] .. ', Entity Name is: ' .. entity_name .. '.')

	if prize == 1 || prize == 5 then
		self:EmitSound("GModTower/misc/sad.mp3")
	elseif prize == 2 || prize == 3 || prize == 4 || prize == 6 || prize == 7 || prize == 8 || prize == 10 then
		BasicWin(self)
		timer.Simple( 0.5, function() BasicWin(self) end)
		timer.Simple( 0.5, function() BasicWin(self) end)
		self:EmitSound("GModTower/misc/win_gameshow.mp3")
	else
		BasicWin(self)
		timer.Simple( 0.5, function() BasicWin(self) end)
		self:EmitSound("GModTower/misc/win_crowd.mp3")
	end

	if prize != 5 && string.EndsWith(self.SLOTS[prize][1],'GMC') then
		BasicWin(self)
		timer.Simple( 0.5, function() BasicWin(self) end)
		timer.Simple( 0.5, function() BasicWin(self) end)
		self:EmitSound("GModTower/misc/win_gameshow.mp3")
		gmc_earn = self.GMCPayouts[prize]
		ply:AddMoney(gmc_earn)
	end
end

function BasicWin(ply)
	local effectdata = EffectData();
	effectdata:SetOrigin(ply:GetPos());
	effectdata:SetStart(Vector(1, 1, 1));
	util.Effect("confetti", effectdata);
end
