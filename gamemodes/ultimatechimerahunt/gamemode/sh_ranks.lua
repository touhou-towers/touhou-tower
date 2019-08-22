local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:GetRankName()

	local name = GAMEMODE.Ranks[ self.Rank ].Name

	if self.IsChimera then
		name = "Ultimate Chimera"
	end

	return name

end

function meta:GetRankColor()

	local color = Color( 250, 180, 180 )

	color = GAMEMODE.Ranks[ self.Rank ].Color

	if self.IsChimera then
		color = Color( 230, 30, 110 )
	end
	
	if self.IsGhost then
		color = Color( 250, 250, 250 )
	end

	return color

end

function meta:GetRankColorSat()

	local color = Color( 255, 255, 255 )

	color = GAMEMODE.Ranks[ self.Rank ].SatColor

	return color

end

function meta:SetRank( num )

	local num = math.Clamp( num, 1, 4 )

	self.Rank = num

	if !self.IsGhost then
		self:SetRankModels()
	end

end

function meta:SetRankModels()

	local rank = self.Rank

	if rank > 3 then
		self:SetBodygroup( 2, 1 )
		self:SetBodygroup( 1, 0 )
	else
		self:SetBodygroup( 2, 0 )
		self:SetBodygroup( 1, rank - 1 )
	end

	self:SetSkin( rank - 1 )

end

function meta:RankUp()

	self.NextRank = math.Clamp( self.Rank + 1, 1, 4 )

end

function meta:RankDown()

	self.NextRank = math.Clamp( self.Rank - 1, 1, 4 )

end

function meta:ResetRank()

	self.NextRank = 1

end