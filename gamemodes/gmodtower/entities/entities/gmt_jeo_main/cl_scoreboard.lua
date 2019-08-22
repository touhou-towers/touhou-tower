


function ENT:StartScoreboard()
	self.DrawMain = self.DrawScoreboard
	
	self.ScoreboardTime = CurTime()
	
	local SortTable = {}
	local YSPacePlayer = self.PlayerHeight * 1.1 + 1
	self.ScoreStartYOffset = self.TotalMinY + self.TotalHeight - (YSPacePlayer * 8)
	
	self.ScoreBoardPlyX = self.TotalMinX + 15
	self.ScoreBoardWidth = self.TotalWidth - 30
	self.ScoreMinY = self.TotalMinY
	
	for k, v in pairs( self.PlayerData ) do
		if v.Valid then
			table.insert( SortTable, k )
			
			if v.YTruePos > self.ScoreMinY then
				self.ScoreMinY = v.YTruePos
			end
		end
	end
	
	table.sort( SortTable, function(a,b)
	
		local tbla = self.PlayerData[a].Ent
		local tblb = self.PlayerData[b].Ent
	
		if tbla.Points == tblb.Points then
			return tbla.AnswerTime < tblb.AnswerTime
		end
	
		return tbla.Points > tblb.Points
	end )

	for k, v in pairs( SortTable ) do
		
		local tbl = self.PlayerData[v]
		
		
		tbl.ScorePosY = self.ScoreStartYOffset + (k-1) * YSPacePlayer
		tbl.ScorePosition = k
		
		local playerEnt = tbl.Ent:GetPlayer()
		
		if IsValid( playerEnt ) && playerEnt:IsPlayer() then
		
			local playerName = playerEnt:GetName() or "Unknown Player"
			tbl.PlyName = string.sub( playerName, 1, 16 )
			
		end
			
	end
	
	
end	

local AnswerTimePerc = 0.7
local PointsPerc = 0.9

function ENT:DrawScoreboard()

	local perc = math.min( CurTime() - self.ScoreboardTime, 2) / 2
	
	

	surface.SetFont("ChatFont")
	surface.SetTextColor( 255, 255, 255, 255 )
	
	local w, h = surface.GetTextSize( "#" )
	local TitleYPos = self.ScoreMinY - (self.ScoreMinY - self.ScoreStartYOffset + h * 2) * perc
	
	
	surface.SetTextPos( self.ScoreBoardPlyX + 15 + w/2, TitleYPos )
	surface.DrawText( "#" )
	
	local Text = "Nickname"
	local w, h = surface.GetTextSize( Text )
	surface.SetTextPos( self.ScoreBoardPlyX + 12 + 50, TitleYPos )
	surface.DrawText( Text )
	
	Text = "Answer Time"
	local w, h = surface.GetTextSize( Text )
	surface.SetTextPos( self.ScoreBoardPlyX + self.ScoreBoardWidth * AnswerTimePerc - w * 0.5, TitleYPos )
	surface.DrawText( Text )
	
	Text = "Points"
	local w, h = surface.GetTextSize( Text )
	surface.SetTextPos( self.ScoreBoardPlyX + self.ScoreBoardWidth * PointsPerc - w * 0.5, TitleYPos )
	surface.DrawText( Text )
	

	

	for _, v in pairs( self.PlayerData ) do
		if v.Valid && v.ScorePosY then
			
			local PosX = v.XTruePos - (v.XTruePos - self.ScoreBoardPlyX) * perc
			local PosY = v.YTruePos - (v.YTruePos - v.ScorePosY) * perc
			local SqW = self.PlayerWidth - (self.PlayerWidth-self.ScoreBoardWidth) * perc
			local BackColor = self:OnGameGetColor( v.Ent.LastAnswer , true )
			local Name = v.Ent:GetPlayerName()
			
			draw.RoundedBox( 8, 
				PosX, 
				PosY, 
				SqW, 
				self.PlayerHeight, 
				BackColor
			)
			
			w, h = surface.GetTextSize( Name )
			local MiddleY = PosY + self.PlayerHeight * 0.5 - h * 0.5 
			
			surface.SetTextColor( 255, 255, 255, 255 )
			
			surface.SetTextPos( PosX + 12 + 50 * perc, MiddleY )
			surface.DrawText( Name )
			
			local Points = v.Ent:GetPoints()
			w, h = surface.GetTextSize( Points )
			surface.SetTextPos( PosX + SqW * PointsPerc - w * 0.5, MiddleY )
			surface.DrawText( Points )
			
			
			surface.SetTextColor( 255, 255, 255, 255 * perc )
			
			Points = math.Round( v.Ent.AnswerTime * 10 ) / 10 
			w, h = surface.GetTextSize( Points )
			surface.SetTextPos( PosX + SqW * AnswerTimePerc - w * 0.5, MiddleY )
			surface.DrawText( Points )
			
			
			w, h = surface.GetTextSize( v.ScorePosition )
			surface.SetTextPos( PosX + 10, MiddleY )
			surface.DrawText( v.ScorePosition )
			
		end
	end


end