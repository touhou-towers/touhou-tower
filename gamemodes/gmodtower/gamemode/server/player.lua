
local meta = FindMetaTable( "Player" )
if (!meta) then
    Msg("ALERT! Could not hook Player Meta Table\n")
    return
end

function meta:SQLId()
	if !self._GTSqlID then

		if !self.SteamID then
			debug.traceback()
			Error("Trying to get player steamid before player is created!")
		end

		local SteamId = self:SteamID()
		local Findings = {}

		for w in string.gmatch( SteamId , "%d+") do
			table.insert( Findings, w )
		end

		if #Findings == 3 then
			self._GTSqlID = (tonumber(Findings[3]) * 2) + tonumber(Findings[2])
		else
			if SteamId != "STEAM_ID_PENDING" && SteamId != "UNKNOWN" then
				SQLLog( 'error', "sql id could not be found (".. tostring(SteamId) ..")\n" )
			end
			return
		end

	end

	return self._GTSqlID
end


function meta:Money()
    return self:GetSetting("GTMoney")
end

function meta:SetMoney( amount )
    self.GTMoney = math.Clamp( tonumber( amount ), 0, 2147483647 ) // math.pow( 2, 31 )  - 1  -- only allow 31 bits of numbers!
	self:SetSetting( "GTMoney", self.GTMoney )
end

function meta:AddMoney( amount, nosend )

	if amount == 0 then return end

    self:SetMoney( self:Money() + amount )

	if nosend != true then
		if amount > 0 then
			self:MsgT("MoneyEarned", amount )

      local pitch = math.Clamp( math.Fit( amount, 1, 500, 90, 160 ), 90, 160 )
      self:EmitSound( "GModTower/misc/gmc_earn.wav", 50, math.ceil( pitch ) )

    if !nobezier then

      local ent = ents.Create("gmt_money_bezier")

      if IsValid( ent ) then
        ent:SetPos( self:GetPos() + Vector( 0, 0, -10 ) )
        ent.GoalEntity = self
        ent.GMC = amount
        ent.RandPosAmount = 50
        ent:Spawn()
        ent:Activate()
        ent:Begin()
      end
    end

		else
			self:MsgT("MoneySpent", -amount)
      self:EmitSound("gmodtower/misc/gmc_lose.wav",60,math.Clamp((100 - amount * -1 / 25),90,100))
		end
	end

end

function meta:Afford( price )
    return self:Money() >= price
end

function meta:IsBot()
	return IsValid(self) && self:SteamID() == "BOT"
end

function meta:Drink(balamt)
	local balamt = balamt or 10

	if self.BAL + balamt > 100 then
		self:Kill()
		self:ChatPrint("You died from alcohol poisoning.")
		self:UnDrunk()
		return
	end

	self.BAL = math.Clamp(self.BAL + balamt, 0, 100)
	self.NextSoberTime = CurTime() + 10
	self.NextHiccupTime = CurTime() + 5
	self:SetDSP(self.BAL * .2)

	if !self._DrunkStartTime then
		self._DrunkStartTime = CurTime()
	end
end

function meta:UnDrunk()
	self.BAL = 0
	self._DrunkStartTime = nil
	self:SetDSP(1)
end

function meta:DrunkThink()
	if CurTime() > self.NextSoberTime then

		if self._DrunkStartTime && !self:Achived( ACHIVEMENTS.drunkenbastard ) then
			local Time = CurTime() - self._DrunkStartTime

			if Time > self:GetAchivement( ACHIVEMENTS.drunkenbastard ) then
				self:SetAchivement( ACHIVEMENTS.drunkenbastard, Time )
			end
		end

		self.BAL = math.Clamp(self.BAL - 1, 0, 100)

		if self.BAL == 0 then
			self:UnDrunk()
			return
		end

		self.NextSoberTime = CurTime() + 10
	end

	if self:Alive() && CurTime() > self.NextHiccupTime then
		self.NextHiccupTime = CurTime() + 5;

		if math.random( 1, 100 ) <= ( self.BAL * 0.65 ) then
			self:Hiccup()
		elseif math.random( 1, 100 ) <= ( self.BAL * 0.35 ) then
			self:Puke()
		end
	end
end

hook.Add("PlayerThink", "PlayerDrunkThink", function(ply)
	if ply.BAL && ply.BAL > 0 then
		ply:DrunkThink()
	end
end)

function meta:Puke()
	self:ViewPunch(Angle(20, 0, 0))

	local edata = EffectData()
	edata:SetOrigin(self:EyePos())
	edata:SetEntity(self)

	util.Effect("puke", edata, true, true)
end

function meta:Hiccup()
	self:ViewPunch(Angle(-1, 0, 0))

	local edata = EffectData()
	edata:SetOrigin(self:EyePos())
	edata:SetEntity(self)

	util.Effect("hiccup", edata, true, true)
end
