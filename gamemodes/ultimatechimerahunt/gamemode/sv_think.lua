function GM:Think()

	if self.Ending then return end
	
	if self.FirstPlySpawned && self:GetTimeLeft() <= 0 && self:GetGameState() == STATUS_WAITING then
		hook.Call("StartRound", GAMEMODE )
	end

	if self:GetTimeLeft() <= 0 && GetGlobalInt("Round") <= self.NumRounds && GetGlobalInt("Round") > 0 then
		if self:IsRoundOver() then
			hook.Call("StartRound", GAMEMODE )
		else
			hook.Call("EndRound", GAMEMODE )
		end
	end
	
	if self:GetGameState() == STATUS_INTERMISSION && GetGlobalInt("Round") + 1 > self.NumRounds then 

		for _,ply in ipairs( player.GetAll() ) do

			self:SalsaThink( ply )
			
		end

	end

	if self:GetTimeLeft() < 31 && self:IsPlaying() && !self.Intense then

		self.Intense = true
		for _, v in ipairs( player.GetAll() ) do
			self:HUDMessage( v, MSG_30SEC, 5 )
			self:SetMusic( v, MUSIC_30SEC )
		end

	end
	
	if self:IsLastPigmasks() && self:IsPlaying() && !self.UCAngry then
		
		self.UCAngry = true
		
		for _, v in ipairs( player.GetAll() ) do
			self:HUDMessage( v, MSG_ANGRYUC, 12 )
		end
		
	end
	
	for _, v in ipairs( player.GetAll() ) do
		
		if v.IsChimera then
			self:UCThink( v )
		end

	end
	
end

local function SalsaConfetti( ply )

	local eff = EffectData()
		eff:SetOrigin( ply:GetPos() )
	util.Effect( "confetti", eff )

end

function GM:SalsaThink( ply )

	if !ply:Alive() then return end
	
	if !ply.LastSalsa || ply.LastSalsa < RealTime() then

		ply.LastSalsa = RealTime() + 0.3391  //60 / 176.9 (bpm)

		SalsaConfetti( ply )

	end

end