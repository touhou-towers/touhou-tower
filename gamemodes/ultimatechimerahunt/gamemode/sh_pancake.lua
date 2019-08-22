local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

if SERVER then

	function meta:Pancake()
		
		if self.IsChimera || self.IsPancake || self.Bit || !GAMEMODE:IsPlaying() then return end
		
		//Msg( "Pancaking Pig: " .. tostring( self ), "\n" )

		self.IsPancake = true
		self:Squeal()

		timer.Simple( .5, function()

			self.Squished = true
			self:Kill()

			GAMEMODE:GetUC():HighestRankKill( self.Rank )
			GAMEMODE:GetUC():AddAchivement( ACHIVEMENTS.UCHPANCAKE, 1 )

			self:ResetRank()

		end )

	end
	
else
	
	function meta:DoPancakeEffect()

		self.PancakeNum = self.PancakeNum or 1

		local num, spd = 1, 8

		self.PancakeNum = math.Approach( self.PancakeNum, .2, ( FrameTime() * ( self.PancakeNum * spd ) ) )

		local scale = Vector(1, 1, self.PancakeNum)
		local mat = Matrix()
		mat:Scale( scale )
		self:EnableMatrix( "RenderMultiply", mat )

	end

end